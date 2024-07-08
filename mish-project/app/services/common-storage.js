//== Mish common storage service with global properties/methods

import Service from '@ember/service';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

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
  @tracked  imdbDir = '';           //actual/current (sub)album directory
  @tracked  imdbDirIndex = 0;       //actual/current (sub)album directory index
        get imdbDirName() {
              if (this.imdbDir) {
                return this.imdbDir.replace(/^(.*\/)*([^/]+)$/, '$2').replace(/_/g, '&nbsp;');
              } else {
                return '';
              }
            }
  @tracked  imdbDirs = '';          //available album directories at imdbRoot
  @tracked  imdbLabels = '';        //thumbnail labels for imdbDirs
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
  @tracked  subColor = '#06f  '; //subalbum legends
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

    //   #region Allowance
  //== Allowances properties/methods

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
    "textEdit"      // +  " edit image texts (metadata)
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

  allowFunc = () => { // Called from Welcome after login
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

  openAlbum = (i) => {
    i = Number(i); // important!
    this.imdbDir = this.imdbDirs[i];
    this.imdbDirIndex = i;
    let h = this.albumHistory;
    if (h.length > 0 && h[h.length - 1] !== i) this.albumHistory.push(i);
    this.loli('opened album ' + i + ' ' + this.imdbDir, 'color:lightgreen' );
    // Reset color
    for (let tmp of document.querySelectorAll('span.album')) {
      tmp.style.color = '';
    }
    document.querySelector('span.album.a' + i).style.color = '#f46aff';
    let selected = document.querySelector('div.album.a' + i);
    selected.style.display = '';
    // Check that all parents are visible too
    while (selected.parentElement.classList.contains('album')) {
      selected = selected.parentElement;
      if (selected.nodeName !== 'DIV') break;
      selected.style.display = '';
    }
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
  }

  loli = (text, style) => { // loli = log list with user name
    console.log(this.userName + ': %c' + text, style);
  }

  alertMess = (mess, hdr) => {
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

  getAlbumRoots = async () => {
    // Propose root directory (requestDirs)
    return new Promise ( (resolve, reject) => {
      var xhr = new XMLHttpRequest ();
      xhr.open ('GET', 'rootdir/', true, null, null);
      xhr.setRequestHeader('username', encodeURIComponent(this.username));
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

  getAlbumDirs = async (hidden) => {
    // Get album collections or albums if thisDir is an album root
    return new Promise((resolve, reject) => {
      // ===== XMLHttpRequest returning user credentials
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'imdbdirs/', true, null, null);
      xhr.setRequestHeader('username', encodeURIComponent(this.username));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.imdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'wihtin 255' characters
      xhr.setRequestHeader('hidden', hidden ? 'true' : 'false');
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

  //   #region Menus
  //== Menu utilities

  toggleMainMenu = async () => {
    var menuMain = document.getElementById("menuMain");
    var menuButton = document.getElementById("menuButton");
    if (menuMain.style.display === "none") {
      menuMain.style.display = "";
      await new Promise (z => setTimeout (z, 9)); // slow response
      menuButton.innerHTML = '<span class="menu">×</span>';
      await new Promise (z => setTimeout (z, 9)); // slow response
      this.loli('opened main menu');
    } else {
      menuMain.style.display = "none";
      await new Promise (z => setTimeout (z, 9)); // slow response
      menuButton.innerHTML = '<span class="menu">☰</span>';
      await new Promise (z => setTimeout (z, 9)); // slow response
      this.loli('closed main menu');
    }
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
    this.loli(dialogId);
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
