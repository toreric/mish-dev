//== Mish dialog with help text

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

// Note: Dialog functions in ButtonsLeft needs dialogHelpId:
export const dialogHelpId = "dialogHelp";

export class DialogHelp extends Component {
  @service('common-storage') z;

  // Detect closing Esc key
  @action
  detectEscClose(e) {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogHelpId).open) this.z.closeDialog(dialogHelpId);
    }
  }

<template>

<dialog id="dialogHelp" style="width:min(calc(100vw - 1rem),600px)" {{on 'keydown' this.detectEscClose}}>
  <header data-dialog-draggable>
    <div style="width:99%">
      <p><b>{{t 'dialog.help.header'}}</b><br>{{t 'dialog.help.header1'}}<span></span></p>
    </div><div>
      <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogHelpId)}}>×</button>
    </div>
  </header>
  <main style="height:30rem">
      <p style="text-align:left;margin:-0.9rem 0 0 1.5rem;line-height:1.7rem" draggable="false" ondragstart="return false"><br>

        <span style="font-size:0.95em"><b>{{t 'dialog.help.login0'}}</b> {{t 'dialog.help.login1'}}<br>

        <b>{{t 'dialog.help.ihrcm0'}}</b> {{{t 'dialog.help.ihrcm1'}}}<b>{{t 'dialog.help.ctrlclick'}}</b> {{t 'dialog.help.ihrcm2'}}<br>

        <b>{{t 'dialog.help.shift0'}}</b> {{t 'dialog.help.shift1'}}<br>

        <b style="color:#0b0">{{t 'dialog.help.green0'}}</b> {{t 'dialog.help.green1'}}
        </span>
      </p>
      <p style="text-align:left;margin-left:1.5rem;line-height:1.7rem" draggable="false" ondragstart="return false">
        <b>{{t 'dialog.help.flebu'}}</b> ({{t 'dialog.help.wviva'}}):<br>

        <a id="albSel" class="helpIcon">𝌆</a> {{t 'dialog.help.mmenu'}}<br>

        <a id="questionMark0" class="helpIcon">?</a> {{t 'dialog.help.qmark'}}<br>

        <a id="reFr0" class="helpIcon"><img draggable="false" ondragstart="return false" src="/images/reload.png"></a> {{t 'dialog.help.rload'}}<br>

        <a id="toggleName0" class="helpIcon">N</a> {{t 'dialog.help.names'}}<br>

        <a id="toggleHide0" class="helpIcon"></a> {{t 'dialog.help.hide'}}<br>

        <a id="saveOrder0" class="helpIcon">S</a> {{t 'dialog.help.save'}}<br>

        <a class="helpIcon">↑</a>  {{t 'dialog.help.uptop'}}
      </p>
      <p style="text-align:left;margin:-0.4rem 0 0 3rem;line-height:1.5rem" draggable="false" ondragstart="return false"> {{t 'dialog.help.note1'}}
        <br> {{t 'dialog.help.note2'}}
      </p>
      <p style="text-align:left;margin-left:1.5rem;line-height:1.5rem" draggable="false" ondragstart="return false"> {{{t 'dialog.help.advice'}}}
      </p>
      <p style="text-align:left;margin-left:1.5em;line-height:1.5em" draggable="false" ondragstart="return false">
        <b>{{t 'dialog.help.keyb'}}</b>:<br>

        <b>F1</b> {{t 'dialog.help.F1'}}  <br>

        <b>Ctrl</b>+<b class="large">+</b> {{t 'and'}}och <b>Ctrl</b>+<b class="large">&minus;</b> {{t 'dialog.help.hilo'}} <b>Ctrl</b>+<b class="large">0</b> {{t 'dialog.help.zero'}}<br>

        <b>F11</b> {{{t 'dialog.help.F11'}}}<br>

        {{{t 'dialog.help.right'}}}<br>

        {{{t 'dialog.help.A'}}}<br>

        {{{t 'dialog.help.F'}}}<br>

        {{{t 'dialog.help.Esc'}}}<br>

        {{{t 'dialog.help.F5'}}}</p>
  </main>
  <footer data-dialog-draggable>
    <button type="button" {{on 'click' (fn this.z.closeDialog dialogHelpId)}}>{{t 'button.close'}}</button>&nbsp;
  </footer>
</dialog>

</template>
}
