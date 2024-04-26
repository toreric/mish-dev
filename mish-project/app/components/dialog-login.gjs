//== Mish login dialog

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
// import { action } from '@ember/object';

import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
// import { getCredentials } from './common-functions';

// Note: Dialog function in Welcome needs dialogLoginId:
export const dialogLoginId = "dialogLogin";

export class DialogLogin extends Component {
// export class DialogLogin extends Controller {
  @service('common-storage') z;
  @service intl;

  get picName() { // this.picName may replace this.z.picName! An example.
    return this.z.picName;
  }

  get statusMissing() {
    return this.intl.t('value.missing');
  }

  // setUserName = async (newUser) => {
  //   this.z.loli('*****' + newUser);
  //   await new Promise (z => setTimeout (z, 129));
  //   this.z.setUserName(newUser);
  //   await new Promise (z => setTimeout (z, 129));
  //   this.z.loli('*****' + newUser);
  // }

  userCheck = () => {
    return new Promise(async resolve => {
      this.z.getCredentials().then((credentials) => {
        var cred = credentials.split('\n');
        this.z.loli(cred);
        var password = cred [0].trim();
        this.z.loli('password is ”' + password + '”');

        var usr = document.querySelector('input.user_').value;
        var prd = document.querySelector('input.password_').value;
        this.z.loli(usr+'|'+prd);

        if (password === '<!DOCTYPE html>') {
          this.z.userStatus = this.statusMissing();
          this.z.allowvalue = null;
        } else {
          this.z.userStatus = cred[1];
          this.z.allowvalue = cred[2];
        }
        if (this.z.userStatus === "viewer") this.z.userName = 'viewer';
        this.z.loli(this.z.userName + '[' + this.z.userStatus + ']' + this.z.allowvalue);
      });
    });
  }

  logIn = () => {
    var usr = document.querySelector('input.user_').value;
    this.z.getCredentials(usr).then((credentials) => {
      var cred = credentials.split('\n');
      var prd = document.querySelector('input.password_').value;
      if (prd === cred[0]) {
        this.z.userName = usr;
        this.z.userStatus = cred[1];
        this.z.allowvalue = cred[2];
        document.getElementById('logInError').style.display = 'none';
        document.querySelector('input.user_').value = '';
        document.querySelector('input.password_').value = '';
        this.z.loli('User ' + usr + ' did log in');
      } else {
        document.getElementById('logInError').style.display = '';
      }
    })
  }

  // Clear input field: user or password
  clearInput = (inputClass) => {
    this.z.loli('clearInput (' + inputClass + ')');
    document.querySelector('input.' + inputClass).value = '';
    document.querySelector('input.' + inputClass).focus({ focusVisible: true });
  }

  // Detect closing Esc key and handle dialog
  // @action
  detectEscClose = (e) => {
    if (e.keyCode === 27) { // Esc key
      this.z.closeDialog(dialogLoginId);
    }
  }

  // Detect closing click outside modal dialog
  // @action
  detectClickOutside = (e) => {
    let tgt = e.target.id;
    if (tgt === dialogLoginId) {
      // Outside a modal dialog, else not!
      this.z.closeDialog(tgt);
    }
  }

  <template>
    <dialog id="dialogLogin" {{on 'keydown' this.detectEscClose}} {{on 'click' this.detectClickOutside}}>
      <header data-dialog-draggable>
        <div style="width:99%">
          <p>{{t 'dialog.login.header'}}<span>{{null}}</span></p>
        </div>{{null}}<div>
          <button class="close" type="button" {{on 'click' (fn this.z.toggleDialog dialogLoginId)}}>×</button>
        </div>
      </header>
      <main style="text-align:center">
        <form action="">
          {{!-- <p>{{this.z.picName}}</p> --}}
          <p style="margin:1rem">
            {{t 'dialog.login.text1'}} <span>{{this.z.userName}}</span>
            {{t 'with'}} [<span>{{this.z.userStatus}}</span>]-{{t 'rights'}}.
            <br>
            {{t 'dialog.login.text2'}}
          </p>
          <div class="show-inline" style="text-align:right;width:fit-content">
            {{t 'dialog.login.user'}}:
            <input class="user_" size="10" title={{t 'dialog.login.name'}} placeholder={{t 'dialog.login.name'}} type="text"><a title={{t 'erase'}} {{on 'click' (fn this.clearInput 'user_')}}> ×&nbsp;</a>
            <br>
            {{t 'dialog.login.password'}}:
            <input class="password_" size="10" title={{t 'dialog.login.password'}} placeholder={{t 'dialog.login.password'}} type="password"><a title={{t 'erase'}} {{on 'click' (fn this.clearInput 'password_')}}> ×&nbsp;</a>
          </div>
          <p id="logInError" style="margin:1rem;color:red;font-weight:bold;display:none">
            {{t 'dialog.login.error'}}
          </p>
        </form>
        <br>
      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogLoginId)}}>{{t 'button.close'}}</button>&nbsp;
        <button type="button" {{on 'click' (fn this.logIn)}}>{{t 'button.login'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>
}
