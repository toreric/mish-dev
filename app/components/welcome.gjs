// eslint-disable-next-line no-unused-vars
import Component from '@glimmer/component';
import { on } from '@ember/modifier';

import { makeDialogDraggable } from 'dialog-draggable';
import focusTrap from 'ember-focus-trap/modifiers/focus-trap';
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
  <button {{on 'click' openDia}}>Open text dialog</button>
</template>;

// Experimens with <dialog> tag
const dialogId = 'dialogText';
const imageId = 'IMG_1234a'; // dummy

const DialogText = <template>
<div style="display:flex; align-items:center; justify-content:center; height:50%;">
<dialog id={{dialogId}} {{focusTrap}} open="">
  <header id="dialogTextHeader" data-dialog-draggable>
    <p>&nbsp;</p>
    <p>Legends for <span>{{imageId}}</span></p>
    <button class="close" {{on 'click' closeDia}}>×</button>
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
        <textarea id="dialogTextDescription" name="description" rows="6" placeholder="Skriv bildtext: När var vad vilka (för Xmp.dc.description)" {{on 'mouseleave' onMouseLeave}} /><br>
        <textarea id="dialogTextCreator" name="creator" rows="1" placeholder="Skriv ursprung: Foto upphov källa (för Xmp.dc.creator)" {{on 'mouseleave' onMouseLeave}} />
      </main>
      <footer id="dialogTextFooter">
        <button id="dialogTextButton1" {{on 'click' saveDia}}>Save</button>&nbsp;
        <button id="dialogTextButton2" {{on 'click' saveCloseDia}}>Save and close</button>&nbsp;
        <button id="dialogTextButton3" {{on 'click' closeDia}}>Close</button>&nbsp;
        <button id="dialogTextButton4" {{on 'click' notesDia}}>Notes</button>&nbsp;
        <button id="dialogTextButton5" {{on 'click' keysDia}}>Keywords</button>&nbsp;
      </footer>
    </form>
</dialog>
</div>
</template>

//const dialog = document.getElementById(dialogId);

function openDia() {
  openDialog(dialogId);
}

function saveDia() {
  saveDialog(dialogId);
}

function saveCloseDia() {
  saveDialog(dialogId);
  closeDialog(dialogId);
}

function closeDia() {
  closeDialog(dialogId);
}

function notesDia() {
  // eslint-disable-next-line no-console
  console.log('The Notes modal window for ' + imageId + ' to be opened');
}

function keysDia() {
  // eslint-disable-next-line no-console
  console.log('The Keywords modal window for ' + imageId + ' to to be opened');
}


// Secondary button actions
function openDialog(dialogId) {
  // eslint-disable-next-line no-console
  console.log('The ' + dialogId + ' window was opened');
}

function saveDialog(dialogId) {
  // eslint-disable-next-line no-console
  console.log('The image legends from ' + dialogId + ' are saved');
}

function closeDialog(dialogId) {
  document.getElementById(dialogId).close();
  // eslint-disable-next-line no-console
  console.log('The ' + dialogId + ' window was closed');
}


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

