//== Mish common storage service with global properties/methods

import Service from '@ember/service';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { htmlSafe } from '@ember/template';

import { replace } from 'tar';
import he from 'he';
// USE: <div title={{he.decode 'text'}}></div> ['he' = HTML entities]
// or  txt = he.decode('text')  or  txt = he.encode('text')

const LF = '\n'   // Line Feed == New Line
const BR = '<br>' // HTML line break

export default class CommonStorageService extends Service {
  @service intl;

  //   #region VARIABLES
  //== Significant Mish system global variables

  @tracked  aboutThis = '«Mish»'; //info (to be changed) about Mish build version etc.
  @tracked  albumHistory = [0];   //album index visit history
  @tracked  bkgrColor = '#111';   //default background color
  @tracked  credentials = '';     //user credentials: \n-string from db
        get defaultUserName() { return `${this.intl.t('guest')}`; }
  @tracked  freeUsers = 'guest...'; //user names without passwords (set by DialogLogin)
  @tracked  imdbCoco = '';    //content counters etc. for 'imdbDirs', see (*) below
  @tracked  imdbDir = '';     //actual/current (sub)album directory (IMDB_DIR)
  @tracked  imdbDirIndex = 0; //actual/current (sub)album directory index
        get imdbDirName() {   //the last-in-path album name of 'imdbRoot+imdbDir'
              if (this.imdbRoot) {
                return (this.imdbRoot + this.imdbDir).replace(/^(.*\/)*([^/]+)$/, '$2');
              } else {
                return '';
              }
            }
  @tracked  imdbDirs = [''];        //available album directories at imdbRoot
  @tracked  imdbLabels = [''];      //thumbnail labels for 'imdbDirs' (paths)
  @tracked  imdbPath = this.userDir + this.imdbRoot; //userDir+imdbRoot = absolut path to album root
  @tracked  imdbRoot = '';          //chosen album root directory (= collection)
        get imdbRootsPrep() { return `${this.intl.t('reloadApp')}`; } // advice!
  @tracked  imdbRoots = [this.imdbRootsPrep]; //available album root directories
  @tracked  imdbTree = null;                  //will have the 'imdbDirs' object tree
  @tracked  infoHeader = 'Header text';       //for the alert dialog DialogAlert
  @tracked  infoMessage = 'No information';   //for dialog texts (e.g. DialogAlert)
        get intlCode() { return `${this.intl.t('intlcode')}`; }
  @tracked  intlCodeCurr = this.intlCode;     // language code
        get picFoundBaseName() { return `${this.intl.t('picfound')}`; }
  // The found pics temporary catalog name is amended with a random 4-code:
  @tracked  picFound = this.picFoundBaseName +"."+ Math.random().toString(36).substring(2,6);
  @tracked  picName = ''; //actual/current image name
        get picIndex() { //the index of picName's file information object in allFiles
          let index = this.allFiles.findIndex(a => {return a.name === this.picName;});
          return index;
        }
  @tracked  sortOrder = '';    //file order information table of 'imdbDir'
  @tracked  subColor = '#aef'; //subalbum legends color
        get subaIndex() {      //subalbum index array for imdbLabels
              let subindex = [];
              for (let i=this.imdbDirIndex+1;i<this.imdbDirs.length;i++) {
                if (this.imdbDirs[i] && this.imdbDirs[i].startsWith(this.imdbDir)) {
                  if (this.imdbDirs[i].slice(this.imdbDir.length + 1).split('/').length === 1) {
                    subindex.push(i);
                  }
                }
              }
              return subindex;
            }
  @tracked  textColor = '#fff';          //default text color
  //       maybe your home dir., server start argument IMDB_HOME
  @tracked  userDir = '/path/to/albums';
  //       userName may be changed in other ways later (e.g. logins):
  @tracked  userName = this.defaultUserName;
  @tracked  userStatus = ''; // A logged in user has a certain allowance status

  // (*) imdbCoco format is "(<npics>[+<nlinked>]) [<nsubdirs>] [<flag>]"
  // where <npics> = images, <nlinks> = linked images, <nsubdirs> = subalums,
  // and <flag> is empty or "*". The <flag> indicates a hidden album,
  // which needs permission for access


  //   #region VIEW VARS
  //== Miniature and show images etc. information

  @tracked  navKeys = false; // Protects from unintended use of L/R arrow keys
  @tracked  allFiles = [];   // Image file information objects, changes with 'imdbDir'
  @tracked  displayNames = 'none'; // Image name display switch
  @tracked  edgeImage = '';  // Text indicating first/last image
  @tracked  hasImages = false; // true if 'imdbDir' has at least one image
  // 'maxWarning' is set in Welcome (about 100?), more will trigger a warning:
  @tracked  maxWarning = 0;  // Recommended max. number of images in an album
  // Dynamic album information:
  @tracked  numHidden = 0;  // Number of images with hide flag in 'sortOrder'
  @tracked  numImages = 0;  // Total numder of images in the album
  @tracked  numInvisible = 0; // Number of invisible images
  @tracked  numLinked = 0;    // Number of images linked into the album
  @tracked  numMarked = 0;  // Number of selection marked images
  @tracked  numOrigin = 0;  // Numder of own original images in the album
  @tracked  numShown = 0;

  @tracked  refreshTexts = 0; // Refresh trigger for RefreshThis

  //   #region ALOWANCE
  //== Allowances variables/properties/methods

  @tracked allow = {}; // The allow object is defined by allowFunc()

  // Rights text table retreived from _imdb_settings.sqlite datbase and
  // initially assembled by the server on demand from the login dialog
  @tracked allowances = '';

  @tracked allowance = [  // defines the order of 'allow'
                    //
    "adminAll",     // + allow EVERYTHING
    "albumEdit",    // +  " create/delete album directories
    "appendixEdit", // o  " edit appendices (attached documents)
    "appendixView", // o  " view     "
    "delcreLink",   // +  " delete and create linked images NOTE *
    "deleteImg",    // +  " delete (= remove, erase) images NOTE *
    "imgEdit",      // o  " edit images
    "imgHidden",    // +  " view and manage hidden images
    "imgOriginal",  // +  " view and download full size images
    "imgReorder",   // +  " reorder images
    "imgUpload",    // +  " upload    "
    "notesEdit",    // +  " edit notes (metadata) NOTE *
    "notesView",    // +  " view   "              NOTE *
    "saveChanges",  // +  " save order/changes (= saveOrder)
    "setSetting",   // +  " change settings
    "textEdit"      // +  " edit image texts (metadata) and hidden albums
                    //
                    // o = not yet used
  ];

  // allowvalue is the source of the 'allow' property values, reset at login
  @tracked allowvalue = "0".repeat (this.allowance.length);

  get allowText() { return [  // IMPORTANT: Ordered as 'allow'!
    `adminAll:     ${this.intl.t('adminAll')}`,
    `albumEdit:    ${this.intl.t('albumEdit')}`,
    `appendixEdit: ${this.intl.t('appendixEdit')}`,
    `appendixView: ${this.intl.t('appendixView')}`,
    `delcreLink:   ${this.intl.t('delcreLink')}`,
    `deleteImg:    ${this.intl.t('deleteImg')}`,
    `imgEdit:      ${this.intl.t('imgEdit')}`,
    `imgHidden:    ${this.intl.t('imgHidden')}`,
    `imgOriginal:  ${this.intl.t('imgOriginal')}`,
    `imgReorder:   ${this.intl.t('imgReorder')}`,
    `imgUpload:    ${this.intl.t('imgUpload')}`,
    `notesEdit:    ${this.intl.t('notesEdit')}`,
    `notesView:    ${this.intl.t('notesView')}`,
    `saveChanges:  ${this.intl.t('saveChanges')}`,
    `setSetting:   ${this.intl.t('setSetting')}`,
    `textEdit:     ${this.intl.t('textEdit')}`
  ];}

  allowFunc = () => { // Called from Welcome and dialogLogin after login
    var allow = this.allow;
    var allowance = this.allowance;
    var allowvalue = this.allowvalue;
    for (var i=0; i<allowance.length; i++) {
      allow[allowance[i]] = Number(allowvalue[i]);
    }
    if (allow.adminAll) {
      allowvalue = "1".repeat (this.allowance.length);
      for (var i=0; i<allowance.length; i++) {
        allow[allowance[i]] = 1;
      }
    }
    if (allow.deleteImg) {  // NOTE *  If ...
      allow.delcreLink = 1; // NOTE *  then set this too
      i = allowance.indexOf("delcreLink");
      // Also set the source value (in this way since allowvalue[i] = "1" isn't allowed: compiler error: "4 is read-only" if 4 = the index value)
      allowvalue = allowvalue.slice(0, i - allowvalue.length) + "1" + allowvalue.slice(i + 1 - allowvalue.length);
    }
    if (allow.notesEdit) { // NOTE *  If ...
      allow.notesView = 1; // NOTE *  then set this too
      i = allowance.indexOf("notesView");
      allowvalue = allowvalue.slice(0, i - allowvalue.length) + "1" + allowvalue.slice(i + 1 - allowvalue.length);
    }
    // Hide smallbuttons we don't need:
    if (allow.saveChanges) {
      document.getElementById('saveOrder').style.display = '';
    } else { // Any user may reorder but not save
      document.getElementById('saveOrder').style.display = 'none';
    }
    this.allow = allow;
    this.allowance = allowance;
    this.allowvalue = allowvalue;
  }

  //   #region TEXT UTILS
  //== Text functions

  // Replace <br> with \n, used in dialog-text/DialogText
  deNormalize2LF = (str) =>{
    return str.replace(/<br>/g, LF);
  }

  // Neutralize dots for CSS, e.g. in the querySelector() argument
  escapeDots = (textString) => { // Cf. CSS.escape()
    // Used for file names when used in CSS, #<id> etc.
    return textString.replace (/\./g, "\\.");
  }

  // Susbtitute underscores in an album name with spaces and remove the first
  // character and the random end from a temporary 'found-images-album' name
  handsomize2sp = (name) => {
    let tmp = name.replace(/_/g, ' ');
    if (tmp[0] === '§') tmp = tmp.replace(/\.[^.]+$/, '').slice(1);
    return tmp;
  }

  // Replace \n with <br> and remove excess spaces
  // Used in saveDialog('dialogText'), cf. deNormalize2LF
  normalize2br = (str, leaveEnd) => {
    if (leaveEnd) {
      str = str.trimStart();
    } else {
      str = str.trim();
    }
    return str.replace(/\n +/g, LF).replace(/\n/g, ' <br>').replace(/ +/g, ' ');
  }

  // Remove HTML tags from text
  noTags = (txt) => {
    let tmp = txt.toString().replace(/<(?:.|\n)*?>/gm, ""); // Remove <tags>
    tmp = he.decode(tmp); // for attributes
    tmp = tmp ? tmp : ' ';
    return tmp;
  }

  // Remove HTML tags from the text and shorten to fit thumbnails
  noTagsShort = (txt) => {
    let tmp = txt.toString().replace(/<(?:.|\n)*?>/gm, ""); // Remove <tags>
    return tmp.slice(0, 23) ? tmp.slice(0, 23) : '&nbsp;';
  }

  // Replace underscores with ' ' or '&nbsp;'
  removeUnderscore = (textString, noHTML) => {
    return textString.replace (/_/g, noHTML ? ' ' : '&nbsp;');
  }


  //   #region UTILITIES
  //== Other service functions






  // Disable browser back arrow, go instead to most recent visited album
  //#region initBrowser
  initBrowser = async () => {
    // Refresh the setting, it may have been lost!
    while (this.bkgrColor) { // Intended eternal loop
      window.history.pushState (null, "");
      window.onpopstate = () => {
        this.goBack();
      }
      await new Promise (z => setTimeout (z, 10000)); // eternal loop pause
    }
  }

  // Browswer back arrow
  //#region goBack
  goBack = () => {
    if (!this.imdbRoot) return;
    this.albumHistory.pop();
    let index = this.albumHistory.length - 1;
    // if (index < 1) { // Reset even at 0=root, may prohibit "browser disorder"
    if (index < 0) {
      this.albumHistory = [0];
      return;
    }
    index = this.albumHistory[index];
    if (this.albumHistory.length > 1) this.albumHistory.pop();
    this.openAlbum(index);
  }

  //#region ifToggleHide
  ifToggleHide = () => {
    if (this.numHidden) {
      document.getElementById('toggleHide').style.display = '';
    } else {
      document.getElementById('toggleHide').style.display = 'none';
    }
  }

  //#region openAlbum
  openAlbum = async (i) => {
    this.picName = '';
    this.closeDialogs(); // close possibly open dialogs
    // Close the show image view
    document.querySelector('.img_show').style.display = 'none'; //was 'table'
    // Open the thumbnail view
    document.querySelector('.miniImgs.imgs').style.display = 'flex';
    // Display the spinner
    document.querySelector('img.spinner').style.display = '';
    // Set marked zero
    this.numMarked = 0;

    i = Number(i); // important!
    if (i === 0) this.albumHistory = [0]; // Recover from possible "browser disorder"
    this.imdbDir = this.imdbDirs[i];
    this.imdbDirIndex = i;
    let h = this.albumHistory;
    if (h.length > 0 && h[h.length - 1] !== i) this.albumHistory.push(i);
    let a = this.imdbRoot + this.imdbDir;
    this.loli('opened album ' + i + ' ' + a, 'color:lightgreen' );
    // Reset colors in the album tree of the main menu
    for (let tmp of document.querySelectorAll('span.album')) {
      tmp.style.color = '';
    }
    // Set color mark on the selected album name and make it visible
    document.querySelector('span.album.a' + i).style.color = '#f46aff';
    let selected = document.querySelector('div.album.a' + i);
    selected.style.display = '';
    // Check that all parents are visible too
    while (selected.parentElement.classList.contains('album')) {
      selected = selected.parentElement;
      if (selected.nodeName !== 'DIV') break;
      selected.style.display = '';
    }

    // Retreive information for every image file from the server:
    this.allFiles = await this.getImages();
        // this.loli(this.allFiles, 'color:lightgreen');
        // console.log(this.allFiles);

    // Get the image order information from the server:
    this.sortOrder = await this.requestOrder();
        // this.loli('sortOrder:\n' + this.sortOrder, 'color:yellow');

    // Now arrange allFiles according to sortOrder before populating DOM
    let allFiles = this.allFiles;
    let newFiles = [];
    let order = this.sortOrder.split(LF);
    let name, k;
        // this.loli(order);
    for (let ord of order) {
      name = ord.split(',')[0]
      k = allFiles.findIndex(all => {return all.name === name;});
          // this.loli(k + ' ' + name, 'color:brown')
      if (k > -1) {
        newFiles.push(allFiles[k]);
        allFiles[k] = '';
      }
    }
    // The remaining (if any)
    for (let file of allFiles) {
      if (file) newFiles.push(file);
    }
    this.hasImages = newFiles.length > 0;
    this.numImages = newFiles.length;
    this.allFiles = newFiles;

    this.clearMiniImgs(); // remove any old thumbnails
    // Hide the subalbums etc.
    document.querySelector('#upperButtons').style.display = 'none';
    document.querySelector('.albumsHdr').style.display = 'none';

    // Populate the DOM with mini images by using the hidden
    // load button in component(s) 'ViewMain > AllImages' to
    // "push the allFiles content" into the thumbnail template:
    document.getElementById('loadMiniImages').click();

    // Then hide the spinner
    document.querySelector('img.spinner').style.display = 'none';

    // Show the subalbums etc.
    document.querySelector('#upperButtons').style.display = '';
    document.querySelector('.albumsHdr').style.display = '';

    // Warn for too many images, if relevant
    if (this.allFiles.length > this.maxWarning && this.allow.imgUpload) {
      this.alertMess(this.intl.t('sizewarning') + ' ' + this.maxWarning + ' ' + this.intl.t('images') + '!', 6);
    }

    // Preload the show images
    let preloadShowImg = [];
    for (let file of this.allFiles) {
      let img = new Image();
      img.src = 'rln' + file.show;
      preloadShowImg.push(img);
    }

    // Reset the show/hide button since hidden images are not shown initially
    this.hideHidden();

    // Prepare for an initial arrow key hit by setting
    // 'this.picName' to the last in album
    if (this.allFiles.length > 0) {
      this.picName = this.allFiles[this.allFiles.length - 1].name;
    } else this.picName = '';

    // Allow for the rendering of mini images and preload of view images
    let size = this.albumAllImg(i);
    await new Promise (z => setTimeout (z, size*2)); // album load

    // Set classes and different background on hidden images
    this.paintHideFlags();
    // Count the number of shown, invisible, linked, unlinked, etc. images
    this.countNumbers();
  }

  //#region toggleBackg
  toggleBackg = () => {
    if (this.bkgrColor === '#cbcbcb') {
      this.bkgrColor = '#111';
      this.textColor = '#fff';
      this.subColor = '#aef';
      this.setCookie('mish_bkgr', 'dark');
      this.loli('set dark background');
    } else {
      this.bkgrColor = '#cbcbcb';
      this.textColor = '#111';
      this.subColor = '#146';
      this.setCookie('mish_bkgr', 'light');
      this.loli('set light background');
    }
    document.querySelector('body').style.background = this.bkgrColor;
    document.querySelector('body').style.color = this.textColor;
  }

  //#region loli
  loli = (text, style) => { // loli = log list with user name
    console.log(this.userName + ': %c' + text, style);
  }




  // Check each thumbnails' hide status and set classes
  //#region paintHideFlags
  paintHideFlags = () => {
    let order = this.updateOrder(true); // array if true, else text

    let hide = document.getElementById('toggleHide')
      .style.backgroundImage === 'url("/images/eyes-blue.png")';

    for (let p of order) {
      let i = p.indexOf(',');
      let mini = document.getElementById('i' + p.slice(0, i));
      if (p[i + 1] === '1') {
        mini.classList.add('hidden');
      } else {
        mini.classList.remove('hidden');
      }
      if (hide && p[i + 1] === '1') {
        mini.classList.add('invisible');
      } else {
        mini.classList.remove('invisible');
      }
    }
  }

  // Check the slide-view's symlink/hide status and set classes
  //#region paintViewImg
  paintViewImg = () => {
    let mini = document.getElementById('i' + this.picName);
    let show = document.getElementById('link_texts');
    if (mini.classList.contains('symlink')) {
      show.classList.add('symlink');
    } else {
      show.classList.remove('symlink');
    }
    if (mini.classList.contains('hidden')) {
      show.classList.add('hidden');
    } else {
      show.classList.remove('hidden');
    }
  }

  //#region countNumbers
  countNumbers = () => {
    this.numHidden = document.querySelectorAll('.img_mini.hidden').length;
    this.ifToggleHide();
    this.numInvisible = document.querySelectorAll('.img_mini.invisible').length;
    this.numLinked = document.querySelectorAll('.img_mini.symlink').length;
    this.numOrigin = this.numImages - this.numLinked;
    this.numShown = document.querySelectorAll('.img_mini').length - this.numInvisible;
    if (this.numImages !== this.numShown + this.numInvisible) {
      this.alertMess(this.intl.t('numbererror'), 0);
      this.loli('shown:' + this.numShown + ' + invisible:' + this.numInvisible + ' != sum:' + this.numImages, 'color:red');
    }
  }

  //#region clearMiniImgs
  clearMiniImgs = () => { // Remove any displayed
    for (let pic of document.querySelectorAll('div.img_mini')) pic.remove();
  }





  // Setting sec to 0 doesn't avoid `inherited Timeout` close!
  //#region alertMess
  alertMess = async (mess, sec) => {
    this.closeDialog('dialogAlert');
    this.infoHeader = this.intl.t('infoHeader'); // default header
    this.infoMessage = mess.replace(/\n/g, '<br>');
    this.openDialog('dialogAlert');
    // this.openModalDialog('dialogAlert');
    if (sec) { // means close after sec seconds
      await new Promise (z => setTimeout (z, sec*1000)); // alertMess
      this.closeDialog('dialogAlert');
    }
  }

  //#region albumAllImg
  albumAllImg = (i) => { // number of original + symlink images in album 'i'
    let c = this.imdbCoco[i];
    return eval(c.replace(/^.*(\(.+\)).*$/, '$1'));
  }





  //#region totalOrigImg
  totalOrigImg = () => { // number of original images in total
    let n = 0;
    let c = this.imdbCoco;
    for (let i=0;i<c.length;i++) {
      n += Number(c[i].replace(/^[^(]*\(([0-9]+).*$/, '$1'));
    }
    return n;
  }

  //#region resetBorders
  resetBorders = () => { // Reset all mini-image borders and SRC attributes
    var minObj = document.querySelectorAll('.img_mini img.left-click');
    for (let min of minObj) {
      min.classList.remove('dotted');
    }
    // Resetting all minifile SRC attributes ascertains that any minipic is shown
    // (maybe created just now, e.g. at upload, any outside-click will show them)
    // NOTE: Is this outdated 2024? We'll test and see, perhaps 2025.
    for (var i=0; i<minObj.length; i++) {
      var minipic = minObj[i].src;
      minObj[i].removeAttribute('src');
      minObj[i].setAttribute('src', minipic);
    }
  }
  //#region markBorders
  markBorders = async (namepic) => { // Mark a mini-image border
    await new Promise (z => setTimeout (z, 25)); // Allow the dom to settle
    document.querySelector('#i' + this.escapeDots(namepic) + ' img.left-click').classList.add('dotted');
  }

  // Position to a minipic and highlight its border
  //#region gotoMinipic
  gotoMinipic = async (namepic) => {
    // await new Promise (z => setTimeout (z, 1999)); // Scroll
    let hs = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
    // this.loli('hs=' + hs, 'color:red');
    let h2 = hs/2;
    // NOTE: No escapeDots for getElementById:
    let p = document.getElementById('i' + namepic);
    // this.loli('p=' + p, 'color:red');
    let y = p.offsetTop ? p.offsetTop : 0;
    // this.loli('y=' + y, 'color:red');
    y = p.offsetHeight ? y + p.offsetHeight/2 : y;
    // this.loli('y=' + y, 'color:red');
    let t = document.getElementById('highUp').offsetTop;
    // this.loli('top=' + t, 'color:red');
    let b = document.getElementById('lowDown').offsetTop;
    // this.loli('bottom=' + b, 'color:red');
    y -= h2 - 150;
    // this.loli('y-h2=' + y, 'color:red');
    if (y < t) y = t;
    // if (y > b - hs) y = b - hs;
    scrollTo(null, y);
    this.resetBorders(); // Reset all borders
    this.markBorders(namepic); // Mark this one
  }

  //#region showHidden
  showHidden = () => {
    document.getElementById('toggleHide').style.backgroundImage = 'url(/images/eyes-white.png)';
    for (let pic of document.querySelectorAll('.img_mini.hidden')) {
      pic.classList.remove('invisible');
    }
    this.numInvisible = 0;
    this.numShown = this.numImages;
  }
  //#region hideHidden
  hideHidden = () => {
    document.getElementById('toggleHide').style.backgroundImage = 'url(/images/eyes-blue.png)';
    let n = 0;
    for (let pic of document.querySelectorAll('.img_mini.hidden')) {
      pic.classList.add('invisible');
      n++;
    }
    this.numInvisible = n;
    this.numShown = this.numImages - this.numInvisible;
  }

  // Open or close the named show image, path = its path in the current album
  // showImage('') will close the show image and reopen the thumbnails
  //#region showImage
  showImage = async (name, path, e) => {
    // Here the thumbnail is clicked: is it with Ctrl or Shift?
    // If so, other than the 'show image' is demanded:
    if (e) {
      e.stopPropagation();
      let tgt = e.target;
      if (tgt.closest('.img_mini')) {
        // WHEN DOES THIS HAPPEN? **************
        this.picName = tgt.closest('.img_mini').id.slice(1);
      }
      if (e.button === 0) {
        let pic = document.getElementById('i' + this.picName);
        if (e.ctrlKey) {
          pic.querySelector('.menu_img').click();
          // this.refreshTexts ++;
          return;
        }
        if (e.shiftKey) {
          pic.querySelector('div[alt="MARKER"]').click();
          return;
        }
      }
    }
    if (name) { //open
      await new Promise (z => setTimeout (z, 19)); // Just by suspicion
          // this.loli('show name: ' + name, 'color:red');
          // this.loli('show path: ' + path, 'color:red');
      // Set the actual picName, do not forget!
      this.picName = name;
      document.querySelector('.miniImgs.imgs').style.display = 'none'; //was 'flex'
      // Load the show image source path and set it's id="dname"
      let pic = document.querySelector('#link_show img');
      pic.src = 'rln' + path;
      // Copy the check mark class from the thumbnail
      let minipic = document.getElementById('i' + this.picName);
      let miniclass = minipic.querySelector('div[alt="MARKER"]').className;
      document.getElementById('markShow').className = miniclass + 'Show';
      // Copy display classes from the thumbnail
      let linkTexts = document.getElementById('link_texts');
      if (minipic.classList.contains('symlink')) {
        linkTexts.classList.add('symlink');
      } else {
        linkTexts.classList.remove('symlink');
      }
      if (minipic.classList.contains('hidden')) {
        linkTexts.classList.add('hidden');
      } else {
        linkTexts.classList.remove('hidden');
      }
      // Open the show image view
      document.querySelector('.img_show').style.display = 'table';
      // Hide the navigation overlay information
      document.querySelector('.toggleNavInfo').style.opacity = '0';

      // Copy the thumbnail menu
      let picture = document.getElementById('i' + this.picName);
      let menu = picture.querySelector('.menu_img_list');
      let element = document.getElementById('link_show');
      if (element.querySelector('.menu_img_list')) {
        element.querySelector('.menu_img_list').remove();
      }
      element.appendChild(menu.cloneNode(true));
      element.querySelector('.menu_img_list').style.display = '';

      // Show the right side buttons
      document.querySelector('.nav_links').style.display = '';
      // Hide the subalbums etc.
      document.querySelector('#smallButtons').style.display = 'none';
      document.querySelector('#upperButtons').style.display = 'none';
      document.querySelector('.albumsHdr').style.display = 'none';
      window.scrollTo(0,0);
    } else { //close
      this.edgeImage = '';
      // Hide the right side buttons
      document.querySelector('.nav_links').style.display = 'none';
      if (document.querySelector('.img_show').style.display === 'none') return;
      // Close the show image view
      document.querySelector('.img_show').style.display = 'none'; //was 'table'
      // Open the thumbnail view and update any selection mark changes
      document.querySelector('.miniImgs.imgs').style.display = 'flex';
      this.numMarked = document.querySelectorAll('.img_mini.selected').length;
      // Show the subalbums etc.
      document.querySelector('#smallButtons').style.display = '';
      document.querySelector('#upperButtons').style.display = '';
      document.querySelector('.albumsHdr').style.display = '';
      // Outline the closed image
      this.gotoMinipic(this.picName);
    }
  }

  // Show the next or previous slideshow image
  //#region showNext
  showNext = async (forward, e) => {
    // Here the image's invisible overlay is clicked: with Ctrl or Shift?
    // If so, other than next or previous image is demanded:
    if (e) {
      e.stopPropagation();
      if (e.button === 0) {
        if (e.ctrlKey) {
          let uli = document.querySelector('#link_show ul');
          if (uli.style.display === '') {
            uli.style.display = 'none';
          } else {
            uli.style.display = '';
          }
          return;
        }
        if (e.shiftKey) {
          document.getElementById('markShow').click();
          return;
        }
      }
    }
    var next, nextName;
    var actual = document.getElementById('i' + this.picName);
    var actualParent = actual.parentElement;
    var allFiles = this.allFiles;
    if (forward) {

      // Ensure that invisibles are skipped over
      while (actual.nextElementSibling && actual.nextElementSibling.classList.contains('invisible')) {
        actual = actual.nextElementSibling;
      }
      next = actual.nextElementSibling;

      if (next) {
        nextName = (next.id).slice(1);
      } else { // Go to the beginning
        next = actualParent.firstElementChild;

        // Ensure once again that invisibles are skipped over
        if (next && next.classList.contains('invisible')) {
          while (next.nextElementSibling && next.nextElementSibling.classList.contains('invisible')) {
            next = next.nextElementSibling;
          }
          next = next.nextElementSibling;
        }
        if (next) nextName = (next.id).slice(1);
      }

    } else { // backward

      // Ensure that invisibles are skipped over
      while (actual.previousElementSibling && actual.previousElementSibling.classList.contains('invisible')) {
        actual = actual.previousElementSibling;
      }
      next = actual.previousElementSibling;

      if (next) {
        nextName = (next.id).slice(1);
      } else { // Go to the beginning
        next = actualParent.lastElementChild;

        // Ensure once again that invisibles are skipped over
        if (next && next.classList.contains('invisible')) {
          while (next.previousElementSibling && next.previousElementSibling.classList.contains('invisible')) {
            next = next.previousElementSibling;
          }
          next = next.previousElementSibling;
        }
        if (next) nextName = (next.id).slice(1);
      }

    }

    if (nextName) {
      // console.log(allFiles);
      let i = allFiles.findIndex(all => {return all.name === nextName;});
      // this.loli('index=' + i);
      let path = '';
      if (i > -1) {
        this.picName = nextName;
        i = this.picIndex;
        path = allFiles[i].show;
        this.showImage(nextName, path);
      }
      // The order of 'allFiles' may not reflect DOM content which may be rearranged
      this.edgeImage = '';
      actual = document.querySelector('#i' + this.escapeDots(this.picName));
      if (!actual.nextElementSibling) this.edgeImage = this.intl.t('imageLast');
      if (!actual.previousElementSibling) this.edgeImage = this.intl.t('imageFirst');
    }
  }

  //#region COCKIES
  // Cookie names are mish_lang, mish_bkgr, ...
  setCookie = (cname, cvalue, exminutes) => {
    if (exminutes) {
      var d = new Date();
      d.setTime(d.getTime() + (exminutes*60000));
      var expires = "expires="+ d.toUTCString();
      document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/;SameSite=Lax";
    } else {
      document.cookie = cname + "=" + cvalue + ";path=/;SameSite=Lax";
    }
  }
  getCookie = (cname) => {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for(var i = 0; i <ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  }

  //   #region SERVER
  //== Server tasks







  //#region xhrsetreqhdr
  xhrSetRequestHeader = (xhr) => {
    xhr.setRequestHeader('username', encodeURIComponent(this.userName));
    xhr.setRequestHeader('imdbdir', encodeURIComponent(this.imdbDir));
    xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
    xhr.setRequestHeader('picfound', this.picFound); // All 'wihtin 255' characters
  }


  //#region execute
  execute = async (command) => { // Execute on the server, return a promise
    return new Promise((resolve, reject) => {
      command = command.replace (/%/g, "%25");
      var xhr = new XMLHttpRequest ();
      xhr.open ('GET', 'execute/', true, null, null);
      this.xhrSetRequestHeader(xhr);
      xhr.setRequestHeader('command', encodeURIComponent(command));
      xhr.onload = function () {
        if (this.status >= 200 && this.status < 300) {
          var data = xhr.response.trim ();
          resolve(data);
        } else {
          reject({
            status: this.status,
            statusText: xhr.statusText
          });
        }
      };
      xhr.onerror = function() {
        reject ({
          status: this.status,
          statusText: xhr.statusText
        });
      };
      xhr.send();
    });
  }

  //#region filestat
  // Get file information
  getFilestat = async (filePath) => {
    return new Promise(async (resolve, reject) => {
      var xhr = new XMLHttpRequest ();
      xhr.open ('GET', 'filestat/', true, null, null);
      this.xhrSetRequestHeader(xhr);
      xhr.setRequestHeader('path', encodeURIComponent(filePath));
      xhr.setRequestHeader('intlcode', encodeURIComponent(this.intlCodeCurr));
      xhr.onload = function() {
        if (this.status >= 200 && this.status < 300) {
          var data = xhr.response.trim();
          resolve(data);
        } else {
          reject({
            status: this.status,
            statusText: xhr.statusText
          });
        }
      };
      xhr.onerror = function() {
        reject ({
          status: this.status,
          statusText: xhr.statusText
        });
      };
      xhr.send();
    });
  }

  //#region login
  getCredentials = async (username) => {
    username = username.trim();
    // this.loli(this.userName);
    if (username === 'Get user name') { // Welcome, initiation
      username = this.userName; // Default log in
      this.imdbRoot = ''; // Empty it
    }
    if (username === 'Get allowances') username = ''; // For all users
    return new Promise((resolve, reject) => {
      // ===== XMLHttpRequest returning user credentials
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'login/', true, null, null);
      // Do not use xhrSetRequestHeader here, perhaps bad user name timing?
      xhr.setRequestHeader('username', encodeURIComponent(username));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.imdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'widhtin 255' characters
      xhr.onload = function() {
        let res = xhr.response;
        resolve(res);
      }
      xhr.onerror = function() {
        reject({
          status: this.status,
          statusText: xhr.statusText
        });
      }
      xhr.send();
    }).catch(error => {
      console.error(error.message);
    });
  }

  //#region rootdir
  getAlbumRoots = async () => {
    // Propose root directory (requestDirs)
    return new Promise ( (resolve, reject) => {
      var xhr = new XMLHttpRequest ();
      xhr.open ('GET', 'rootdir/', true, null, null);
      this.xhrSetRequestHeader(xhr);
      xhr.onload = function () {
        if (this.status >= 200 && this.status < 300) {
          var dirList = xhr.response;
          resolve (dirList);
        } else {
          reject ({
            status: this.status,
            statusText: xhr.statusText
          });
        }
      };
      xhr.onerror = function () {
        reject ({
          status: this.status,
          statusText: xhr.statusText
        });
      };
      xhr.send ();
    }).catch (error => {
      if (error.status !== 404) {
        console.error (error.message);
      } else {
        console.warn ("reqRoot: No NodeJS server");
      }
    });
  }

  //#region imdbdirs
  getAlbumDirs = async (getHidden) => {
    // Get album collections or albums if thisDir is an album root
    return new Promise((resolve, reject) => {
      // ===== XMLHttpRequest returning user credentials
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'imdbdirs/', true, null, null);
      this.xhrSetRequestHeader(xhr);
      xhr.setRequestHeader('hidden', getHidden ? 'true' : 'false');
      xhr.onload = function() {
        let res = xhr.response;
        resolve(res);
      }
      xhr.onerror = function() {
        reject({
          status: this.status,
          statusText: xhr.statusText
        });
      }
      xhr.send();
    }).catch(error => {
      console.error(error.message);
    });
  }

  //#region imagelist
  // WAS: requestNames = async () => { // ===== Request the file information list
  getImages = async () => { // ===== Get the image files information list
    // NEPF = number of entries (lines) per file in the plain text-line-result list
    // ('namedata') from the server. The main information (e.g. metadata) is retreived
    // from each image file. It is reordered into 'newdata' in 'sortnames' order, as
    // far as possible; 'sortnames' is cleaned from non-existent (removed) files and
    // extended with new (added) files, in order as is. So far, the sort order is
    // 'sortnames' with hideFlag (and albumIndex?)
    var that = this;
    return new Promise((resolve, reject) => {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'imagelist/', true, null, null);
      this.xhrSetRequestHeader(xhr);
      xhr.onload = function() {
        var allow = that.allow;
        var allfiles = [];
       if (this.status >= 200 && this.status < 300) {
          var NEPF = 7; // Number of rows per file in xhr.response
          var result = xhr.response;
          result = result.trim ().split (LF); // result is vectorised
          var i = 0, j = 0;
          var n_files = result.length/NEPF;
          if (n_files < 1) { // Covers all weird outcomes
            result = [];
            n_files = 0;
            that.numHidden = 0;
            that.numInvisible = 0;
            that.numMarked = 0;
            that.numShown = 0;
            // ///document.querySelectorAll("span.ifZero").style.display = 'hide';
            // document.querySelectorAll('#navKeys').text ('false');
            that.navKeys = false; // Protects from unintended use of L/R arrows
          }
          for (i=0; i<n_files; i++) {
            result [j + 4] = result [j + 4].replace (/&lt;br&gt;/g,'<br>'); // j + 5??
            var f = {
              orig: result[j],        // orig-file path (...jpg|tif|png|...)
              show: result[j + 1],    // show-file path (_show_...png)
              mini: result[j + 2],    // mini-file path (_mini_...png)
              name: result[j + 3],    // Orig-file base name without extension
              txt1: htmlSafe(result [j + 4]), // xmp.dc.description metadata
              txt2: htmlSafe(result [j + 5]), // xmp.dc.creator metadata
              symlink: result[j + 6], // & or else, the value for linkto
              linkto: '',             // which is set when reorganized below
              albname: ''             // "    (short name for symlink's original album)
            };
            if (f.txt1.toString() === "-") {f.txt1 = "";}
            if (f.txt2.toString() === "-") {f.txt2 = "";}

            // From the server: f.symlink=& for ordinary files, else it is the linked-to
            // relative file path. This is reorganized as follows:
            f.linkto = f.orig; // The real file path
            if (f.symlink === '&') {
              f.symlink = '';
            } else {
              let tmp = f.symlink;
              // HOW this missing slash?
              f.orig = '/' + tmp; // The actual path in this context
              f.symlink = 'symlink';
              tmp = tmp.replace(/^([.]*\/)+/, that.imdbRoot + "/").replace(/^([^/]*\/)*([^/]+)\/[^/]+$/, "$2");
              f.albname = that.removeUnderscore(tmp, true);
            }

            // // Explanations among printouts, the namings may seem weird - be careful!
            // let tmp = f.symlink ? f.symlink : 'ordinary';
            // that.loli(tmp, 'color:white');
            // // The real file reference, if symlink: it's resolution (from here):
            // that.loli('  reference (orig): ' + f.orig, 'color:brown');
            // // The real file path (root to be added),same as f.orig if ordinary:
            // that.loli(' formally (linkto): ' + f.linkto, 'color:orange');
            // // This file's real album's readable short name:
            // that.loli('in album (albname): ' + f.albname, 'color:yellow');

            j = j + NEPF;
            allfiles.push(f);
          }

          // ///document.querySelector(".showCount:first").style.display = '';
          document.querySelector(".miniImgs").style.display = '';
          if (n_files < 1) {
            document.querySelector("#toggleName").style.display = 'none';
            document.querySelector("#toggleHide").style.display = 'none';
          }
          else {
            document.querySelector("#toggleName").style.display = '';
            if (allow.imgHidden) document.querySelector("#toggleHide").style.display = '';
          }

          //userLog ('INFO received');
          resolve (allfiles); // Return file-list object array
        } else {
          reject ({
            status: this.status,
            statusText: xhr.statusText
          });
        }
      };
      xhr.onerror = function () {
        reject ({
          status: this.status,
          statusText: xhr.statusText
        });
      };
      xhr.send ();
    })
    .then ()
    .catch (error => {
      console.error ("In getImages:", error.message);
    });
  }

  //#region sortlist
  //is actually the getOrder function, cf. saveOrder below
  requestOrder = async () => {
    // Request the sort order list of image files
    return new Promise ( (resolve, reject) => {
      var xhr = new XMLHttpRequest ();
      xhr.open ('GET', 'sortlist/', true, null, null);
      this.xhrSetRequestHeader(xhr);
      xhr.onload = async function () {
        if (this.status >= 200 && this.status < 300) {
          var data = xhr.response.trim ();
          if (data.slice (0, 8) === '{"error"') {
            data = "Error!"; // This error text may also be generated elsewhere
          }
          resolve (data); // Return file-name text lines
          // console.log ("ORDER received");
        } else {
          resolve ("Error!");
          reject ({
            status: this.status,
            statusText: xhr.statusText
          });
        }
      };
      xhr.onerror = function () {
        resolve ("Error!");
        reject ({
          status: this.status,
          statusText: xhr.statusText
        });
      };
      xhr.send ();
    }).catch (error => {
      console.error (error.message);
    });
  }

  //#region saveorder
  //the name coincides with the saveOrder left button
  saveOrder = async () => {
    if (this.imdbDir === this.picFound || !this.allow.saveChanges) return;
    // assemble the new sortOrder list
    this.sortOrder = this.updateOrder();
    // then replace the order file in the album
    // document.getElementById("divDropZone").style.display = "none"; // If shown...
    var that = this;
    return new Promise( (resolve, reject) => {
      var xhr = new XMLHttpRequest();
      xhr.open('POST', 'saveorder/');
      this.xhrSetRequestHeader(xhr);
      xhr.onload = function() {
        if (this.status >= 200 && this.status < 300) {
          resolve(true); // Can we forget 'resolve'?
          that.alertMess(that.intl.t('saved'), 3);
        } else {
          reject({
            status: this.status,
            statusText: xhr.statusText
          });
        }
      };
      xhr.send(that.sortOrder);
    }).catch(error => {
      console.error(error.message);
    });
  }
  updateOrder = (noJoin) => {
    let old = this.sortOrder.split(LF);
    let name = [];
    for (let elem of document.querySelectorAll('div.img_mini')) {
      name.push(elem.id.slice(1));
    }
    var save = '§§';
    for (let i=0;i<name.length;i++) {
      for (var item of old) {
        if (item.startsWith(name[i] + ',')) {
          save = item;
          name[i] = item;
          break;
        }
      }
      if (name[i] !== save) name[i] += ',0,0';
    }
    if (noJoin) {
      return name;
    } else {
      return name.join(LF);
    }
  }

  //#region savetext
  //saving image captions as metadata: saveText(filePath +'\n'+ txt1 +'\n'+ txt2);
  placeMess = () => {
    let textel = document.getElementById('dialogText');
    let messel = document.getElementById('dialogAlert');
    messel.style.transform = textel.style.transform;
  }
  saveText = (txt) => {
    var that = this;
    var xhr = new XMLHttpRequest ();
    xhr.open ('POST', 'savetext/');
    this.xhrSetRequestHeader(xhr);
    xhr.onload = function () {
      if (xhr.response) {
          console.log(xhr.response);
        that.loli('Xmp.dc metadata not saved for ' + that.picName, 'color:red');
        let edpn = that.escapeDots(that.picName);
        document.querySelector('#i' + edpn + ' .img_txt1').innerHTML = '';
        document.querySelector('#i' + edpn + ' .img_txt2').innerHTML = '';
        let mess = that.intl.t('errTxtNotSaved') + '<br><br>';
        mess += that.intl.t('errTxtCannotSave') + '<br><br>';
        mess += that.intl.t('errTxtRecover');
        that.alertMess(mess, 0);
        that.placeMess();
      } else {
        that.loli('Xmp.dc metadata saved for ' + that.picName);
        let mess = that.intl.t('captionFor') + ' <b style="color:black">' + that.picName + '</b> ' + that.intl.t('captionSaved');
        that.alertMess(mess, 1.5);
        that.placeMess();
        // Not used since 'server savetxt/', that is, tne SERVER will do sqlUpdate:
        // that.sqlUpdate(txt.split(LF)[0]); ***CHECK, WHEN used?
      }
    }
    xhr.send(txt);
  }

  //#region sqlupdate
  // Update the sqlite text database (symlinked pictures auto-omitted)
  // ***CHECK if it ever will be used
  sqlUpdate = (picPaths) => { // Must be complete server paths
    if (!picPaths) return;
    let data = new FormData ();
    data.append ("filepaths", picPaths);
    return new Promise ( (resolve, reject) => {
      let xhr = new XMLHttpRequest ();
      xhr.open ('POST', 'sqlupdate/')
      this.xhrSetRequestHeader(xhr);
      xhr.onload = function () {
        resolve (xhr.response); // empty
      };
      xhr.onerror = function () {
        resolve (xhr.statusText);
        reject ({
          status: this.status,
          statusText: xhr.statusText
        });
      };
      xhr.send (data);
    });
  }


  //   #region MENUS
  //== Menu utilities

  openMainMenu = async (e) => {
    if (e) e.stopPropagation();
    var menuMain = document.getElementById('menuMain');
    var menuButton = document.getElementById('menuButton');
    menuMain.style.display = '';
    await new Promise (z => setTimeout (z, 9)); // slow response
    menuButton.innerHTML = '<span class="menu">×</span>';
    await new Promise (z => setTimeout (z, 9)); // slow response
    this.loli('opened main menu');
    return '';
  }

  closeMainMenu = async (msg) => {
    var menuMain = document.getElementById('menuMain');
    if (menuMain.style.display === 'none') return '';
    var menuButton = document.getElementById('menuButton');
    menuMain.style.display = 'none';
    await new Promise (z => setTimeout (z, 9)); // slow response
    menuButton.innerHTML = '<span class="menu">𝌆</span>';
    await new Promise (z => setTimeout (z, 9)); // slow response
    this.loli('closed main menu ' + msg);
    return '';
  }

  //   #region DIALOGS
  //== Dialog utilities for open/close/modal ...

  // Functions openDialog(id, op), toggleDialog(id, op), openModalDialog(id, op),
  // saveDialog(id), closeDialog(id), and saveCloseDialog(id) (= save then close),
  // where id = `dialogId` and op = 'original position'. If op is `true` then the dialog
  // is opened in the original position -- else opened where it was left at last close.
  // The close function may be modified to return to original position before closing.

  openDialog = (dialogId, origPos) => {
    let diaObj = document.getElementById(dialogId);
    if (!diaObj.open) {
      diaObj.show();
      if (origPos) diaObj.style = '';
      this.loli('opened ' + dialogId);
    }
  }

  toggleDialog = async (dialogId, origPos) => {
    let diaObj = document.getElementById(dialogId);
    let what = 'closed ';
    await new Promise (z => setTimeout (z, 20)); // toggleDialog
    if (diaObj.hasAttribute("open")) {
      diaObj.close();
    } else {
      what = 'opened ';
      await new Promise (z => setTimeout (z, 20)); // toggleDialog
      if (origPos) diaObj.style.display = '';
      diaObj.show();
    }
    this.loli(what + dialogId);
  }

  openModalDialog = (dialogId, origPos) => {
    let diaObj = document.getElementById(dialogId);
    if (!diaObj.open) {
      if (origPos) diaObj.style = '';
      diaObj.showModal();
      this.loli('opened ' + dialogId + ' (modal)');
    }
  }

  saveDialog = async (dialogId) => {
    // should have alternatives for any dialogId
    if (dialogId === 'dialogText' && this.picIndex > -1) {
      // Close any previous alert:
      this.closeDialog('dialogAlert');
      let f = this.allFiles[this.picIndex];
      let path = '';
      if (f.symlink) {
        path = f.orig; //** see below
          // this.loli(path, 'color:red');
      } else {
        path = f.linkto;
          // this.loli(path,'color:yellow');
      }
      let gif = /\.gif$/i.test(path);
      let txt1 = document.getElementById('dialogTextDescription').value;
      txt1 = this.normalize2br(txt1, true); // true: leave end untrimmed
        // this.loli(txt1,'color:yellow');
      this.allFiles[this.picIndex].txt1 = txt1;
      document.getElementById('dialogTextDescription').value = txt1.replace(/<br>/g, '\n');

      let  txt2 = document.getElementById('dialogTextCreator').value;
      txt2 = this.normalize2br(txt2); // also trim end
        // this.loli(txt2,'color:yellow');
      this.allFiles[this.picIndex].txt2 = txt2;
      document.getElementById('dialogTextCreator').value = txt2.replace(/<br>/g, '\n');

      // When the img_mini pictures are visible,
      if (document.querySelector('.miniImgs.imgs').style.display !== 'none') {
        // let size = this.albumAllImg(this.imdbDirs.indexOf(this.imdbDir));
        // await new Promise (z => setTimeout (z, size*6 + 10)); // album rerender
      } else { // else the img_show picture is visible
        document.querySelector('#link_texts .img_txt1').innerHTML = txt1;
        document.querySelector('#link_texts .img_txt2').innerHTML = txt2;
      }
      // console.log(this.allFiles[this.picIndex])
      this.refreshTexts ++; // Change trigger to rerender by RefreshThis
      let size = this.albumAllImg(this.imdbDirs.indexOf(this.imdbDir));
      await new Promise (z => setTimeout (z, size*6 + 10)); // album rerender
      this.paintHideFlags(); // AFTER RERENDER!
      this.paintViewImg();   // AFTER RERENDER!
      this.markBorders(this.picName);
      // Remove the initial '../..etc.' if 'path' is from 'f.orig' //**
      path = this.imdbRoot + path.replace(/^\.*(\/\.+)*/, '');
        // this.loli(path, 'color:red');
      if (!gif) {
        this.saveText(path + LF + txt1 + LF + txt2);
        // this.loli('saved ' + dialogId); // is confirmed by 'saveText'
        return;
      }
    }
  }

  closeDialog = (dialogId) => {
    let diaObj = document.getElementById(dialogId);
    if (diaObj && diaObj.open) {
      diaObj.close();
      this.loli('closed ' + dialogId);
    }
  }

  saveCloseDialog = (dialogId) => {
    this.saveDialog(dialogId);
    this.closeDialog(dialogId);
  }

  closeDialogs  = () => { // Close ALL <dialog>s!
    for (let diaObj of document.getElementsByTagName('dialog')) {
      if (diaObj.open) {
        diaObj.close();
        this.loli('closed ' + diaObj.id);
      }
    }
  }
}
//   #region END
//   #endregion
