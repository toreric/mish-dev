import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

let rnd = "." + Math.random().toString(36).substring(2,6);

export default class CommonStorageService extends Service {

  @tracked bkgrColor = '#cbcbcb';
  @tracked credentials = '';
  @tracked imageId = 'IMG_1234a_2023_november_19';
  @tracked imdbDir = "/album";
  @tracked imdbRoot = "MISH";
  @tracked picFound = "Funna_bilder" + rnd;
  @tracked credentials = '';
  @tracked userName = 'viewer';

  loli = (text) => { // loli = log list
    console.log(this.userName + ':', text);
  }

  // detectEsc = (e) => {
  //   if (e.keyCode === 27) { // Esc key
  //     if (document.getElementById("menuMain").style.display !== "none") this.toggleMainMenu();
  //   }
  // }

  toggleMainMenu = () => {
    var menuMain = document.getElementById("menuMain");
    if (menuMain.style.display === "none") {
      menuMain.style.display = "";
      this.loli('opened main menu');
    } else {
      menuMain.style.display = "none";
      this.loli('closed main menu');
    }
  }

 //== Dialog methods
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

  //== May also be used in the buttons of the dialogs:

  saveDialog = (dialogId) => {
    this.loli('saved ' + dialogId);
  }

  saveCloseDialog = (dialogId) => {
    saveDialog(dialogId);
    closeDialog(dialogId);
  }

  closeDialog = (dialogId) => {
    let diaObj = document.getElementById(dialogId);
    if (diaObj.open) {
      diaObj.close();
      this.loli('closed ' + dialogId);
    }
  }

}