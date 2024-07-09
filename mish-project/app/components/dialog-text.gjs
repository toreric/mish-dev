//== Mish dialogs for image texts (captions etc.)

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

// Note: Dialog-functions in Header needs dialogTextId:
export const dialogTextId = 'dialogText';
const dialogTextNotesId = 'dialogTextNotes';
const dialogTextKeywordsId = 'dialogTextKeywords';

//== Component DialogText with <dialog> tags
//== Note: 'data-dialog-draggable' is triggered with makeDialogDraggable() in welcome.gjs

export class DialogText extends Component {
  @service('common-storage') z;

  // Child dialog open button is pressed

  childDialog = (diaId) => {
    this.z.openModalDialog(diaId, 0);
  }

  // Detect closing Esc key and handle (child) dialogs
  detectEscClose = async (e) => {
   if (e.keyCode === 27) { // Esc key
      let tmp1 = document.getElementById(dialogTextNotesId);
      let tmp2 = document.getElementById(dialogTextKeywordsId);
      // There are 2 child dialogs
      if (tmp1.open) {
        this.z.closeDialog(tmp1.id);
        await new Promise (z => setTimeout (z, 9)); // Soon allow next
      } else if (tmp2.open) {
        this.z.closeDialog(tmp2.id);
        await new Promise (z => setTimeout (z, 9)); // Soon allow next
      } else {
        this.z.closeDialog(dialogTextId);
      }
    }
  }

  // Detect closing click outside a dialog-draggable modal dialog
  detectClickOutside = (e) => {
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
          <p>{{t 'dialog.text.header'}} <span>{{this.z.picName}}</span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogTextId)}}>×</button>
        </header>
        <main>
          <div class="diaMess">
            <VirtualKeys />
          </div>
          <textarea id="dialogTextDescription" name="description" rows="6" placeholder="{{t "write.description"}} (Xmp.dc.description)" {{on 'mouseleave' onMouseLeaveTextarea}}></textarea><br>
          <textarea id="dialogTextCreator" name="creator" rows="2" placeholder="{{t "write.creator"}} (Xmp.dc.creator)" {{on 'mouseleave' onMouseLeaveTextarea}}></textarea>
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
          <textarea id="dialogTextInfo" name="description" rows="8" placeholder="{{t 'write.notes'}} (Xmp.dc.source)" {{on 'mouseleave' onMouseLeaveTextarea}}></textarea><br>
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
// (Should this be i18nd? Or extended to include all needs for langages offered?)

const VirtualKeys = <template>
  <div class="" style='padding:0.1em'>
    &nbsp;<b class='insertChar' {{on 'click' insert}}>’</b>
    &nbsp;<b class='insertChar' {{on 'click' insert}}>–</b>
    &nbsp;<b class='insertChar' {{on 'click' insert}}>×</b>
    &nbsp;<b class='insertChar' {{on 'click' insert}}>°</b>
    &nbsp;<b class='insertChar' {{on 'click' insert}}>—</b>
    &nbsp;<b class='insertChar' {{on 'click' insert}}>”</b>
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
