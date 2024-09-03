// app/routes.js

module.exports = function(app) { // Start module.exports
  const path = require('path')
  const Promise = require('bluebird')
  const fs = Promise.promisifyAll(require('fs')) // ...Async() suffix
  const execP = Promise.promisify(require('child_process').exec)
  const multer = require('multer')
  const upload = multer( {dest: '/tmp'} ) // tmp upload
  const exec = require('child_process').exec
  const execSync = require('child_process').execSync
  const bodyParser = require('body-parser')

  app.use(bodyParser.urlencoded( {extended: false} ))

  const SQLite = require('better-sqlite3')
  const setdb = new SQLite('_imdb_settings.sqlite')

  let n_upl = 0 // Upload counter
  let mailsender = 'savarhembygd@telia.com' // mailSender/host/provider/smtpRelay
  let WWW_ROOT = path.resolve('.') // Present work directory
  let IMDB_HOME = imdbHome() // Root directory where IMDB_ROOTs are found
  let IMDB_ROOT = '' // Image database root directory
  let IMDB_DIR = ''  // Actual image database(sub)directory
  let IMDB = ''
  let picFound = '' // Name of special(temporary) search result album
  let show_imagedir = false // For debug data(base) directories
  let allfiles = [] // For /imagelist use

  // ===== Make a synchronous shell command formally 'asynchronous'(cf. asynchronous execP)
  let cmdasync = async(cmd) => {return execSync(cmd)}
  // ===== ABOUT COMMAND EXECUTION
  // ===== `execP` provides a non-blocking, promise-based approach to executing commands, which is generally preferred in Node.js applications for better performance and easier asynchronous handling.
  // ===== `cmdasync`, using `execSync`, offers a synchronous alternative that blocks the event loop, which might be useful in specific scenarios but is generally not recommended for most use cases due to its blocking nature. `a = await cmdasync(cmd)` and `a = execSync(cmd)` achieve the same end result of executing a command synchronously. The usage differs based on the context (asynchronous with `await` for `cmdasync` versus direct synchronous call for `execSync`). The choice between them depends on whether you're working within an asynchronous function and your preference for error handling and code style.

  // 30 black, 31 red, 32 green, 33 yellow, 34 blue, 35 magenta, 36 cyan, 37 white, 0 default
  // Add '1;' for bright, e.g. '\x1b[1;33m' is bright yellow, while '\x1b[31m' is red, etc.
  
  const BGRE = '\x1b[1;32m' // Bright green
  const BYEL = '\x1b[1;33m' // Bright yellow
  const RED  = '\x1b[31m'   // Red
  const RSET = '\x1b[0m'    // Reset
  
  const LF = '\n' // Line Feed == New Line
  // Max lifetime(minutes) after last access of a temporary search result album:
  const toold = 60

  //#region = code regions, only for the editors's minilist in the right margin!
  //#region start route
  // ##### R O U T I N G  E N T R I E S
  // Check 'Express route tester'!
  // ##### General passing point
  app.all('*', async function(req, res, next) {
    if (req.originalUrl !== '/upload') { // Upload with dropzone: 'req' used else!
      let tmp = req.get('imdbroot')
      if (tmp) {
        IMDB_ROOT = decodeURIComponent(tmp)
        IMDB_DIR = decodeURIComponent( req.get('imdbdir') )
        IMDB = IMDB_HOME + '/' + IMDB_ROOT
        picFound = req.get('picfound')
        // The server AUTOMATICALLY removes old search result temporary albums:
        // Remove too old picFound (search result tmp) catalogs (with added random .01yz)
        let cmd = 'find -L ' + IMDB + ' -type d -name "' + '§*" -amin +' + toold + ' | xargs rm -rf'
        // await cmdasync(cmd) // ger direktare diagnos
        await execP(cmd)
        // console.log(BYEL + cmd + RSET)
      }
    }
    console.log(BGRE + decodeURIComponent(req.originalUrl) + RSET)
    // console.log('  WWW_ROOT:', WWW_ROOT)
    // console.log(' IMDB_HOME:', IMDB_HOME)
    // console.log('      IMDB:', IMDB)
    // console.log(' IMDB_ROOT:', IMDB_ROOT)
    // console.log('  IMDB_DIR:', IMDB_DIR)
    // console.log('  picFound:', picFound)
    if (show_imagedir) {
      console.log(req.params)
      console.log(req.hostname)
      console.log(req.originalUrl)
    }
    // console.log(process.memoryUsage())
    if (req.body && req.body.like) {
      console.log('LIKE', req.body.like)
    }
    next() // pass control to the next handler
  })

  //region execute
  // ##### Execute a shell command
  app.get ('/execute', async (req, res) => {
    var cmd = decodeURIComponent(req.get('command'))
    console.log(BYEL + cmd + RSET)
    try {
      // NOTE: exec seems to use ``-ticks, not $()
      // Hence don't pass "`" if you don't escape it
      cmd = cmd.replace (/`/g, "\\`")
      var resdata = await execP (cmd)
      res.location ('/')
      res.send (resdata)
      //res.end ()
    } catch (err) {
      /*console.error ("`" + cmd + "`")
      console.error (err.message)
      res.location ('/')*/
      res.send (err.message)
    }
  })

  //#region login
  // ##### Return a user's credentials for login, or return
  //       all available user statuses and their allowances
  app.get('/login', (req, res) => {
    var name = decodeURIComponent(req.get('username'))
    var password = ''
    var status = ''
    var allow = ''
    try {
      if (name) {
        console.log('  userName: "' + name + '"')
        let row = setdb.prepare('SELECT pass, status FROM user WHERE name = $name').get({name: name})
        if (row) {
          password = row.pass
          status = row.status
        }
        row = setdb.prepare('SELECT allow FROM class WHERE status = $status').get({status: status})
        if (row) {
          allow = row.allow
        }
        let rows = setdb.prepare('SELECT name FROM user WHERE pass = ? ORDER BY name').all('')
        var freeUsers = []
        for (let i=0;i<rows.length;i++) {
          freeUsers[i] = rows[i].name
        }
        freeUsers = freeUsers.join(', ')
        console.log(' freeUsers:', freeUsers)

        res.location('/')
        // console.log(password +LF+ status +LF+ allow +LF+ freeUsers)
        res.send(password +LF+ status +LF+ allow +LF+ freeUsers)

      } else { // Send all recorded user statuses and their allowances, formatted
        console.log('Get the table of user rights')
        let rows = setdb.prepare('SELECT * FROM class ORDER BY status').all()
        var allowances = ''
        for (let j=0;j<rows.length;j++) {
          allowances +=  rows[j].status + ' '
        }
          allowances += '\n──────────────────────────────────────────────\n'
        let al = rows[0].allow.length
        for (let i=0;i<al;i++) {
          for (let j=0;j<rows.length;j++) {
            // allowances += '     ' +(rows[j].allow)[i].replace)(/0/g, '⋅').replace(/1/g, '@') // overkill
            if (j) { var space = '     ' } else { space = '    ' }
            allowances += space +(rows[j].allow)[i].replace('0', '.').replace('1', 'x')
          }
          allowances += '     \n'
        }
        allowances += '──────────────────────────────────────────────\n'
        console.log(allowances.trim())
        res.location('/')
        res.send(allowances.trim())
      }
    } catch(err) {
      console.log('Sqlite(?)error:', err.message)
      res.location('/')
      res.send('Sqlite(?)error: ' + err.message)
    }
  })

  //#region rootdir
  // ##### Find subdirs which are album roots
  app.get('/rootdir', function(req, res) {
    readSubdir(IMDB_HOME).then(dirlist => {
      dirlist = dirlist.join(LF)
      // var tmp = execSync("echo $IMDB_ROOT").toString().trim()
      // if (dirlist.indexOf(tmp) < 0) {tmp = ""}
      // dirlist = tmp + LF + dirlist
      res.location('/')
      res.send(dirlist)
      //res.end()
    })
    .catch((err) => {
      console.error("RRR", err.message)
      res.location('/')
      res.send(err.message)
    })
  })

  //#region imdbdirs
  // ##### Get IMDB(image data base) directories list,
  //       i.e. get all possible album directories, recursive
  app.get('/imdbdirs', async function(req, res) {
    await new Promise(z => setTimeout(z, 200))
    let allowHidden = req.get('hidden')
    // Refresh picFound: the shell commands must execute in sequence
    let pif = IMDB + '/' + picFound
    let cmd = 'rm -rf ' + pif + ' && mkdir ' + pif + ' && touch ' + pif + '/.imdb'
    // await cmdasync(cmd) // better diagnosis
    await execP(cmd)
    // console.log(BYEL + cmd + RSET)
    console.log('Refreshed the picFound tmp album')
    setTimeout(function() {
      allDirs().then(dirlist => { // dirlist entries start with the root album
        areAlbums(dirlist).then(async dirlist => {
          // dirlist = dirlist.sort()
          var albumLabel
          let dircoco = [] // directory content counters
          let dirlabel = [] // album label thumbnail paths

          // Hidden albums are listed in _imdb_ignore.txt, create if missing
          let fd, ignorePaths = IMDB + "/_imdb_ignore.txt"
          try {
            fd = await fs.openAsync(ignorePaths, 'r')
            await fs.closeAsync(fd)
          } catch(err) {
            fd = await fs.openAsync(ignorePaths, 'w') // created
            await fs.closeAsync(fd)
          }
          // Remove hidden albums from the list if allowHidden is 'false'
          if (allowHidden !== 'true') {
            for (let i=0; i<dirlist.length; i++) {
              // An _imdb_ignore line/path may/should start with just './'(if not #)
              let ignore =(await execP("cat " + ignorePaths)).toString().trim().split(LF)
              for (let j=0; j<ignore.length; j++) {
                if (ignore[j].slice(0, 1) === '#') ignore[j] = ''
                ignore[j] = ignore[j].replace(/^[^/]*/, '')
                for (let i=dirlist.length-1;i>-1;i--) {
                  if (ignore[j] && ignore[j].slice(0, 1) !== '#') {
                    if (ignore[j] && dirlist[i].startsWith(ignore[j])) {
                      dirlist.splice(i, 1)
                      break
                    }
                  }
                }
              }
            }
          }

          // Get all thumbnails and select randomly
          // one to be used as "subdirectory label"
          for (let i=0; i<dirlist.length; i++) {

            cmd = "echo -n `find " + IMDB + dirlist[i] + " -maxdepth 1 -type l -name '_mini_*' | grep -c ''`"
            let nlinks =(await execP(cmd))/1 // Get no of linked images
            cmd = "echo -n `ls " + IMDB + dirlist[i] + "/_mini_* 2>/dev/null`"
            let pics = await execP(cmd) // Get all images
            pics = pics.toString().trim().split(" ")
            if (!pics[0]) {pics = []} // Remove a "" element
            let npics = pics.length // No of images in the album
            if (npics) {
              let k, n = 1 + Number((new Date).getTime().toString().slice(-1))
              // Instead of seeding, loop n(1 to 10) times to get some variation:
              for (let j=0; j<n; j++) {
                k = Math.random()*npics
              }
              albumLabel = pics[Number(k.toString().replace(/\..*/, ""))]
            } else {albumLabel = "€" + dirlist[i]} // Mark empty albums
            // Count the number of subdirectories; albums are in sorted order
            var subs = 0
            if (i) {
              for (let j=i+1; j<dirlist.length; j++) {
                if ((dirlist[j]).startsWith(dirlist[i])) ++subs
              }
            } else {
              subs = dirlist.length - 1 // All subsubs to root
            }
            if (nlinks) {
              npics = "(" +(npics - nlinks) + "+" + nlinks + ")"
            } else {
              npics = "(" + npics + ")"
            }
            if (subs) {npics += ' ' + subs + '‡'} // text!
            dircoco.push(npics)
            dirlabel.push(albumLabel)
          }
          for (let i=0; i<dirlist.length; i++) {
            // console.log('A i dirlabel[i]',i,dirlabel[i])
            if (dirlabel[i].slice(0, 1) === "€") {
              albumLabel = dirlabel[i].slice(1)
              dirlabel[i] = ""
              for (let j=i+1; j<dirlist.length; j++) { //Take any subalbum's minipic if available
                if (albumLabel === dirlabel[j].slice(IMDB.length).slice(0, albumLabel.length)) {
                  dirlabel[i] = dirlabel[j]
                  // console.log('B i dirlabel[i]',i,dirlabel[i])
                  break
                }
              }
            }
          }
          // Add a mark for hidden files(if not removed already)
          if (allowHidden === 'true') {
            // An _imdb_ignore line/path may/should start with just './'(if not #)
            let ignore =(await execP("cat " + ignorePaths)).toString().trim().split(LF)
            for (let j=0; j<ignore.length; j++) {
              for (let i=0; i<dirlist.length; i++) {
                // console.log('C i dirlabel[i]',i,dirlabel[i])
                if (ignore[j] && ignore[j].slice(0, 1) !== '#') {
                  ignore[j] = ignore[j].replace(/^[^/]*/, "")
                  if (ignore[j] && dirlist[i].startsWith(ignore[j])) dircoco[i] += " *"
                }
              }
            }
          }
          let dirtext = dirlist.join(LF)
          dircoco = dircoco.join(LF)
          dirlabel = dirlabel.join(LF)
          // Add 2 lines at start: Node version and imdbPath
          dirtext = "NodeJS " + process.version.trim() + LF + IMDB + LF + dirtext
          res.location('/')
          //NOTE: The paths include IMDB_ROOT, soon removed by caller!
          res.send(dirtext + LF + dircoco + LF + dirlabel)
          //res.end()
          console.log('Directory information sent from server')
        })
      }).catch(function(error) {
        res.location('/')
        res.sloadend(error.message)
      })
    }, 500) // Was 1000
  })

  //#region imagelist
  // ##### Get all images in IMDB_DIR using 'findFiles' with readdirAsync,
  //       Bluebird support  
  app.get('/imagelist', function(req, res) {
    // NOTE: Reset allfiles here, since it isn't refreshed by an empty album!
    allfiles = undefined
    //OLD: IMDB_DIR = req.params.imagedir.replace(/@/g, "/")

    // console.log('IMAGELIST')

    findFiles(IMDB_DIR).then(async function(files) {

      // console.log('files from FINDFILES:', files)

      if (!files) {files = []}
      var origlist = ''
      //files.forEach(function(file) { not recommended
      for (var i=0; i<files.length; i++) {
        var file = files [i]
        // Check the file name and that it is not a broken link: !`find <filename> xtype l`
        if (acceptedFileName(file.slice((IMDB + IMDB_DIR).length + 1)) && !brokenLink(file)) {
          origlist = origlist +'\n'+ file
        }
      }
      origlist = origlist.trim()
      ////////////////////////////////////////////////////////
      // Get, check and package quadruple file names:
      //    [ 3 x relative-path, and simple-name ]   of
      //    [ origfile(without root-link-name, nov 2014),
      //               showfile, minifile, nameonly ]
      // where the corresponding images will be sized(e.g.)
      //    [ full, 640x640, 150x150, -- ]   with file type
      //    [ image/*, png, png, -- ]   *(see application.hbs)
      // Four text lines represents an image's names
      ////////////////////////////////////////////////////////
      // Next to them, two '\n-free' metadata lines follow:
      // 5 Xmp.dc.description
      // 6 Xmp.dc.creator
      // 7 Last is '&' or the path to the origin if this is a symlink
      ////////////////////////////////////////////////////////
      // pkgfilenames prints initial console.log message
      await pkgfilenames(origlist).then(() => {
        if (!allfiles) {allfiles = ''}
        res.location('/')
        res.send(allfiles)
        //res.end()
        console.log('...file information sent from server') // Remaining message
      }).catch(function(error) {
        res.location('/')
        res.send(error.message)
      })
    })
  })

  //#region sortlist
  // ##### Get sorted file name list
  app.get ('/sortlist', async function(req, res) {
    var imdbtxtpath = IMDB + IMDB_DIR + '/_imdb_order.txt'
    try { // Create _imdb_order.txt if missing
      fd = await fs.openAsync (imdbtxtpath, 'r') // check
      await fs.closeAsync (fd)
    } catch (err) {
      fd = await fs.openAsync (imdbtxtpath, 'w') // create
      await fs.closeAsync (fd)
      execSync ('chmod 664 ' + imdbtxtpath)
    }
    fs.readFileAsync (imdbtxtpath)
    .then (names => {
        // console.log ('/sortlist/:names' +'\n'+ names) // names <buffer> here converts to <text>
      res.send (names) // Sent buffer arrives as text
    }).then (console.info ('File order sent from server'))
  })

  //#region Functions

  // ===== Get the image databases' root directory
  // The server environment should have $IMDB_HOME, else use $HOME
  function imdbHome() {
    var IMDB_HOME = execSync('echo $IMDB_HOME').toString().trim()
    if (!IMDB_HOME || IMDB_HOME === '') {
      IMDB_HOME = execSync('echo $HOME').toString().trim()
    }
    return IMDB_HOME
  }

  // ===== Read the dir's content of album sub-dirs(not recursively)
  readSubdir = async(dir, files = []) => {
    let items = await fs.readdirAsync('rln' + dir) // items are file || dir names
    return Promise.map(items, async(name) => { // Cannot use mapSeries here(why?)
      //let apitem = path.resolve(dir, name) // Absolute path
      let item = path.join(dir, name) // Relative path
      if (acceptedDirName(name) && !brokenLink(item)) {
        let stat = await fs.statAsync('rln' + item)
        if (stat.isDirectory()) {
          let flagFile = path.join(item, '.imdb')
          let fd = await fs.openAsync('rln' + flagFile, 'r')
          if (fd > -1) {
            await fs.closeAsync(fd)
            files.push(name)
          }
        }
      }
    })
    .then(files,() => {
      return files
    })
    .catch((err) => {
      console.error("€ARG", err.message)
      return err.toString()
    })
  }

  // ===== Check if an album/directory name can be accepted
  function acceptedDirName(name) { // Note that &ndash; is accepted:
    let acceptedName = 0 === name.replace(/[/\-–@_.a-zåäöA-ZÅÄÖ0-9]+/g, "").length
    return acceptedName && name.slice(0,1) !== "." && !name.includes('/.')
  }

  // ===== Is this file/directory a broken link? Returns its name or false
  // NOTE: Broken links may cause severe problems if not taken care of properly!
  brokenLink = item => {
    return execSync("find '" + item + "' -maxdepth 0 -xtype l 2>/dev/null").toString()
  }


  // ===== Read the IMDB's content of sub-dirs recursively
  // Use: allDirs().then(dirlist => { ...
  // IMDB is the absolute current album root path
  // Returns directories formatted like imdbDirs,(first "", then /... etc.)
  let allDirs = async() => {
    let dirlist = await cmdasync('find -L ' + IMDB + ' -type d|sort')
    dirlist = dirlist.toString().trim() // Formalise string
    dirlist = dirlist.split(LF)
    for (let i=0; i<dirlist.length; i++) {
      dirlist[i] = dirlist[i].slice(IMDB.length)
    }
    return dirlist
  }

  // ===== Remove from a directory path array each entry not pointing
  // to an album, which contains a file named '.imdb', and return
  // the remaining album directory list. NOTE: Both returns(*) are required!
  let areAlbums = async (dirlist) => {
    let fd, albums = []
    return Promise.mapSeries(dirlist, async(album) => { //(*) CAN use mapSeries here but don't understand why!?
      try {
        fd = await fs.openAsync('rln' + IMDB + album + '/.imdb', 'r')
        await fs.closeAsync(fd)
        // Exclude dotted, and not actual picFound files
        if (album.includes('/.') || album.includes('§') && album.indexOf(picFound) === -1) {
          // Ignore 'dotted' directory paths
          //console.log("NOT album:", album)
        } else {
          albums.push(album)
        }
      } catch(err) {
        // Ignore directories without '.imdb' file
        //console.log("NOT album:", album)
      }
    }).then(() => {
      return albums //(*)
    }).catch((err) => {
      console.error("€RRR", err.message)
      return err.toString()
    })
  }

  // ===== Read a directory's file content; also remove broken links
  function findFiles(dirName) {

    // console.log('FINDFILES')
    // console.log('rln' + IMDB + dirName)

    return fs.readdirAsync('rln' + IMDB + dirName).map(function(fileName) { // Cannot use mapSeries here(why?)
      var filepath = path.join(IMDB + dirName, fileName)

      // console.log('filepath:', filepath)

      var brli = brokenLink(filepath) // refers to server root
      if (brli) {
        rmPic(filepath) // may hopefully also work for removing any single file ...
        return path.join(path.dirname(filepath), '.ignore') // fake dotted file
      }
      return fs.statAsync('rln' + filepath).then(function(stat) {
        if (stat.mode & 0o100000) {
          // See 'man 2 stat': S_IFREG bitmask for 'Regular file', and google more!
          return filepath
        } else {
          return path.join(path.dirname(filepath), ".ignore") // fake dotted file
        }
      })
    })
    .reduce(function(a, b) {
      //return a.concat(b)
      if (b) {a = a.concat(b)} // Discard undefined, probably from brokenLink check(?)
      return a
    }, [])
    .catch(err => {
      console.log("£RR", err.toString())
    })
  }

  // ===== Make a package of orig, show, mini, and plain filenames, metadata, and symlink flag=origin
  async function pkgfilenames(origlist) {

          // console.log('PKGFILENAMES')
          // console.log('origlist: \n' + origlist)

    if (origlist) {
      let files = origlist.split('\n')

      // console.log('origlist:', files)

      allfiles = ''
      for (let file of files) {
        execSync('pentaxdebug ' + file) // Pentax metadata bug fix is done here
        let pkg = await pkgonefile(file)
        //console.log("pkg\n" + pkg)
        allfiles += '\n' + pkg
      }
      console.log('Showfiles•minifiles•metadata...')
      return allfiles.trim()
    } else {
      return ''
    }
  }
  async function pkgonefile(file) {

    // console.log('PKGONEFILE', file)

    let origfile = file
    let symlink = await symlinkFlag(origfile)
    let fileObj = path.parse(origfile)
    let namefile = fileObj.name
    if (namefile.length === 0) {return null}
    let showfile = path.join(fileObj.dir, '_show_' + namefile + '.png')
    let minifile = path.join(fileObj.dir, '_mini_' + namefile + '.png')
    if (symlink === '&') {
      resizefileAsync(origfile, showfile, "'640x640>'")
      .then(resizefileAsync(origfile, minifile, "'150x150>'")).then()
    } else {
      //let linkto = await cmdasync("readlink " + origfile).then().toString().trim() // NOTE: Buggy, links badly, why, wrong syntax?
      let linkto = execSync("readlink " + origfile).toString().trim()
      let linkObj = path.parse(linkto)

      await cmdasync("ln -sfn " + linkObj.dir + "/" +"_show_"+ linkObj.name + ".png " + showfile)
      .then(
      await cmdasync("ln -sfn " + linkObj.dir + "/" +"_mini_"+ linkObj.name + ".png " + minifile))
      .then()
    }
    let cmd = []
    let tmp = '--' // Should never show up
    // Extract Xmp data with exiv2 scripts to \n-separated lines
    cmd [0] = 'xmp_description ' + origfile // for txt1
    cmd [1] = 'xmp_creator ' + origfile     // for txt2
    // START HERE if you want to add, for example, xmp.dc.source = "notes text", and so on.
    // BUT REMEMBER, if so, to extend for this everywhere, after "res.send *" in "get * imagelist"
    let txt12 = ''
    for (let _i = 0; _i< cmd.length; _i++) {
      tmp = "?" // Should never show up
      //tmp = execSync(cmd [_i])
      tmp = await cmdasync(cmd [_i])
      tmp = tmp.toString().trim() // Formalise string
      if (tmp.length === 0) tmp = "-" // Insert fill character
      tmp = tmp.replace(/\n/g," ").trim() // Remove embedded \n(s)
      if (tmp.length === 0) tmp = "-" // Insert fill character
      txt12 = txt12 +'\n'+ tmp
    }
    // Triggers browser autorefresh but no meaning to refresh symlinks:
    let qrn = '?' + Math.random().toString(36).substring(2,6)
    if (symlink !== '&') {qrn = ''}
    // origfile without root-link-name, nov 2014, e.g. imdb/aa/bb => aa/bb :
    // origfile without the whole IMDB-path, jan 2022:
    return(origfile.slice(IMDB.length) +'\n'+ showfile + qrn +'\n'+ minifile + qrn +'\n'+ namefile +'\n'+ txt12.trim()).trim() +'\n'+ symlink // NOTE: returns 7 rows, the last often '&'
  }

  // ===== Create minifile or showfile (note: size!), if non-existing
  // origpath = the file to be resized, filepath = the resized file
  async function resizefileAsync(origpath, filepath, size) {
    // Check if the file exists, then continue, but note (!): This openAsync will
    // fail if filepath is absolute. Needs web-rel-path to work ...
    fs.openAsync(filepath, 'r').then(async () => { // async!
      if (Number(fs.statSync (filepath).mtime) < Number(fs.statSync(origpath).mtime)) {
        await rzFile(origpath, filepath, size) // await!
      }
    })
    .catch(async function(error) { // async!
      // Else if it doesn't exist, make the resized file:
      if (error.code === "ENOENT") {
        await rzFile(origpath, filepath, size) // await!
      } else {
        console.error('resizefileAsync', error.message)
        throw error
      }
    })
  }

  // ===== Use of ImageMagick: It is no longer true that
  // '-thumbnail' stands for '-resize -strip', perhaps darkens pictures ...
  // Note: All files except GIFs are resized into JPGs and thereafter
  // 'fake typed' PNG (resize into PNG is too difficult with ImageMagick).
  // GIFs are resized into GIFs to preserve their special properties.
  // The formal file extension PNG will still be kept for all resized files.
  async function rzFile(origpath, filepath, size) {
    var filepath1 = filepath // Set 'png' as in filepath
    if (origpath.search(/gif$/i) > 0) {
      filepath1 = filepath.replace(/png$/i, 'gif') // gif to gif
    } else {
      filepath1 = filepath.replace(/png$/i, 'jpg') // Others to jpg
    }
    var imckcmd
    imckcmd = "convert " + origpath + " -antialias -quality 80 -resize " + size + " -strip " + filepath1
    //console.log(imckcmd)
    exec(imckcmd,(error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`)
        return
      }
      //if(filepath1 !== filepath) {
        try { // Rename to 'fake png' and adjust mode
          execSync("mv " + filepath1 + " " + filepath + "&&chmod 664 " + filepath)
        } catch(err) {
          console.error(err.message)
        }
      //}
      console.log(' .' + filepath.slice(IMDB.length) + ' created') // Hide absolute server path
    })
    return
  }

  // ===== Check if an image/file name can be accepted
  // Also, cf. 'acceptedFiles' in menu-buttons.hbs (for DropZone/drop-zone)
  function acceptedFileName(name) {
    // This function must equal the acceptedFileName function in drop-zone.js
    var acceptedName = 0 === name.replace(/[-_.a-zA-Z0-9]+/g, "").length
    // Allowed file types are also set at drop-zone in the template menu-buttons.hbs
    var ftype = name.match(/\.(jpe?g|tif{1,2}|png|gif)$/i)
    var imtype = name.slice(0, 6) // System file prefix
    // Here more files may be filtered out depending on o/s needs etc.:
    return acceptedName && ftype && imtype !== '_mini_' && imtype !== '_show_' && imtype !== '_imdb_' && name.slice(0,1) !== "."
  }

  // ===== Remove the files of a picture, filename with full web path
  //      (or deletes at least the primarily named file)
  function rmPic(fileName) {
    let picfile = path.parse(fileName).base
    let pngname = path.parse(fileName).name + '.png'
    let imdbImdbDir = path.parse(fileName).dir
    let IMDB_PATH = (IMDB + IMDB_DIR)
    let tmp = 'Directory mismatch when "' + fileName.slice(IMDB.length) + '" is deleted'
    if (imdbImdbDir !== IMDB_PATH) console.log('INFO: ' + RED + tmp + RSET)
    fs.unlinkAsync(imdbImdbDir + '/' + picfile) // File not found isn't caught!
    .then(sqlUpdate(fileName))
    .then(fs.unlinkAsync(imdbImdbDir +'/_mini_'+ pngname)) // File not found isn't caught!
    .then(fs.unlinkAsync(imdbImdbDir +'/_show_'+ pngname)) // File not found isn't caught!
    .then()
    .catch(function(error) {
      if (error.code === "ENOENT") {
        tmp = 'FILE NOT FOUND by ' + IMDB_ROOT + IMDB_DIR + '/' + picfile
      } else {
        tmp = 'NO PERMISSION to ' + IMDB_ROOT + IMDB_DIR + '/' + picfile
        console.log(RED + tmp + RSET)
        return tmp
      }
    })
    return 'DELETED'
  }

  // ===== Return a symlink flag value, value = & or source file
  function symlinkFlag (file) {
    return new Promise (function (resolve, reject) {
      fs.lstat (file, function (err, stats) {
        if (err) {
          console.error ('symlinkFlag', err.message)
        } else if (stats.isSymbolicLink ()) {
          resolve (execSync ("readlink " + file).toString ().trim ())
        } else {
          resolve ('&') // normal file
        }
      })
    })
  }

  // THIS FUNCTION IS NEVER USED
  /** Function that counts occurrences of a substring in a string;
   * @param {String} string               The string
   * @param {String} subString            The substring to search for
   * @param {Boolean} [allowOverlapping]  Optional.(Default:false)
   *
   * @author Vitim.us https://gist.github.com/victornpb/7736865
   * @see Unit Test https://jsfiddle.net/Victornpb/5axuh96u/
   * @see http://stackoverflow.com/questions/4009756/how-to-count-string-occurrence-in-string/7924240#7924240
   */
  function occurrences(string, subString, allowOverlapping) {
    string += "";
    subString += "";
    if (subString.length <= 0) return(string.length + 1)

    var n = 0,
      pos = 0,
      step = allowOverlapping ? 1 : subString.length;

    while(true) {
      pos = string.indexOf(subString, pos)
      if (pos >= 0) {
        ++n;
        pos += step;
      } else break;
    }
  //console.log(subString, n)
    return n;
  }

} // End module.exports


