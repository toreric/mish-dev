//== Mish common storage service with global properties/methods

import Service from '@ember/service';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { htmlSafe } from '@ember/template';

export default class CommonStorageService extends Service {
  @service intl;

  //   #region Variables
  //== Significant Mish system global variables

  @tracked  bkgrColor = '#111';     //default background color
  @tracked  credentials = '';       //user credentials: \n-string from db
        get defaultUserName() { return `${this.intl.t('guest')}`; }
  @tracked  freeUsers = 'guest...'; //user names without passwords (set by DialogLogin)
  @tracked  imdbCoco = '';          //content counters etc. for imdbDirs (*)
  @tracked  albumHistory = [0];     //album index visit history
  @tracked  imdbDir = '';           //actual/current (sub)album directory (server IMDB_DIR)
  @tracked  imdbDirIndex = 0;       //actual/current (sub)album directory index
        get imdbDirName() {
              if (this.imdbRoot) {
                return (this.imdbRoot + this.imdbDir).replace(/^(.*\/)*([^/]+)$/, '$2').replace(/_/g, '&nbsp;');
              } else {
                return '';
              }
            }
  @tracked  imdbDirs = [''];        //available album directories at imdbRoot
  @tracked  imdbLabels = [''];      //thumbnail labels for imdbDirs (paths)
  @tracked  imdbPath = '';          //userDir+imdbRoot = absolut path to album root
  @tracked  imdbRoot = '';          //chosen album root directory (collection)
        get imdbRootsPrep() { return `${this.intl.t('reloadApp')}`; } // advice!
  @tracked  imdbRoots = [this.imdbRootsPrep]; //avalable album root directories
  @tracked  imdbTree = null;                  //will have the imdbDirs object tree
  @tracked  infoHeader = 'Header text';       //for information dialog
  @tracked  infoMessage = 'No information';   //for information dialog
        get intlCode() { return `${this.intl.t('intlcode')}`; }
  @tracked  intlCodeCurr = this.intlCode;     // language code
        get picFoundBaseName() { return `${this.intl.t('picfound')}`; }
  // The found pics temporary catalog name is amended with a random 4-code:
  @tracked  picFound = this.picFoundBaseName +"."+ Math.random().toString(36).substring(2,6);
  @tracked  picName = 'IMG_1234a2023_nov_19'; //actual/current image name
  @tracked  subColor = '#aef'; //subalbum legends
        get subaIndex() {
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
  @tracked  textColor = '#fff';               //default text color
  @tracked  userDir = '/path/to/albums';      //maybe your home dir., server start argument!
  @tracked  userName = this.defaultUserName;  // May be changed in other ways (e.g. logins)
  @tracked  userStatus = '';
  // (*) imdbCoco format is "(<npics>[+<nlinked>]) [<nsubdirs>] [<flag>]"
  // where <npics> = images, <nlinks> = linked images, <nsubdirs> = subalums,
  // and <flag> is empty or "*". The <flag> indicates a hidden album,
  // which needs permission for access

  //   #region View vars.
  //== Miniature and show images etc. information

  @tracked  navKeys = false; // Protects from unintended use of L/R arrows
  @tracked  allFiles = [];

  @tracked  numHidden = ' 0';
  @tracked  numMarked = '0';
  @tracked  numShown = ' 0';
  @tracked  b = '';
  @tracked  c = '';
  @tracked  d = '';
  @tracked  e = '';


  //   #region Allowance
  //== Allowances variables/properties/methods

  // allowvalue is the source of the 'allow' property values, reset at login
  @tracked allowvalue = "0".repeat (this.allowance.length);

  // Infotext retreived from _imdb_settings.sqlite datbase in dialog-login
  @tracked allowances = '';

  // zeroSet = () => { // Will this be needed any more?
  //   this.allowvalue = ('0'.repeat (this.allowance.length));
  // }

  @tracked allow = {};

  @tracked allowance = [     //  'allow' order
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

  // allowText = [ // IMPORTANT: Ordered as 'allow'z!
  get allowText() { return [
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
      // Also set the source value (in this way since allowvalue[i] = "1" in't allowed: compiler error: "4 is read-only" if 4 = the index value)
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

  //   #region Utilities
  //== Other service functions

  // Disable browser back button, go instead to most recent visited album
  initBrowser = async () => {
    // Refresh the setting, it may be lost!
    while (this.bkgrColor) { // Intended eternal loop
      window.history.pushState (null, "");
      window.onpopstate = () => {
        this.goBack();
      }
      await new Promise (z => setTimeout (z, 10000)); // Wait some seconds
    }
  }

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

  openAlbum = async (i) => {
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
    // Set color mark on the selected album and make it visible
    document.querySelector('span.album.a' + i).style.color = '#f46aff';
    let selected = document.querySelector('div.album.a' + i);
    selected.style.display = '';
    // Check that all parents are visible too
    while (selected.parentElement.classList.contains('album')) {
      selected = selected.parentElement;
      if (selected.nodeName !== 'DIV') break;
      selected.style.display = '';
    }

    document.querySelector('img.spinner').style.display = '';
    this.allFiles = await this.getImages();
    document.querySelector('img.spinner').style.display = 'none';

    this.loli(this.allFiles, 'color:lightgreen');
    console.log(this.allFiles);
    document.getElementById('loadMiniImages').click();
  }

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
    for (let a of document.querySelectorAll('.sameBackground')) a.style.background = this.bkgrColor;
    for (let a of document.querySelectorAll('.sameBackground')) a.style.color = this.textColor;
}

  loli = (text, style) => { // loli = log list with user name
    console.log(this.userName + ': %c' + text, style);
  }

  alertMess = async (mess, hdr) => {
    this.infoHeader = this.intl.t('infoHeader'); // default header
    if (hdr) this.infoHeader = hdr;
    this.infoMessage = mess;
    this.openDialog('dialogAlert');
    // this.openModalDialog('dialogAlert');
  }

  totalNumber = () => { // of original images
    let n = 0;
    let c = this.imdbCoco;
    for (let i=0;i<c.length;i++) {
      n += Number(c[i].replace(/^[^(]*\(([0-9]+).*$/, '$1'));
    }
    return n.toString();
  }

  removeUnderscore = (textString, noHTML) => {
    return textString.replace (/_/g, noHTML ? " " : "&nbsp;");
  }

  //#region cookies
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

  //   #region Server
  //== Server tasks








  //#region login
  getCredentials = async (username) => {
    username = username.trim();
    // this.loli(this.userName);
    if (username === 'Get user name') { // Welcome, initiation
      username = this.userName; // Default log in
      // this.imdbDir = '';  // Empty it
      this.imdbRoot = ''; // Empty it
    }
    // this.loli(username + ' (parameter)');
    if (username === 'Get allowances') username = '';
    return new Promise((resolve, reject) => {
      // ===== XMLHttpRequest returning user credentials
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'login/', true, null, null);
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
      xhr.setRequestHeader('username', encodeURIComponent(this.userName));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.imdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'wihtin 255' characters
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
      xhr.setRequestHeader('username', encodeURIComponent(this.userName));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.imdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'wihtin 255' characters
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
      xhr.setRequestHeader('username', encodeURIComponent(this.userName));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.imdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'widhtin 255' characters
      xhr.onload = function() {
        var allow = that.allow;
        var allfiles = [];
        console.log('ALLFILES 0');
        console.log(allfiles);
        that.loli(allfiles, 'color:yellow');
        if (this.status >= 200 && this.status < 300) {
          var NEPF = 7; // Number of rows per file in xhr.response
          var result = xhr.response;
          result = result.trim ().split ('\n'); // result is vectorised
          var i = 0, j = 0;
          var n_files = result.length/NEPF;
          if (n_files < 1) { // Covers all weird outcomes
            console.log('ALLFILES 1');
            result = [];
            n_files = 0;
            // document.querySelectorAll('.showCount .numShown').innerHTML(' 0');
            // document.querySelectorAll('.showCount .numHidden').innerHTML(' 0');
            // document.querySelectorAll('.showCount .numMarked').innerHTML('0');
            that.numShown = ' 0';
            that.numHidden = ' 0';
            that.numMarked = '0';
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
              f.orig = tmp; // The actual path in this context
              f.symlink = 'symlink';
              tmp = tmp.replace(/^([.]*\/)+/, that.imdbRoot + "/").replace(/^([^/]*\/)*([^/]+)\/[^/]+$/, "$2");
              f.albname = that.removeUnderscore(tmp, true);
            }

            // Explanations among printouts, the namings may seem weird!
            let tmp = f.symlink ? f.symlink : 'ordinary';
            that.loli(tmp, 'color:white');
            // The real file reference, if symlink: it's resolution (from here):
            that.loli('  reference (orig): ' + f.orig, 'color:brown');
            // The real file path (root to be added),same as f.orig if ordinary:
            that.loli(' formally (linkto): ' + f.linkto, 'color:orange');
            // This file's real album's readable short name:
            that.loli('in album (albname): ' + f.albname, 'color:yellow');

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
          console.log('ALLFILES 2');
          console.log(allfiles);
          that.loli(allfiles, 'color:yellow');
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

  //   #region Menus
  //== Menu utilities

  openMainMenu = async () => {
    var menuMain = document.getElementById("menuMain");
    var menuButton = document.getElementById("menuButton");
    menuMain.style.display = '';
    await new Promise (z => setTimeout (z, 9)); // slow response
    await new Promise (z => setTimeout (z, 9)); // slow response
    menuButton.innerHTML = '<span class="menu">×</span>';
    this.loli('opened main menu');
    return '';
  }

  closeMainMenu = async (p) => {
    var menuMain = document.getElementById("menuMain");
    var menuButton = document.getElementById("menuButton");
    menuMain.style.display = 'none';
    await new Promise (z => setTimeout (z, 9)); // slow response
    menuButton.innerHTML = '<span class="menu">☰</span>';
    await new Promise (z => setTimeout (z, 9)); // slow response
    this.loli('closed main menu, ' + p);
    return '';
  }

  //   #region Dialogs
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

  toggleDialog = (dialogId, origPos) => {
    let diaObj = document.getElementById(dialogId);
    let what = 'closed ';
    if (diaObj.hasAttribute("open")) {
      diaObj.close();
    } else {
      what = 'opened ';
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

  saveDialog = (dialogId) => {
    // save code here, to do!
    // needs alternatives for any dialogId
    this.loli('saved ' + dialogId);
  }

  closeDialog = (dialogId) => {
    let diaObj = document.getElementById(dialogId);
    if (diaObj.open) {
      diaObj.close();
      this.loli('closed ' + dialogId);
    }
  }

  saveCloseDialog = (dialogId) => {
    this.saveDialog(dialogId);
    this.closeDialog(dialogId);
  }

}
//   #region End
//   #endregion
