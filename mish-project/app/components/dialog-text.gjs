//== Mish dialogs for image texts (captions etc.)

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { TrackedAsyncData } from 'ember-async-data';
import { cached } from '@glimmer/tracking';

import RefreshThis from './refresh-this';

// Note: Dialog-functions in Header needs dialogTextId:
export const dialogTextId = 'dialogText';
const dialogTextNotesId = 'dialogTextNotes';
const dialogTextKeywordsId = 'dialogTextKeywords';

document.addEventListener('mousedown', async (e) => {
  e.stopPropagation();
});

document.addEventListener('keydown', async (e) => {
  if (e.keyCode === 27) {
    e.stopPropagation();
    document.getElementById(dialogTextId).close();
    console.log('-"-: closed ' + dialogTextId);
  }
});

//== Component DialogText with <dialog> tags
export class DialogText extends Component {
  @service('common-storage') z;

  // Subdialog open button is pressed

  childDialog = (diaId) => {
    this.z.openModalDialog(diaId, 0);
  }

  // Detect closing Esc key and handle (sub)dialogs
  detectEscClose = async (e) => {
    if (e.keyCode !== 27) return;
    e.stopPropagation();
    let tmp1 = document.getElementById(dialogTextNotesId);
    let tmp2 = document.getElementById(dialogTextKeywordsId);
    // There are 2 subdialogs
    if (tmp1.open) {
      this.z.closeDialog(tmp1.id);
      await new Promise (z => setTimeout(z, 9)); // Soon allow next
    } else if (tmp2.open) {
      this.z.closeDialog(tmp2.id);
      await new Promise (z => setTimeout(z, 9)); // Soon allow next
    } else {
      this.z.closeDialog(dialogTextId);
    }
  }

  get picName() {
    if (!this.z.picName) return; // Dismiss initial reactivity
    let text = '';
    let path = this.z.allFiles[this.z.picIndex].linkto;
    let nodeMess = document.querySelector('#dialogText main .diaMess b');
    if (/\.gif$/i.test(path)) {
      // Insert after '#dialogText main .diaMess', ended wirh <br>:
      // Gif-bilder kan bara ges tillfällig text, den kan inte sparas!
      // intl.t name = txtGif
      text = 'Gif-bilder kan inte ges permanent text, sparas bara tillfälligt';
      nodeMess.textContent = text;
    } else {
      nodeMess.textContent = '';
    }

   return this.z.picName;
  }

  get txt1() {
    if (!this.z.picName) return; // picIndex depends on picName
    return this.z.deNormalize(this.z.allFiles[this.z.picIndex].txt1.toString());
  }

  get txt2() {
    if (!this.z.picName) return; // picIndex depends on picName
    return this.z.deNormalize(this.z.allFiles[this.z.picIndex].txt2.toString());
  }

  // Detect closing click outside a dialog-draggable modal dialog
  detectClickOutside = (e) => {
    e.stopPropagation();
    if (!navigator.userAgent.includes("Firefox")) return; // Only Firefox can do this
    let tgt = e.target.id;
    if (tgt === dialogTextId || tgt === dialogTextNotesId || tgt === dialogTextKeywordsId) {
      // Outside a modal dialog, else not!
      this.z.closeDialog(tgt);
    }
  }

  <template>
    <div style="display:flex" {{on 'keydown' this.detectEscClose}} {{on 'click' this.detectClickOutside}}>

      <dialog id='dialogText'>
        <header data-dialog-draggable >
          <p>&nbsp;</p>
          <p>{{t 'dialog.text.header'}} <span>{{this.picName}}</span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogTextId)}}>×</button>
        </header>
        <main>
          <div class="diaMess">
            <b style="width:100%;text-align:center;color:brown"></b>
            <VirtualKeys />
          </div>

          <RefreshThis @for={{this.picName}}>
            <textarea id="dialogTextDescription" name="description" rows="6" placeholder="{{t "write.description"}} (Xmp.dc.description)" {{on 'mouseleave' onMouseLeaveTextarea}}>{{this.txt1}}</textarea><br>

            <textarea id="dialogTextCreator" name="creator" rows="2" placeholder="{{t "write.creator"}} (Xmp.dc.creator)" {{on 'mouseleave' onMouseLeaveTextarea}}>{{this.txt2}}</textarea>
          </RefreshThis>

        </main>
        <footer data-dialog-draggable>
          <button id="dialogTextButton1" type="button" {{on 'click' (fn this.z.saveDialog dialogTextId)}}>{{t 'button.save'}}</button>&nbsp;
          <button id="dialogTextButton2" type="button" {{on 'click' (fn this.z.saveCloseDialog dialogTextId)}}>{{t 'button.saveclose'}}</button>&nbsp;
          <button id="dialogTextButton3" type="button" {{on 'click' (fn this.z.closeDialog dialogTextId)}}>{{t 'button.close'}}</button>&nbsp;
          <button id="dialogTextButton4" type="button" {{on 'click' (fn this.childDialog 'dialogTextNotes')}}>{{t 'button.notes'}}</button>&nbsp;
          <button id="dialogTextButton5" type="button" {{on 'click' (fn this.childDialog 'dialogTextKeywords')}}>{{t 'button.keywords'}}</button>&nbsp;
        </footer>
      </dialog>

      <dialog id='dialogTextNotes'>
        <header data-dialog-draggable>
          <p>&nbsp;</p>
          <p>{{t 'dialog.text.notes'}} <span>{{this.z.picName}}</span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog 'dialogTextNotes')}}>×</button>
        </header>
        <main>
          <div class="diaMess">
            <VirtualKeys />
          </div>

          <textarea id="dialogTextInfo" name="description" rows="8" placeholder="{{t 'write.notes'}} (Xmp.dc.source)" {{on 'mouseleave' onMouseLeaveTextarea}}> {{t 'write.notes'}} (Xmp.dc.source)&#13;&#10;&#13;&#10; {{t 'futureFacility'}}</textarea><br>

        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.z.saveDialog dialogTextNotesId)}}>{{t 'button.save'}}</button>&nbsp;
          <button type="button" {{on 'click' (fn this.z.saveCloseDialog dialogTextNotesId)}}>{{t 'button.saveclose'}}</button>&nbsp;
          <button type="button" {{on 'click' (fn this.z.closeDialog dialogTextNotesId)}}>{{t 'button.close'}}</button>
        </footer>
      </dialog>

      <!-- Temporary special styling 1 in this dialog stub -->
      <dialog id="dialogTextKeywords" style="width:max(20%, 20rem)">
        <header data-dialog-draggable>
          <p>&nbsp;</p>
          <p>{{t 'dialog.text.keywords'}} <span>{{this.z.picName}}</span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogTextKeywordsId)}}>×</button>
        </header>
        <!-- Temporary special styling 2 in this dialog stub -->
        <main style="padding:0.5rem;text-align:center">
          <div class="diaMess">
            {{t 'write.keywords'}}
          </div>
        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.z.closeDialog dialogTextKeywordsId)}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

    </div>
  </template>

}

//== Virtual keys for some missing characters on common keyboards
// (some are due to the included languages)

const VirtualKeys = <template>
  <div class="" style='padding:0.1em'>
    <b class='insertChar' {{on 'click' insert}}>×</b>
    <b class='insertChar' {{on 'click' insert}}>°</b>
    &nbsp;
    &nbsp;
    <b class='insertChar' {{on 'click' insert}}>–</b>
    <b class='insertChar' {{on 'click' insert}}>—</b>
    &nbsp;
    &nbsp;
    <b class='insertChar' {{on 'click' insert}}>„</b>
    <b class='insertChar' {{on 'click' insert}}>“</b>
    <b class='insertChar' {{on 'click' insert}}>”</b>
    &nbsp;
    &nbsp;
    <b class='insertChar' {{on 'click' insert}}>‚</b>
    <b class='insertChar' {{on 'click' insert}}>‘</b>
    <b class='insertChar' {{on 'click' insert}}>’</b>
    &nbsp;
    &nbsp;
    <b class='insertChar' {{on 'click' insert}}>«</b>
    <b class='insertChar' {{on 'click' insert}}>»</b>
  </div>
</template>

var textArea = '';
var insertInto = '';

// Detect last active textarea
// Used when a VirtualKeys key is clicked

function onMouseLeaveTextarea(/*e*/) {
  //textArea = e.target;
  textArea = document.activeElement;
  insertInto = textArea.id;
}

// Insert from VirtualKeys, non-replacing(!)

export function insert(e) {
  if (!insertInto) return;

  textArea = document.getElementById(insertInto);

  let textValue = textArea.value;

  if (textValue === undefined) return;

  let beforeInsert = textValue.substring(
    0, textArea.selectionStart);
  let afterInsert = textValue.substring(
    textArea.selectionStart, textArea.length);
  // Avoid 'delete selected', cannot undo!
  // let afterInsert = textValue.substring(
  //   textArea.selectionEnd, textArea.length);
  // selectedText = textValue.substring(
  //   textArea.selectionStart, textArea.selectionEnd);

  beforeInsert += e.target.innerHTML;
  textValue = beforeInsert + afterInsert;
  document.getElementById(insertInto).value = textValue;
  document.getElementById(insertInto).focus();

  let i = beforeInsert.length;

  if (textArea.setSelectionRange) { // avoid error in some special cases
    textArea.setSelectionRange(i, i);
    beforeInsert = textValue.substring(
      0, textArea.selectionStart);
    afterInsert = textValue.substring(
      textArea.selectionEnd, textArea.length);
  }
}
