//== Mish login dialog

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';

import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
// import { openDialog, toggleDialog, openModalDialog, saveDialog, closeDialog, saveCloseDialog } from 'dialog-functions';
import { closeDialog, toggleDialog } from './dialog-functions'

import { loli } from './common-functions';
// import { userName } from './common-storage';
import { getCredentials } from './common-functions';

var password = '';
var status = '';
var allval = '';

export const dialogLoginId = "dialogLogin";
const dialogId = "dialogLogin";

export class DialogLogin extends Component {
  @service('common-storage') z;

  @action setImageId(newId) {
    this.z.imageId = newId;
  }

  get imageId() {
    return this.z.imageId;
  }


  // setImageId('IMG_1234a');
  this.z.setUserName('mish');

  <template>
    <!--button>{{on 'click' (fn setUserName 'mish')}}</button-->
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
          <p>{{this.imageId}}</p>
          <p>
            Du är nu inloggad som <span>{{this.z.userName}}</span>
            med [<span>{{this.z.status}}</span>]-rättigheter.
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
        <button type="button" {{on 'click' (fn closeDialog dialogId)}}>{{t 'button.login'}}</button>&nbsp;
      </footer>
    </dialog>
    {{! This script has no effect: }}
    <script>document.querySelector("input.user_").focus({ focusVisible: true });</script>
  </template>
}

function userCheck() {
  return new Promise(resolve => {
    getCredentials(userName).then(credentials => {
      //console.log('credentials:\n' + credentials);
      var cred = credentials.split("\n");
      password = cred [0];
      status = cred [1];
      allval = cred [2];
      if (status === "viewer") userName = "";
      console.log(userName, cred);
    });
  });
}

userCheck();

//== Detect closing Esc key

document.addEventListener ('keydown', detectEsc, false);

function detectEsc(e) {
  if (e.keyCode === 27) { // Esc key
    if (document.getElementById(dialogId).open) closeDialog(dialogId);
  }
}

function clearInput(inputClass) {
  loli("clearInput called");
  // loli(document.querySelector("input." + inputClass));
  document.querySelector("input." + inputClass).value = '';
  document.querySelector("input." + inputClass).focus({ focusVisible: true });
}

//== Detect closing click outside modal dialog

document.addEventListener ('click', detectClickOutside, false);

function detectClickOutside(e) {
  let tgt = e.target.id;

  if (tgt === dialogId) { // Outside a modal dialog, else not!
    closeDialog(tgt);
  }
}
