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

function clearInput(cls) {
  loli("clearInput called");
  // loli(document.querySelector("input." + cls));
  document.querySelector("input." + cls).value = '';
  document.querySelector("input." + cls).focus({ focusVisible: true });
}

export const DialogLogin = <template>

<dialog id="dialogLogin">
  <header data-dialog-draggable>
    <div style="width:99%">
      <p>{{t 'dialog.login.header'}}<span>{{null}}</span></p>
    </div>{{null}}<div>
      <button class="close" type="button" {{on 'click' (fn toggleDialog dialogId)}}>×</button>
    </div>
  </header>
  <main style="text-align:center">
    <form action="">
      <p>
        Du är nu inloggad som <span></span>
        med [<span></span>]-rättigheter.
        <br>
        Om du vill byta gör du det här:
      </p>
      <div class="show-inline" style="text-align:right;width:fit-content">
        {{t 'dialog.login.user'}}:
        <input class="user_" size="10" title={{t 'dialog.login.user'}} placeholder={{t 'dialog.login.name'}} type="text"><a title={{t 'erase'}} {{on 'click' (fn clearInput 'user_')}}> × </a>
        <br>
        {{t 'dialog.login.password'}}:
        <input class="password_" size="10" title={{t 'dialog.login.password'}} placeholder={{t 'dialog.login.password'}} type="password"><a title={{t 'erase'}} {{on 'click' (fn clearInput 'password_')}}> × </a>
      </div>
    </form>
      <br>
  </main>
  <footer data-dialog-draggable>
    <button type="button" {{on 'click' (fn closeDialog dialogId)}}>{{t 'button.close'}}</button>&nbsp;
  </footer>
</dialog>
{{! This script has no effect: }}
<script>document.querySelector("input.user_").focus({ focusVisible: true });</script>

</template>
