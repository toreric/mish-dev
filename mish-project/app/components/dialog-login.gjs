//== Mish login dialog

import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
//import { openDialog, toggleDialog, openModalDialog, saveDialog, closeDialog, saveCloseDialog } from 'dialog-functions';
import { closeDialog, toggleDialog } from './dialog-functions'

import { loli } from './welcome';

export const dialogLoginId = "dialogLogin";
const dialogId = "dialogLogin";

//== Detect closing Esc key

document.addEventListener ('keydown', detectEsc, false);

function detectEsc(e) {
  if (e.keyCode === 27) { // Esc key
    if (document.getElementById(dialogId).open) closeDialog(dialogId);
  }
}

export const DialogLogin = <template>

<dialog id="dialogLogin">
  <header data-dialog-draggable>
    <div style="width:99%">
      <p>{{t 'dialog.login.header'}}<span></span></p>
    </div><div>
      <button class="close" type="button" {{on 'click' (fn toggleDialog dialogId)}}>×</button>
    </div>
  </header>
  <main>
    <form action="">
      <br>
      <div style="text-align:right">
        &nbsp; {{t 'dialog.login.user'}}: <input size="10" title={{t 'dialog.login.user'}} placeholder={{t 'dialog.login.name'}} type="text"> &nbsp;<br>
        &nbsp; {{t 'dialog.login.password'}}: <input size="10" title={{t 'dialog.login.password'}} placeholder={{t 'dialog.login.password'}} type="password"> &nbsp;
      </div>
      <br>
    </form>
  </main>
  <footer data-dialog-draggable>
    <button type="button" {{on 'click' (fn closeDialog dialogId)}}>{{t 'button.close'}}</button>&nbsp;
  </footer>
</dialog>

</template>
