import { on } from '@ember/modifier';

import { makeDialogDraggable } from 'dialog-draggable';
import focusTrap from 'ember-focus-trap/modifiers/focus-trap';
import { Modal } from 'ember-primitives';
import { cell } from 'ember-resources';

import { Clock } from './clock';
import { Excite } from './excite';

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

</template>;

// Experimens with <dialog> tag
const DialogText = <template>

<dialog id="dialogText" {{focusTrap}} open="">
  <div>
  <header id="dialogTextHeader" data-dialog-draggable>
    <p>&nbsp;</p>
    <p>Legends for <span>IMG_1234a</span></p>
    <button class="close">×</button>
  </header>
    <form method="dialog">
      <main>
        <div class="diaMess">
          <div class="" style='padding:0.1em'>
            &nbsp;<b class='insertChar' style='cursor:pointer' {{on 'click' insert}}>’</b>
            &nbsp;<b class='insertChar' style='cursor:pointer' {{on 'click' insert}}>–</b>
            &nbsp;<b class='insertChar' style='cursor:pointer' {{on 'click' insert}}>×</b>
            &nbsp;<b class='insertChar' style='cursor:pointer' {{on 'click' insert}}>°</b>
            &nbsp;<b class='insertChar' style='cursor:pointer' {{on 'click' insert}}>—</b>
            &nbsp;<b class='insertChar' style='cursor:pointer' {{on 'click' insert}}>”</b>
          </div>
        </div>
        <textarea id="dialogTextDescription" name="description" rows="6" placeholder="Skriv bildtext: När var vad vilka (för Xmp.dc.description)" {{on 'mouseleave' onMouseLeave}} /><br>
        <textarea id="dialogTextCreator" name="creator" rows="1" placeholder="Skriv ursprung: Foto upphov källa (för Xmp.dc.creator)" {{on 'mouseleave' onMouseLeave}} />
      </main>
      <footer id="dialogTextFooter">
        <button id="dialogTextButton1">Save</button>&nbsp;
        <button id="dialogTextButton2">Save and close</button>&nbsp;
        <button id="dialogTextButton3">Close</button>&nbsp;
        <button id="dialogTextButton4">Notes</button>&nbsp;
        <button id="dialogTextButton5">Keywords</button>&nbsp;
      </footer>
    </form>
  </div>
</dialog>
</template>

var textArea = '';
var insertInto = '';

function onMouseLeave(e) {
  textArea = document.activeElement;
  insertInto = textArea.id;
  // eslint-disable-next-line no-console
  // console.log(insertInto, textArea.tagName)
}

function insert(e) {
  // eslint-disable-next-line no-console
  // console.log(insertInto, textArea.tagName)
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

