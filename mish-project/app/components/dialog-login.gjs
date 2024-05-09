//== Mish login dialog

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';

import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

// Note: Dialog function in Welcome needs dialogLoginId:
export const dialogLoginId = 'dialogLogin';
const dialogRightsId = 'dialogRights';

export class DialogLogin extends Component {
  @service('common-storage') z;
  @service intl;
  // @tracked 2;

  get picName() { // this.picName may replace this.z.picName, a code example.
    return this.z.picName;
  }

  logIn = async () => {
    let user = document.querySelector('input.user_').value.trim();
    if (!user) user = this.z.userName;
    let cred = (await this.z.getCredentials(user)).split('\n');
    let pwrd = document.querySelector('input.password_').value.trim();
    // cred = [password, userStatus, allowvalue, freeUsers], no status for illegal users
    if (cred[1] && pwrd === cred[0]) {
      var oldUser = this.z.userName;
      this.z.userName = user;
      this.z.userStatus = cred[1];
      this.z.allowvalue = cred[2];
      this.z.freeUsers = cred[3];
      document.getElementById('logInError').style.display = 'none';
      document.querySelector('input.user_').value = '';
      document.querySelector('input.password_').value = '';
      if (user !== oldUser) this.z.loli('logged in');
    } else {
      document.getElementById('logInError').style.display = '';
      await new Promise (z => setTimeout (z, 5222));
      document.getElementById('logInError').style.display = 'none';
    }
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
  detectClickOutside = (e) => {
    let tgt = e.target.id;
    if (tgt === dialogLoginId || tgt === dialogRightsId ) {
      // Outside a modal dialog, else not!
      this.z.closeDialog(tgt);
    }
  }

  // Format allowances for dialogRights
  // @action
  allowances = () => {
    return this.z.allowances;
    // let tmp = this.z.allowances.split('\n');
    // var status = [];
    // var allow = [];
    // for (let i=0; i<tmp.length; i+=2) {
    //   status.push(tmp[i]);
    //   allow.push(tmp[i+1]);
    // }
    // await new Promise (z => setTimeout (z, 222));
    // var m = String(allow[0]).length;
    // var mx = '';
    // for (let i=0; i<m; i++) {
    //   for (let j=0; j<status.length; j++) {
    //     mx += String(allow[j])[i];
    //   }
    //   mx += '\n';
    // }
    // return String(mx).trim();
  }

  // Make an allowvalue array for dialogRights
  allowvalues = () => {
    return this.z.allowvalue.split('');
  }

  <template>
    <div style="display:flex" {{on 'keydown' this.detectEscClose}} {{on 'click' this.detectClickOutside}}>

      <dialog id="dialogLogin">
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
              <br>
              ({{t 'dialog.login.text3'}}: {{this.z.freeUsers}}):
            </p>
            <div class="show-inline" style="text-align:right;width:fit-content">
              {{t 'dialog.login.user'}}:
              <input class="user_" size="10" title={{t 'dialog.login.name'}} placeholder={{t 'dialog.login.name'}} type="text"><a title={{t 'erase'}} {{on 'click' (fn this.clearInput 'user_')}}> ×&nbsp;</a>
              <br>
              {{t 'dialog.login.password'}}:
              <input class="password_" size="10" title={{t 'dialog.login.password'}} placeholder={{t 'dialog.login.password'}} type="password"><a title={{t 'erase'}} {{on 'click' (fn this.clearInput 'password_')}}> ×&nbsp;</a>
            </div>
            <p id="logInError" style="margin:1rem 1rem 0;color:red;font-weight:bold;display:none">
              {{t 'dialog.login.error'}}
            </p>
          </form>
          <div style="display:none" info="allowvalue char 'array'">{{this.z.allowvalue}}</div>
          <button type="button" {{on 'click' (fn this.z.openModalDialog dialogRightsId 0)}}>{{t 'button.rights'}}</button>&nbsp;
          <br>
        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.z.closeDialog dialogLoginId)}}>{{t 'button.close'}}</button>&nbsp;
          <button type="submit" {{on 'click' (fn this.logIn)}}>{{t 'button.login'}}</button>&nbsp;
        </footer>
      </dialog>

      <dialog id="dialogRights">
        <header data-dialog-draggable>
          <div style="width:99%">
            <p>{{t 'dialog.rights.header'}}<span></span></p>
          </div><div>
            <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogRightsId)}}>×</button>
          </div>
        </header>
        <main style="text-align:center">
          <p>
            Text in the Rights Dialog
          </p>
          <p>
            <pre>{{(this.allowances)}}</pre>
          </p>
          <div class="" style="display:grid;grid-template-columns:auto auto auto auto auto auto auto">

            {{!-- {{#each this.status as |status|}}
              {{#each this.allowvalues as |av|}}
                <div>{{av}}</div>
                {{if this.zero '0' '1'}}
              {{/each}}
            {{/each}} --}}

          </div>
        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.z.closeDialog dialogRightsId)}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

    </div>
  </template>
}
