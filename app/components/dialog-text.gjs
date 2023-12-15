import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

import t from 'ember-intl/helpers/t';

import { imageId } from './welcome';


//== Dialogs with <dialog> tag

export const dialogTextId = 'dialogText';

export const DialogText = <template>
<div style="display:flex; align-items:center; justify-content:center; height:80%;">

<dialog id='dialogText'>
  <header data-dialog-draggable>
    <p>&nbsp;</p>
    <p>{{t 'dialog.text.header'}} <span>{{imageId}}</span></p>
    <button class="close" type="button" {{on 'click' (fn closeDialog dialogTextId)}}>×</button>
  </header>
    <main>
      <div class="diaMess">
        <div class="" style='padding:0.1em'>
          &nbsp;<b class='insertChar' {{on 'click' insert}}>’</b>
          &nbsp;<b class='insertChar' {{on 'click' insert}}>–</b>
          &nbsp;<b class='insertChar' {{on 'click' insert}}>×</b>
          &nbsp;<b class='insertChar' {{on 'click' insert}}>°</b>
          &nbsp;<b class='insertChar' {{on 'click' insert}}>—</b>
          &nbsp;<b class='insertChar' {{on 'click' insert}}>”</b>
        </div>
      </div>
      <textarea id="dialogTextDescription" name="description" rows="6" placeholder="{{t "write.description"}} (Xmp.dc.description)" {{on 'mouseleave' onMouseLeave}}></textarea><br>
      <!--textarea id="dialogTextDescription" name="description" rows="6" placeholder="Skriv bildtext: När var vad vilka (för Xmp.dc.description)" {{on 'mouseleave' onMouseLeave}}></textarea><br-->
      <textarea id="dialogTextCreator" name="creator" rows="1" placeholder="{{t "write.creator"}} (Xmp.dc.creator)" {{on 'mouseleave' onMouseLeave}}></textarea>
      <!--textarea id="dialogTextCreator" name="creator" rows="1" placeholder="Skriv ursprung: Foto upphov källa (för Xmp.dc.creator)" {{on 'mouseleave' onMouseLeave}}></textarea-->
    </main>
    <footer>
      <button id="dialogTextButton1" type="button" {{on 'click' (fn saveDialog dialogTextId)}}>{{t 'button.save'}}</button>&nbsp;
      <button id="dialogTextButton2" type="button" {{on 'click' (fn saveCloseDialog dialogTextId)}}>{{t 'button.saveclose'}}</button>&nbsp;
      <button id="dialogTextButton3" type="button" {{on 'click' (fn closeDialog dialogTextId)}}>{{t 'button.close'}}</button>&nbsp;
      <button id="dialogTextButton4" type="button" {{on 'click' (fn notesDialog 'dialogTextNotes')}}>{{t 'button.notes'}}</button>&nbsp;
      <button id="dialogTextButton5" type="button" {{on 'click' (fn keysDialog 'dialogTextKeywords')}}>{{t 'button.keywords'}}</button>&nbsp;
    </footer>
</dialog>

<dialog id='dialogTextNotes'>
  <header data-dialog-draggable>
    <p>&nbsp;</p>
    <p>Notes for <span>{{imageId}}</span></p>
    <button class="close" type="button" {{on 'click' (fn closeDialog 'dialogTextNotes')}}>×</button>
  </header>
  <main>
    <div class="diaMess">
      <div class="" style='padding:0.1em'>
        &nbsp;<b class='insertChar' {{on 'click' insert}}>’</b>
        &nbsp;<b class='insertChar' {{on 'click' insert}}>–</b>
        &nbsp;<b class='insertChar' {{on 'click' insert}}>×</b>
        &nbsp;<b class='insertChar' {{on 'click' insert}}>°</b>
        &nbsp;<b class='insertChar' {{on 'click' insert}}>—</b>
        &nbsp;<b class='insertChar' {{on 'click' insert}}>”</b>
      </div>
    </div>
    <textarea id="dialogTextInfo" name="description" rows="8" placeholder="{{t 'write.notes'}} (Xmp.dc.source)" {{on 'mouseleave' onMouseLeave}}></textarea><br>
  </main>
  <footer>
    <button type="button" {{on 'click' (fn saveDialog 'dialogTextNotes')}}>Save</button>&nbsp;
    <button type="button" {{on 'click' (fn saveCloseDialog 'dialogTextNotes')}}>Save and close</button>&nbsp;
    <button type="button" {{on 'click' (fn closeDialog 'dialogTextNotes')}}>Close</button>
  </footer>
</dialog>

<!-- Temporary special styling 1 in this dialog -->
<dialog id="dialogTextKeywords" style="width:max(20%, 20rem)">
  <header data-dialog-draggable>
    <p>&nbsp;</p>
    <p>Keywords for <span>{{imageId}}</span></p>
    <button class="close" type="button" {{on 'click' (fn closeDialog 'dialogTextKeywords')}}>×</button>
  </header>
  <!-- Temporary special styling 2 in this dialog -->
  <main style="padding:0.5rem;text-align:center">
    <div class="diaMess">
      {{t 'write.keywords'}}
    </div>
  </main>
  <footer>
    <button type="button" {{on 'click' (fn closeDialog 'dialogTextKeywords')}}>Ok</button>&nbsp;
  </footer>
</dialog>

</div>
</template>


//== Dialog open/toggle

export function openDialog(dialogTextId, origPos) {
  let diaObj = document.getElementById(dialogTextId);

  diaObj.show();
  if (origPos) diaObj.style = '';
  // eslint-disable-next-line no-console
  console.log(dialogTextId + ' opened');
}

export function toggleDialog(dialogTextId, origPos) {
  let diaObj = document.getElementById(dialogTextId);
  let what = ' closed';

  if (diaObj.hasAttribute("open")) {
    diaObj.close();
  } else {
    what = ' opened';
    if (origPos) diaObj.style = '';
    diaObj.show();
  }

  // eslint-disable-next-line no-console
  console.log(dialogTextId + what);
}


//== Open modal dialog function, also a dialog button function

export function openModalDialog(dialogTextId, origPos) {
  let diaObj = document.getElementById(dialogTextId);

  if (!diaObj.open) {
    if (origPos) diaObj.style = '';
    diaObj.showModal();
    // eslint-disable-next-line no-console
    console.log(dialogTextId + ' opened (modal)');
  }
}


//== Dialog button functions

function saveDialog(dialogTextId) {
  // eslint-disable-next-line no-console
  console.log(dialogTextId + ' image text(s) saved');
}

function saveCloseDialog(dialogTextId) {
  saveDialog(dialogTextId);
  closeDialog(dialogTextId);
}

function closeDialog(dialogTextId) {
  document.getElementById(dialogTextId).close();
  // eslint-disable-next-line no-console
  console.log(dialogTextId + ' closed');
}

function notesDialog(dialogTextId) {
  // eslint-disable-next-line no-console
  console.log('The Notes modal for ' + imageId + ' to be opened');
  openModalDialog(dialogTextId, 0);
}

function keysDialog(dialogTextId) {
  // eslint-disable-next-line no-console
  console.log('The Keywords modal for ' + imageId + ' to be opened');
  openModalDialog(dialogTextId, 0);
}


//== Detect closing Esc key

document.addEventListener ('keydown', detectEsc, false);

async function detectEsc(e) {
  if (e.keyCode === 27) { // Esc key
    let tmp1 = document.getElementById('dialogTextNotes');
    let tmp2 = document.getElementById('dialogTextKeywords');

    if (tmp1.open) {
      closeDialog(tmp1.id);
      await new Promise (z => setTimeout (z, 5)); // Allow next
      openModalDialog(dialogTextId, 0); // Close of modal closes parent
    } else if (tmp2.open) {
      closeDialog(tmp2.id);
      await new Promise (z => setTimeout (z, 5)); // Allow next
      openModalDialog(dialogTextId, 0); // Close of modal closes parent
    } else {
      closeDialog(dialogTextId);
    }
  }
}

//== Detect closing click outside modal dialog

document.addEventListener ('click', detectClickOutside, false);

function detectClickOutside(e) {
  let tgt = e.target.id;

  if (tgt === dialogTextId || tgt === 'dialogTextNotes' || tgt === 'dialogTextKeywords') { // Outside a modal dialog, else not!
    closeDialog(tgt);
  }
}


//== Insert from virtual minikeyboard

var textArea = '';
var insertInto = '';

function onMouseLeave(/*e*/) {
  //textArea = e.target;
  textArea = document.activeElement;
  insertInto = textArea.id;
}

function insert(e) {
  if (!insertInto) return;

  textArea = document.getElementById(insertInto);

  let textValue = textArea.value;

  if (textValue === undefined) return;

  let beforeInsert = textValue.substring(
    0, textArea.selectionStart);
  let afterInsert = textValue.substring(
    textArea.selectionStart, textArea.length); // thus avoid delete any selected, cannot undo!
  // let afterInsert = textValue.substring(
  //   textArea.selectionEnd, textArea.length);
  // selectedText = textValue.substring(
  //   textArea.selectionStart, textArea.selectionEnd);

  beforeInsert += e.target.innerHTML;
  textValue = beforeInsert + afterInsert;
  document.getElementById(insertInto).value = textValue;
  document.getElementById(insertInto).focus();

  let i = beforeInsert.length;

  if (textArea.setSelectionRange) { // avoid error e.g. after save
    textArea.setSelectionRange(i, i);
    beforeInsert = textValue.substring(
      0, textArea.selectionStart);
    afterInsert = textValue.substring(
      textArea.selectionEnd, textArea.length);
  }
}
