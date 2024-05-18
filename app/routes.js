// app/routes.js

module.exports = function (app) { // Start module.exports
  const path = require ('path')
  const Promise = require ('bluebird')
  const fs = Promise.promisifyAll (require ('fs')) // ...Async () suffix
  const execP = Promise.promisify (require ('child_process').exec)
  const multer = require ('multer')
  const upload = multer ( {dest: '/tmp'} ) // tmp upload
  const exec = require ('child_process').exec
  const execSync = require ('child_process').execSync
  const bodyParser = require ('body-parser')

  app.use(bodyParser.urlencoded( {extended: false} ))

  const SQLite = require ('better-sqlite3')
  const setdb = new SQLite('_imdb_settings.sqlite')

  // ----- Upload counter
  let n_upl = 0
  // ----- mailSender/host/provider/smtpRelay for the contact function
  let mailsender = 'savarhembygd@telia.com'
  // ----- Present work directory
  let WWW_ROOT = path.resolve ('.')
  // ----- Root directory where IMDB_ROOTs are found
  let IMDB_HOME = imdbHome () // From env.var. $IMDB_HOME or $HOME
  // ----- Image database root directory
  let IMDB_ROOT = '' // Must be set in route
  // ----- Image database directory
  let IMDB_DIR = '' // Must be set in route
  // ----- Name of 
  let IMDB = ''
  // ----- Name of special (temporary) search result albums
  let picFound = ''
  // ----- Max lifetime (minutes) after last access of a special (temporary) search result album
  let toold = 60
  // ----- For debug data(base) directories
  let show_imagedir = false // for debugging

  // ===== Make a synchronous shell command formally 'asynchronous' (cf. asynchronous execP)
  let cmdasync = async (cmd) => {return execSync (cmd)}
  // ===== ABOUT COMMAND EXECUTION
  // ===== `execP` provides a non-blocking, promise-based approach to executing commands, which is generally preferred in Node.js applications for better performance and easier asynchronous handling.
  // ===== `cmdasync`, using `execSync`, offers a synchronous alternative that blocks the event loop, which might be useful in specific scenarios but is generally not recommended for most use cases due to its blocking nature. `a = await cmdasync(cmd)` and `a = execSync(cmd)` achieve the same end result of executing a command synchronously. The usage differs based on the context (asynchronous with `await` for `cmdasync` versus direct synchronous call for `execSync`). The choice between them depends on whether you're working within an asynchronous function and your preference for error handling and code style.


  // ##### R O U T I N G  E N T R I E S
  // Check 'Express route tester'!
  // ##### General passing point
  app.all ('*', async function(req, res, next) {
    if (req.originalUrl !== '/upload') { // Upload with dropzone: 'req' used else!
      let tmp = req.get('imdbroot')
      if (tmp) {
        IMDB_ROOT = decodeURIComponent(tmp)
        IMDB_DIR = decodeURIComponent( req.get('imdbdir') )
        IMDB = IMDB_HOME + '/' + IMDB_ROOT
        picFound = req.get('picfound')
        // Remove all too old picFound (search result) catalogs, NOTE their added random <.01yz>
        // let picFoundBaseName = picFound.replace(/\.[^.]{4}$/, '')
        // let cmd = 'find -L ' + IMDB + ' -type d -name "' + picFoundBaseName + '*" -amin +' + toold + ' | xargs rm -rf'
        let cmd = 'find -L ' + IMDB + ' -type d -name "' + '§*" -amin +' + toold + ' | xargs rm -rf'
        console.log('\n' + cmd)
        // await cmdasync(cmd) // ger direktare diagnos
        await execP(cmd)
      }
    }
    // 30 black, 31 red, 32 green, 33 yellow, 34 blue, 35 magenta, 36 cyan, 37 white, 0 default
    // Add '1;' for bright, e.g. '\x1b[1;33m' is bright yellow, while '\x1b[31m' is red, etc.
    let BYEL = '\x1b[1;33m' // Bright yellow
    let RSET = '\x1b[0m'    // Reset
    console.log('\n' + BYEL + decodeURIComponent(req.originalUrl) + RSET);
    console.log('  WWW_ROOT:', WWW_ROOT)
    console.log(' IMDB_HOME:', IMDB_HOME)
    console.log('      IMDB:', IMDB)
    console.log(' IMDB_ROOT:', IMDB_ROOT)
    console.log('  IMDB_DIR:', IMDB_DIR)
    console.log('  picFound:', picFound)
    if (show_imagedir) {
      console.log(req.params)
      console.log(req.hostname)
      console.log(req.originalUrl)
    }
    // console.log (process.memoryUsage ())
    if (req.body && req.body.like) {
      console.log('LIKE', req.body.like)
    }
    next() // pass control to the next handler
  })

  // ##### Return a user's credentials for login, or return
  //       all available user statuses and their allowances
  app.get('/login/', (req, res) => {
    var name = decodeURIComponent(req.get('username'))
    console.log('  userName: "' + name + '"')
    var password = ''
    var status = ''
    var allow = ''
    try {
      if (name) {
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

        res.location ('/')
        console.log(password +'\n'+ status +'\n'+ allow +'\n'+ freeUsers)
        res.send(password +'\n'+ status +'\n'+ allow +'\n'+ freeUsers)

      } else { // Send all recorded user statuses and their allowances, formatted
        let rows = setdb.prepare('SELECT * FROM class ORDER BY status').all()
        var allowances = ''
        for (let j=0;j<rows.length;j++) {
          allowances +=  rows[j].status + ' '
        }
          allowances += '\n──────────────────────────────────────────────\n'
        let al = rows[0].allow.length
        for (let i=0;i<al;i++) {
          for (let j=0;j<rows.length;j++) {
            // allowances += '     ' + (rows[j].allow)[i].replace(/0/g, '⋅').replace(/1/g, '@') // overkill
            if (j) { var space = '     ' } else { space = '    ' }
            allowances += space + (rows[j].allow)[i].replace('0', '.').replace('1', 'x')
          }
          allowances += '     \n'
        }
        allowances += '──────────────────────────────────────────────\n'
        console.log(allowances.trim())
        res.location ('/')
        res.send(allowances.trim())
      }
    } catch (err) {
      console.log('Sqlite(?)error:', err.message)
      res.location('/')
      res.send('Sqlite(?)error: ' + err.message)
    }
  })

  // ##### Find subdirs which are album roots
  app.get ('/rootdir/', function (req, res) {
    readSubdir (IMDB_HOME).then (dirlist => {
      dirlist = dirlist.join ('\n')
      // var tmp = execSync ("echo $IMDB_ROOT").toString ().trim ()
      // if (dirlist.indexOf (tmp) < 0) {tmp = ""}
      // dirlist = tmp + '\n' + dirlist
      res.location ('/')
      res.send (dirlist)
      //res.end ()
    })
    .catch ( (err) => {
      console.error ("RRR", err.message)
      res.location ('/')
      res.send (err.message)
    })
  })

  // ##### Get IMDB (image data base) directories list,
  //       i.e. get all possible album directories
  app.get ('/imdbdirs/', async function (req, res) {
    await new Promise (z => setTimeout (z, 200))
    // Refresh picFoundx: the shell commands must execute in sequence
    let pif = IMDB + '/' + picFound
    let cmd = 'rm -rf ' + pif + ' && mkdir ' + pif + ' && touch ' + pif + '/.imdb'
    await cmdasync (cmd)
    setTimeout (function () {
      allDirs ().then (dirlist => { // dirlist entries start with the root album
        areAlbums (dirlist).then (async dirlist => {
          // dirlist = dirlist.sort ()
          let dirtext = dirlist.join ("€")
          let dircoco = [] // directory content counter
          let dirlabel = [] // Album label thumbnail paths

          // Get all thumbnails and select randomly
          // one to be used as "subdirectory label"
          for (let i=0; i<dirlist.length; i++) {
            cmd = "echo -n `ls " + IMDB + dirlist [i] + "/_mini_* 2>/dev/null`"
            let pics = await execP (cmd)
            pics = pics.toString ().trim ().split (" ")
            if (!pics [0]) {pics = []} // Remove a "" element
            let npics = pics.length
            if (npics > 0) {
              let k, n = 1 + Number ((new Date).getTime ().toString ().slice (-1))
              // Instead of seeding, loop n (1 to 10) times to get some variation:
              for (let j=0; j<n; j++) {
                k = Math.random ()*npics
              }
              var albumLabel = pics [Number (k.toString ().replace (/\..*/, ""))]
            } else {albumLabel = "€" + dirlist [i]}
            // Count the number of subdirectories
            let subs = occurrences (dirtext, dirlist [i]) - 1
            npics = " (" + npics + ")"
            if (i > 0 && subs) {npics += subs} // text!
            dircoco.push (npics)
            dirlabel.push (albumLabel)
          }
          for (let i=0; i<dirlist.length; i++) {
            var albumLabel
            if (dirlabel [i].slice (0, 1) === "€" && dirlabel [i].indexOf (picFound) === -1) {
              albumLabel = dirlabel [i].slice (1)
              dirlabel [i] = ""
              for (let j=i+1; j<dirlist.length; j++) { // Take any subalbum's minipic if available
                if (albumLabel === dirlabel [j].slice (IMDB.length).slice (0, albumLabel.length)) {
                  dirlabel [i] = dirlabel [j]
                  break
                }
              }
            }
          }

          //OLD: let fd, ignorePaths = IMDB_HOME + "/" + IMDB_ROOT + "/_imdb_ignore.txt"
          let fd, ignorePaths = IMDB + "/_imdb_ignore.txt"
          try { // Create _imdb_ignore.txt if missing
            fd = await fs.openAsync (ignorePaths, 'r')
            await fs.closeAsync (fd)
          } catch (err) {
            fd = await fs.openAsync (ignorePaths, 'w') // created
            await fs.closeAsync (fd)
          }
          // An _imdb_ignore line/path may/should start with just './' (if not #)
          let ignore = (await execP ("cat " + ignorePaths)).toString ().trim ().split ("\n")
          for (let j=0; j<ignore.length; j++) {
            for (let i=0; i<dirlist.length; i++) {
              if (ignore [j] && ignore [j].slice (0, 1) !== '#') {
                ignore [j] = ignore [j].replace (/^[^/]*/, "")
                if (ignore [j] && dirlist [i].startsWith (ignore [j])) dircoco [i] += "*"
              }
            }
          }
          dirtext = dirtext.replace (/€/g, "\n")
          dircoco = dircoco.join ("\n")
          dirlabel = dirlabel.join ("\n")
          // NOTE: IMDB = IMDB_HOME + "/" + IMDB_ROOT, but here "@" separates them (important!):
          dirtext = IMDB_HOME + "@" + IMDB_ROOT + "\n" + dirtext + "\nNodeJS " + process.version.trim ()
          res.location ('/')
          //NOTE: The paths include IMDB_ROOT, soon removed by caller!
          res.send (dirtext + "\n" + dircoco + "\n" + dirlabel)
          //res.end ()
          console.log ('Directory information sent from server')
        })
      }).catch (function (error) {
        res.location ('/')
        res.sloadend (error.message)
      })
    }, 2000) // Was 1000
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

  // ===== Read the dir's content of album sub-dirs (not recursively)
  readSubdir = async (dir, files = []) => {
    let items = await fs.readdirAsync ('rln' + dir) // items are file || dir names
    return Promise.map (items, async (name) => { // Cannot use mapSeries here (why?)
      //let apitem = path.resolve (dir, name) // Absolute path
      let item = path.join (dir, name) // Relative path
      if (acceptedDirName (name) && !brokenLink (item)) {
        let stat = await fs.statAsync ('rln' + item)
        if (stat.isDirectory ()) {
          let flagFile = path.join (item, '.imdb')
          let fd = await fs.openAsync ('rln' + flagFile, 'r')
          if (fd > -1) {
            await fs.closeAsync (fd)
            files.push (name)
          }
        }
      }
    })
    .then (files, () => {
      return files
    })
    .catch ( (err) => {
      console.error ("€ARG", err.message)
      return err.toString ()
    })
  }

  // ===== Check if an album/directory name can be accepted
  function acceptedDirName (name) { // Note that &ndash; is accepted:
    let acceptedName = 0 === name.replace (/[/\-–@_.a-zåäöA-ZÅÄÖ0-9]+/g, "").length
    return acceptedName && name.slice (0,1) !== "." && !name.includes ('/.')
  }

  // ===== Is this file/directory a broken link? Returns its name or false
  // NOTE: Broken links may cause severe problems if not taken care of properly!
  brokenLink = item => {
    return execSync ("find '" + item + "' -maxdepth 0 -xtype l 2>/dev/null").toString ()
  }

} // End module.exports


