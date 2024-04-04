//== Dialog open/toggle/modal, in original position if origpos is true.

// Should be imported as soon as a dialog is going to be opened and used. Contains:
// openDialog, toggleDialog, openModalDialog, saveDialog, closeDialog, saveCloseDialog;
// that is, openDialog(id, op), toggleDialog(id, op), openModalDialog(id, op),
// saveDialog(id), closeDialog(id, op), and saveCloseDialog(id) (= save then close),
// where id = `dialogId` and op = 'original position'. If op is `true` then the dialog
// is opened in the original position -- else opened where it was left at last close.

// import { loli } from './common-functions';

// export function openDialog(dialogId, origPos) {
//   let diaObj = document.getElementById(dialogId);
//   if (!diaObj.open) {
//     diaObj.show();
//     if (origPos) diaObj.style = '';
//     loli('opened ' + dialogId);
//   }
// }

// export function toggleDialog(dialogId, origPos) {
//   let diaObj = document.getElementById(dialogId);
//   let what = 'closed ';
//   if (diaObj.hasAttribute("open")) {
//     diaObj.close();
//   } else {
//     what = 'opened ';
//     if (origPos) diaObj.style = '';
//     diaObj.show();
//   }
//   loli(what + dialogId);
// }

// export function openModalDialog(dialogId, origPos) {
//   let diaObj = document.getElementById(dialogId);

//   if (!diaObj.open) {
//     if (origPos) diaObj.style = '';
//     diaObj.showModal();
//     loli('opened ' + dialogId + ' (modal)');
//   }
// }

// //== May also be used as dialog button functions:

// export function saveDialog(dialogId) {
//   loli('saved ' + dialogId);
// }

// export function saveCloseDialog(dialogId) {
//   saveDialog(dialogId);
//   closeDialog(dialogId);
// }

// export function closeDialog(dialogId) {
//   let diaObj = document.getElementById(dialogId);
//   if (diaObj.open) {
//     diaObj.close();
//     loli('closed ' + dialogId);
//   }
// }
