//== Mish dialog with help text

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

// Note: Dialog functions in ButtonsLeft needs dialogHelpId:
export const dialogHelpId = 'dialogHelp';

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

<dialog id="dialogHelp" style="width:min(calc(100vw - 1rem),38rem);height:min(calc(100vh - 1rem,40rem))" {{on 'keydown' this.detectEscClose}}>
  <header data-dialog-draggable>
    <div style="width:99%">
      <p><b>{{t 'dialog.help.header'}}</b><br>{{t 'dialog.help.header1'}}<span></span></p>
    </div><div>
      <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogHelpId)}}>×</button>
    </div>
  </header>
  <main style="height:30rem">
      <p style="text-align:left;margin:0.5rem 0.3rem 0 1.5rem;line-height:1.4rem" draggable="false" ondragstart="return false">
        <p><b>{{t 'dialog.help.login0'}}</b> {{t 'dialog.help.login1'}}</p>

        <p><b>{{t 'dialog.help.ihrcm0'}}</b> {{{t 'dialog.help.ihrcm1'}}}<br><b>{{t 'dialog.help.ctrlclick'}}</b> {{t 'dialog.help.ihrcm2'}}</p>

        <p>{{{t 'dialog.help.mark0'}}}<br>
          <b>{{t 'dialog.help.shift0'}}</b> {{t 'dialog.help.shift1'}}</p>

        <p><b style="color:#0b0;text-decoration:underline">{{t 'dialog.help.green0'}}</b> {{t 'dialog.help.green1'}}</p>
      </p>
      <p style="text-align:left;margin:0.5rem 0.3rem 0 1.5rem;line-height:1.7rem" draggable="false" ondragstart="return false">
        <b>{{t 'dialog.help.flebu'}}</b> ({{t 'dialog.help.wviva'}}):<br>

        <a id="albSel" class="helpIcon">𝌆</a>&nbsp; {{t 'dialog.help.mmenu'}}<br>

        <a id="questionMark0" class="helpIcon">?</a>&nbsp; {{t 'dialog.help.qmark'}}<br>

        <a id="reFr0" class="helpIcon"><img draggable="false" ondragstart="return false" src="/images/reload.png"></a>&nbsp; {{t 'dialog.help.rload'}}<br>

        <a id="toggleName0" class="helpIcon">N</a>&nbsp; {{t 'dialog.help.names'}}<br>

        <a id="toggleHide0" class="helpIcon"></a>&nbsp; {{t 'dialog.help.hide'}}<br>

        <a id="saveOrder0" class="helpIcon">S</a>&nbsp; {{t 'dialog.help.save'}}<br>

        <a class="helpIcon">↑</a>&nbsp; {{t 'dialog.help.uptop'}}
      </p>
      <p style="text-align:left;margin:0.3rem 0.3rem 0 1.5rem;line-height:1.4rem" draggable="false" ondragstart="return false"> {{t 'dialog.help.note1'}}
        <br> {{t 'dialog.help.note2'}}
      </p>
      <p style="text-align:left;margin:0.7rem 0.3rem 0 1.5rem;line-height:1.4rem" draggable="false" ondragstart="return false"> {{{t 'dialog.help.advice'}}}
      </p>
      <p style="text-align:left;margin:0.7rem 0.3rem 0 1.5rem;line-height:1.4rem" draggable="false" ondragstart="return false">
        <p style="margin:0.7rem 0 0 0"><b>{{t 'dialog.help.keyb'}}</b>:</p>

        <p style="margin:0.25rem 0.3rem 0 0"><b>F1</b> {{{t 'dialog.help.F1'}}}  </p>

        <p style="margin:0.25rem 0.3rem 0 0"><b>Ctrl</b>+<b class="large">+</b> {{t 'and'}} <b>Ctrl</b>+<b class="large">&minus;</b> {{t 'dialog.help.hilo'}} &ndash; <b>Ctrl</b>+<b class="large">0</b> {{t 'dialog.help.zero'}}</p>

        <p style="margin:0.5rem 0.3rem 0 0"><b>F11</b> {{{t 'dialog.help.F11'}}}</p>

        <p style="margin:0.5rem 0.3rem 0 0">{{{t 'dialog.help.right'}}}</p>

        <p style="margin:0.5rem 0.3rem 0 0">{{{t 'dialog.help.A'}}}</p>

        <p style="margin:0.5rem 0.3rem 0 0">{{{t 'dialog.help.F'}}}</p>

        <p style="margin:0.5rem 0.3rem 0 0">{{{t 'dialog.help.Esc'}}}</p>

        <p style="margin:0.5rem 0.3rem 1rem 0">{{{t 'dialog.help.F5'}}}</p>
      </p>
  </main>
  <footer data-dialog-draggable>
    <button type="button" {{on 'click' (fn this.z.closeDialog dialogHelpId)}}>{{t 'button.close'}}</button>&nbsp;
  </footer>
</dialog>

</template>
}
