// eslint-disable-next-line no-unused-vars
import Component from '@glimmer/component';
// eslint-disable-next-line no-unused-vars
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

import { makeDialogDraggable } from 'dialog-draggable';
//import focusTrap from 'ember-focus-trap/modifiers/focus-trap';
// eslint-disable-next-line no-unused-vars
import { Modal } from 'ember-primitives';
import { cell } from 'ember-resources';

import { Clock } from './clock';
import { Excite } from './excite';

// eslint-disable-next-line no-unused-vars
const returnValue = cell('');

makeDialogDraggable();

const Welcome = <template>
  <Header />
  <DialogText />
</template>;

export default Welcome;

const Header = <template>
  <h1>Welcome to Mish, Polaris revision</h1>
  <Excite />
  <p>The time is <span>{{Clock}}</span></p>
  <p><button type="button" {{on 'click' (fn openDialog dialogId 0)}}>Open text dialog</button><button type="button" {{on 'click' (fn openDialog dialogId 1)}}>... in original position</button>
  &nbsp;
  <button type="button" {{on 'click' (fn toggleDialog dialogId 1)}}>Toggle text dialog</button>
  &nbsp;
  <button type="button" {{on 'click' (fn openModalDialog dialogId 1)}}>Open modal text dialog</button>
  </p>
</template>;

var dialogId = 'dialogText';
var imageId = 'IMG_1234a_2023_november_19'; // dummy
    imageId = 'IMG_1234a'; // dummy

//== Dialog with <dialog> tag

document.addEventListener ('keydown', detectEsc, false);

function detectEsc(e) {
  if (e.keyCode === 27) { // ESC key
    closeDialog(dialogId);
  }
}

const DialogText = <template>
<div style="display:flex; align-items:center; justify-content:center; height:50%;">

<dialog id='dialogText'>
  <header data-dialog-draggable>
    <p>&nbsp;</p>
    <p>Legends for <span>{{imageId}}</span></p>
    <button class="close" type="button" {{on 'click' (fn closeDialog dialogId)}}>×</button>
  </header>
    <form method="dialog">
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
        <textarea id="dialogTextDescription" name="description" rows="6" placeholder="Skriv bildtext: När var vad vilka (för Xmp.dc.description)" {{on 'mouseleave' onMouseLeave}}></textarea><br>
        <textarea id="dialogTextCreator" name="creator" rows="1" placeholder="Skriv ursprung: Foto upphov källa (för Xmp.dc.creator)" {{on 'mouseleave' onMouseLeave}}></textarea>
      </main>
      <footer>
        <button id="dialogTextButton1" type="button" {{on 'click' (fn saveDialog dialogId)}}>Save</button>&nbsp;
        <button id="dialogTextButton2" type="button" {{on 'click' (fn saveCloseDialog dialogId)}}>Save and close</button>&nbsp;
        <button id="dialogTextButton3" type="button" {{on 'click' (fn closeDialog dialogId)}}>Close</button>&nbsp;
        <button id="dialogTextButton4" type="button" {{on 'click' (fn notesDialog dialogId)}}>Notes</button>&nbsp;
        <button id="dialogTextButton5" type="button" {{on 'click' (fn keysDialog 'dialogTextKeywords')}}>Keywords</button>&nbsp;
      </footer>
    </form>
</dialog>

<dialog id="dialogTextKeywords" style="width:20%">
  <header data-dialog-draggable>
    <p>&nbsp;</p>
    <p>Keywords for <span>{{imageId}}</span></p>
    <button class="close" type="button" {{on 'click' (fn closeDialog 'dialogTextKeywords')}}>×</button>
  </header>
  <main style="padding:0.5rem;text-align:center">
    <div class="diaMess">
      Planerat framtida tillägg:<br>
      Ord lagrade som metadata<br>
      för användning som<br>
      särskilda sökbegrepp
    </div>
  </main>
  <footer>
    <button type="button" {{on 'click' (fn closeDialog 'dialogTextKeywords')}}>Ok</button>&nbsp;
  </footer>
</dialog>

</div>
</template>


//== Dialog open/toggle

function openDialog(dialogId, origPos) {
  let diaObj = document.getElementById(dialogId);

  diaObj.show();
  if (origPos) diaObj.style = '';
  // eslint-disable-next-line no-console
  console.log(dialogId + ' opened');
}

function toggleDialog(dialogId, origPos) {
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

function openModalDialog(dialogId, origPos) {
  let diaObj = document.getElementById(dialogId);

  if (origPos) diaObj.style = '';
  diaObj.showModal();
  // eslint-disable-next-line no-console
  console.log(dialogId + ' opened (modal)');
}


//== Dialog buttons

function saveDialog(dialogId) {
  // eslint-disable-next-line no-console
  console.log(dialogId + ' image legends saved');
}

function saveCloseDialog(dialogId) {
  saveDialog(dialogId);
  closeDialog(dialogId);
}

function closeDialog(dialogId) {
  document.getElementById(dialogId).close();
  // eslint-disable-next-line no-console
  console.log(dialogId + ' closed');
}

function notesDialog() {
  // eslint-disable-next-line no-console
  console.log('The Notes modal for ' + imageId + ' to be opened');
}

function keysDialog(dialogId) {
  // eslint-disable-next-line no-console
  console.log('The Keywords modal for ' + imageId + ' to be opened');
  openModalDialog(dialogId, 1)
}


//== Insert from virtual keys

var textArea = '';
var insertInto = '';

function onMouseLeave(e) {
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

  textArea.setSelectionRange(i, i);
  beforeInsert = textValue.substring(
    0, textArea.selectionStart);
  afterInsert = textValue.substring(
    textArea.selectionEnd, textArea.length);
}

