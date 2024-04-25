// app/routes.js

module.exports = function (app) {
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
  // ----- Name of symlink pointing to IMDB_ROOT
  let IMDB = '' // History: Replaces the former ´link-to-album´ task of 'imdb' (IMDB_LINK)
  // ----- Name of special (temporary) search result albums
  let picFound = ''
  // ----- Max lifetime (minutes) after last access of a special (temporary) search result album
  let toold = 60
  // ----- For debug data(base) directories
  let show_imagedir = true // for debugging

  // ===== Make a synchronous shell command formally 'asynchronous' (cf. asynchronous execP)
  let cmdasync = async (cmd) => {return execSync (cmd)}
  // ===== ABOUT COMMAND EXECUTION
  // ===== `execP` provides a non-blocking, promise-based approach to executing commands, which is generally preferred in Node.js applications for better performance and easier asynchronous handling.
  // ===== `cmdasync`, using `execSync`, offers a synchronous alternative that blocks the event loop, which might be useful in specific scenarios but is generally not recommended for most use cases due to its blocking nature. `a = await cmdasync(cmd)` and `a = execSync(cmd)` achieve the same end result of executing a command synchronously. The usage differs based on the context (asynchronous with `await` for `cmdasync` versus direct synchronous call for `execSync`). The choice between them depends on whether you're working within an asynchronous function and your preference for error handling and code style.


  // ##### R O U T I N G  E N T R I E S
  // Check 'Express route tester'!
  // ##### #0. General passing point
  app.all ('*', async function(req, res, next) {
    if (req.originalUrl !== '/upload') { // Upload with dropzone: 'req' used else!
      let tmp = req.get('imdbroot')
      if (tmp) {
        IMDB_ROOT = decodeURIComponent(tmp)
        IMDB_DIR = decodeURIComponent( req.get('imdbdir') )
        IMDB = IMDB_HOME + '/' + IMDB_ROOT
        picFound = req.get('picfound')
        // Remove all too old picFound files, NOTE the added random <.01yz>
        let cmd = 'find -L ' + IMDB + ' -type d -name "' + picFound + '*" -amin +' + toold + ' | xargs rm -rf'
        console.log(cmd)
        await cmdasync(cmd)
      }
    }
    console.log('')
    // 30 black, 31 red, 32 green, 33 yellow, 34 blue, 35 magenta, 36 cyan, 37 white, 0 default
    // Add '1;' for bright, e.g. '\x1b[1;33m' is bright yellow, while '\x1b[31m' is red, etc.
    let BYEL = '\x1b[1;33m' // Bright yellow
    let RSET = '\x1b[0m'    // Reset
    console.log(BYEL + decodeURIComponent(req.originalUrl) + RSET);
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
    //console.log (process.memoryUsage ())
    //console.log ('PARAMS', req.params)
    if (req.body && req.body.like) {
      console.log('LIKE', req.body.like)
    }

    next() // pass control to the next handler
  })

  // ##### #0.6 Return user credentials
  app.get('/login/', (req, res) => {
    var name = decodeURIComponent(req.get('username'))
    console.log('  userName:', name)
    var password = ''
    var status = 'viewer'
    var allow = '?'
    try {
      let row = setdb.prepare ('SELECT pass, status FROM user WHERE name = $name').get ( {name: name})
      if (row) {
        password = row.pass
        status = row.status
      }
      row = setdb.prepare ('SELECT allow FROM class WHERE status = $status').get ( {status: status})
      if (row) {
        allow = row.allow
      }
      res.location ('/')
      res.send(password +'\n'+ status +'\n'+ allow)
    } catch (err) {
      res.location('/')
      res.send(err.message)
    }
  })

  // ===== Get the image databases' root directory
  // The server environment should have $IMDB_HOME, else use $HOME
  function imdbHome() {
    var IMDB_HOME = execSync('echo $IMDB_HOME').toString().trim()
    if (!IMDB_HOME || IMDB_HOME === '') {
      IMDB_HOME = execSync('echo $HOME').toString().trim()
    }
    return IMDB_HOME
  }

}
// End module.exports


