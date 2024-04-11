//== Mish login dialog

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';

import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
// import { openDialog, toggleDialog, openModalDialog, saveDialog, closeDialog, saveCloseDialog } from 'dialog-functions';
// import { closeDialog, toggleDialog } from './dialog-functions'

// import { loli } from './common-functions';
// import {    } from './common-storage';
import { getCredentials } from './common-functions';

var password = '';
var status = '';
var allval = '';

export const dialogLoginId = "dialogLogin";
const dialogId = "dialogLogin";

export class DialogLogin extends Component {
  @service('common-storage') z;

  get imageId() {
    return this.z.imageId;
  }

  setUserName(newUser) {
    this.z.setUserName(newUser);
  }

  userCheck = () => {
    return new Promise(resolve => {
      getCredentials(this.z.userName).then(credentials => {
        var cred = credentials.split("\n");
        password = cred [0];
        status = cred [1];
        allval = cred [2];
        if (status === "viewer") this.setUserName('');
        console.log(this.z.userName, cred);
        // console.log('mish', cred);
      });
    });
  }

  //== Detect closing click outside modal dialog

  // document.addEventListener ('click', detectClickOutside, false);

  // detectClickOutside = (e) => {
  //   let tgt = e.target.id;
  //   if (tgt === dialogId) { // Outside a modal dialog, else not!
  //     this.z.closeDialog(tgt);
  //   }
  // }

  //== Clear input field, user or password

  clearInput = (inputClass) => {
    this.z.loli('clearInput (' + inputClass + ')');
    // loli(document.querySelector("input." + inputClass));
    document.querySelector("input." + inputClass).value = '';
    document.querySelector("input." + inputClass).focus({ focusVisible: true });
  }

  <template>
    <!--button>{{on 'click' (fn setUserName 'mish')}}</button-->
    <dialog id="dialogLogin">
      <header data-dialog-draggable>
        <div style="width:99%">
          <p>{{t 'dialog.login.header'}}<span>{{null}}</span></p>
        </div>{{null}}<div>
          <button class="close" type="button" {{on 'click' (fn this.z.toggleDialog dialogId)}}>×</button>
        </div>
      </header>
      <main style="text-align:center">
        <form action="">
          <p>{{this.z.imageId}}</p>
          <p>
            Du är nu inloggad som <span>{{this.z.userName}}</span>
            med [<span>{{status}}</span>]-rättigheter.
            <br>
            Om du vill byta gör du det här:
          </p>
          <div class="show-inline" style="text-align:right;width:fit-content">
            {{t 'dialog.login.user'}}:
            <input class="user_" size="10" title={{t 'dialog.login.user'}} placeholder={{t 'dialog.login.name'}} type="text"><a title={{t 'erase'}} {{on 'click' (fn this.clearInput 'user_')}}> ×&nbsp;</a>
            <br>
            {{t 'dialog.login.password'}}:
            <input class="password_" size="10" title={{t 'dialog.login.password'}} placeholder={{t 'dialog.login.password'}} type="password"><a title={{t 'erase'}} {{on 'click' (fn this.clearInput 'password_')}}> ×&nbsp;</a>
          </div>
        </form>
        <br>
      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogId)}}>{{t 'button.close'}}</button>&nbsp;
        <button type="button" {{on 'click' (fn this.userCheck)}}>{{t 'button.login'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>
}

//== Detect closing Esc key

// document.addEventListener ('keydown', detectEsc, false);

// function detectEsc(e) {
//   if (e.keyCode === 27) { // Esc key
//     if (document.getElementById(dialogId).open) closeDialog(dialogId);
//   }
// }

//== Detect closing click outside modal dialog

// document.addEventListener ('click', detectClickOutside, false);

// function detectClickOutside(e) {
//   let tgt = e.target.id;

//   if (tgt === dialogId) { // Outside a modal dialog, else not!
//     this.z.closeDialog(tgt);
//   }
// }

//== Clear input field, user or password

// function clearInput(inputClass) {
//   this.z.loli('clearInput (' + inputClass + ')');
//   // loli(document.querySelector("input." + inputClass));
//   document.querySelector("input." + inputClass).value = '';
//   document.querySelector("input." + inputClass).focus({ focusVisible: true });
// }
