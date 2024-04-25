//== Mish common storage service with global properties/methods

import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';

export default class CommonStorageService extends Service {
  @service intl;

  @tracked allowvalue; //the source of the 'allow' property values
  @tracked bkgrColor = '#cbcbcb'; //common background color
  @tracked credentials = ''; //user credentials \n-string
  @tracked imdbDir = "/album";
  @tracked imdbRoot = "MISH";
  @tracked imdbRoots = ['root1', 'root2', 'root3'];
  /*!trk*/ picFound = "Funna_bilder." + Math.random().toString(36).substring(2,6); //found pics
  @tracked picName = 'IMG_1234a_2023_november_19'; //current image name
  @tracked userName = this.intl.t('guest');
  @tracked userStatus = '';

  loli = (text) => { // loli = log list
    console.log(this.userName + ':', text);
  }

  getCredentials = async (username) => {
    if (!username) username = this.userName;
    return new Promise((resolve, reject) => {
      // ===== XMLHttpRequest checking 'usr'
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'login', true, null, null);
      // setReqHdr(xhr, 999);
      xhr.setRequestHeader('username', encodeURIComponent(username));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.mdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'wihtin 255' characters
      xhr.onload = function() {
        let res = xhr.response.split('/n');
        this.userStatus = res[1];
        resolve(xhr.response);
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
  //== Dialog properties/methods
  // openDialog(id, op), toggleDialog(id, op), openModalDialog(id, op),
  // saveDialog(id), closeDialog(id, op), and saveCloseDialog(id) (= save then close),
  // where id = `dialogId` and op = 'original position'. If op is `true` then the dialog
  // is opened in the original position -- else opened where it was left at last close.

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

  //#region Buttons
  //== May also be used in the buttons of the dialogs:

  saveDialog = (dialogId) => {
    // save code here
    this.loli('saved ' + dialogId);
  }

  saveCloseDialog = (dialogId) => {
    this.saveDialog(dialogId);
    this.closeDialog(dialogId);
  }

  closeDialog = (dialogId) => {
    let diaObj = document.getElementById(dialogId);
    if (diaObj.open) {
      diaObj.close();
      this.loli('closed ' + dialogId);
    }
  }
  //#endregion
}
