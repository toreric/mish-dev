//== Dialog open/toggle/modal, in original position if origpos is true.

// Should be imported as soon as a dialog is going to be opened and used. Contains:
// openDialog, toggleDialo, openModalDialog, saveDialog, closeDialog, saveCloseDialog;
// that is, openDialog(id, op), toggleDialog(id, op), openModalDialog(id, op),
// saveDialog(id), closeDialog(id), and saveCloseDialog(id) (= save then close),
// where id = `dialogId` and op = 'original position'. If op is true then it is
// opened in the original position -- else where it was left at last close.

export function openDialog(dialogId, origPos) {
  let diaObj = document.getElementById(dialogId);

  diaObj.show();
  if (origPos) diaObj.style = '';
  // eslint-disable-next-line no-console
  console.log(dialogId + ' opened');
}

export function toggleDialog(dialogId, origPos) {
  let diaObj = document.getElementById(dialogId);
  let what = ' closed';

  if (diaObj.hasAttribute("open")) {
    diaObj.close();
  } else {
    what = ' opened';
    if (origPos) diaObj.style = '';
    diaObj.show();
  }

  // eslint-disable-next-line no-console
  console.log(dialogId + what);
}

export function openModalDialog(dialogId, origPos) {
  let diaObj = document.getElementById(dialogId);

  if (!diaObj.open) {
    if (origPos) diaObj.style = '';
    diaObj.showModal();
    // eslint-disable-next-line no-console
    console.log(dialogId + ' opened (modal)');
  }
}

//== May also be used as dialog button functions:

export function saveDialog(dialogId) {
  // eslint-disable-next-line no-console
  console.log(dialogId + ' image text(s) saved');
}

export function saveCloseDialog(dialogId) {
  saveDialog(dialogId);
  closeDialog(dialogId);
}

export function closeDialog(dialogId) {
  document.getElementById(dialogId).close();
  // eslint-disable-next-line no-console
  console.log(dialogId + ' closed');
}
