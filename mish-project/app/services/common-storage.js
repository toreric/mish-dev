//== Mish common storage service with global properties/methods

import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';

export default class CommonStorageService extends Service {
  @service intl;

  @tracked  bkgrColor = '#cbcbcb'; //common background color
  @tracked  credentials = ''; //user credentials \n-string
  @tracked  freeUsers = 'guest...';
  @tracked  imdbDir = "/album";
  @tracked  imdbRoot = "MISH";
  @tracked  imdbRoots = ['root1', 'root2', 'root3'];
            picFoundBaseName = this.intl.t('picfound');
            // The 'found-pics' temporary catalog name is amended with a random 4-code:
            picFound = this.picFoundBaseName +"."+ Math.random().toString(36).substring(2,6);
  @tracked  picName = 'IMG_1234a_2023_november_19'; //current image name
  @tracked  userName = this.intl.t('guest');
  @tracked  userStatus = '';

  loli = (text) => { // loli = log list
    console.log(this.userName + ':', text);
  }

  getCredentials = async (username) => {
    // await new Promise (z => setTimeout (z, 999));
    username = username.trim();
    // this.loli(this.userName);
    if (username === 'Get user name') username = this.userName; // Welcome, initiation
    // this.loli(username + ' (parameter)');
    if (username === 'Get allowances') username = '';
    return new Promise((resolve, reject) => {
      // ===== XMLHttpRequest returning user credentials
      // console.log(username + ' (parameter, Promise)');
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'login', true, null, null);
      xhr.setRequestHeader('username', encodeURIComponent(username));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.mdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'wihtin 255' characters
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

  //#region Allowance
  //== Allowances properties/methods

  // allowvalue is the source of the 'allow' property values, reset at login
  @tracked allowvalue = "0".repeat (this.allowance.length);

  // Information text retreived from the _imdb_settings.sqlite datbase at login
  @tracked allowances = '';

  zeroSet = () => { // Will this be needed any more?
    this.allowValue = ('0'.repeat (this.allowance.length));
  }

  allow = {};

  allowance = [     //  'allow' order
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
  allowText = [ // Ordered as 'allow', IMPORTANT!
    'adminAll: ' + this.intl.t('adminAll'),
    'albumEdit: ' + this.intl.t('albumEdit'),
    'appendixEdit: ' + this.intl.t('appendixEdit'),
    'appendixView: ' + this.intl.t('appendixView'),
    'delcreLink: ' + this.intl.t('delcreLink'),
    'deleteImg: ' + this.intl.t('deleteImg'),
    'imgEdit: ' + this.intl.t('imgEdit'),
    'imgHidden: ' + this.intl.t('imgHidden'),
    'imgOriginal: ' + this.intl.t('imgOriginal'),
    'imgReorder: ' + this.intl.t('imgReorder'),
    'imgUpload: ' + this.intl.t('imgUpload'),
    'notesEdit: ' + this.intl.t('notesEdit'),
    'notesView: ' + this.intl.t('notesView'),
    'saveChanges: ' + this.intl.t('saveChanges'),
    'setSetting: ' + this.intl.t('setSetting'),
    'textEdit: ' + this.intl.t('textEdit'),
  ];

  allowFunc = () => { // Called from Welcome   after login
    var allow = this.allow;
    var allowance = this.allowance;
    var allowvalue = this.allowvalue;
    for (var i=0; i<allowance.length; i++) {
      allow [allowance [i]] = Number (allowvalue [i]);
    }
    if (allow.deleteImg) {  // NOTE *  If ...
      allow.delcreLink = 1; // NOTE *  then set this too
      i = allowance.indexOf ("delcreLink");
      // Also set the source value (in this way since allowvalue [i] = "1" in't allowed: compiler error: "4 is read-only" if 4 = the index value)
      allowvalue = allowvalue.slice (0, i - allowvalue.length) + "1" + allowvalue.slice (i + 1 - allowvalue.length);
    }
    if (allow.notesEdit) { // NOTE *  If ...
      allow.notesView = 1; // NOTE *  then set this too
      i = allowance.indexOf ("notesView");
      allowvalue = allowvalue.slice (0, i - allowvalue.length) + "1" + allowvalue.slice (i + 1 - allowvalue.length);
    }
    // Hide smallbuttons we don't need:
    if (allow.adminAll || allow.saveChanges) {
      document.getElementById('saveOrder').style.display = '';
    } else { // Any user may reorder but not save
      document.getElementById('saveOrder').style.display = 'none';
    }
    this.allow = allow;
    this.allowance = allowance;
    this.allowvalue = allowvalue;
  }

  //#region Menus
  //== Menu properties/methods

  toggleMainMenu = async () => {
    var menuMain = document.getElementById("menuMain");
    var menuButton = document.getElementById("menuButton");
    if (menuMain.style.display === "none") {
      menuMain.style.display = "";
      await new Promise (z => setTimeout (z, 9));
      menuButton.innerHTML = '<span class="menu">×</span>';
      await new Promise (z => setTimeout (z, 9));
      this.loli('opened main menu');
    } else {
      menuMain.style.display = "none";
      await new Promise (z => setTimeout (z, 9));
      menuButton.innerHTML = '<span class="menu">☰</span>';
      await new Promise (z => setTimeout (z, 9));
      this.loli('closed main menu');
    }
  }

  //#region Dialogs
  //== Dialog open/close/modal properties/methods

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
      if (origPos) diaObj.style = '';
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
  //#endregion
}
