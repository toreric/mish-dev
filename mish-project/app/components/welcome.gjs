//== Mish main component Welcome

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { modifier } from 'ember-modifier';
import { cell } from 'ember-resources';
import { makeDialogDraggable } from 'dialog-draggable';

import { Clock } from './clock';
import { ButtonsLeft } from './buttons-left';
import { DialogAlert } from './dialog-alert';
import { DialogHelp } from './dialog-help';
import { DialogLogin } from './dialog-login'
import { DialogText } from './dialog-text';
import { DialogXper } from './dialog-xper';
import { default as Header } from './header';
import { Language } from './language';
import { MenuMain } from './menu-main';

import { dialogLoginId } from './dialog-login';
import { dialogRightsId } from './dialog-login';
import { dialogXperId } from './dialog-xper';

const returnValue = cell('');
const LF = '\n';
makeDialogDraggable();

// Detect closing click outside menuMain (tricky case!)
document.addEventListener('mousedown', (event) => {
  var tmp0 = document.getElementById('menuButton');
  var tmp1 = document.getElementById('menuMain');
  if (tmp1.style.display !== 'none' && event.target !== tmp0 && event.target !== tmp1 && !tmp0.contains(event.target) && !tmp1.contains(event.target)) {
    tmp0.innerHTML = '<span class="menu">☰</span>';
    tmp1.style.display = 'none';
    console.log('-"-: closed main menu');
  }
});

class Welcome extends Component {
  @service('common-storage') z;
  @service intl;

  openRights = async () => {
    this.z.openModalDialog(dialogRightsId, 0);
    // this.z.openDialog(dialogRightsId, 0);
  }
  openLogIn = async () => {
    this.z.openModalDialog(dialogLoginId, 0);
  }
  getCred = async () => {
    if (!this.z.userStatus) { // only once
      // Set default background
      document.querySelector('body').style.background = this.z.bkgrColor;
      document.querySelector('body').style.color = this.z.textColor;
      // Set a guest user and corresponding allowances
      let allowances = await this.z.getCredentials('Get allowances');
      console.log(allowances);
      this.z.allowances = allowances;

     // Get all recorded user statuses and their allowances + passwordless users
      let cred = (await this.z.getCredentials('Get user name')).split(LF);
      this.z.userStatus = cred[1];
      this.z.allowvalue = cred[2];
      this.z.freeUsers = cred[3];
      this.z.allowFunc(); // SET ALLOWANCES PATTERN

      // Get album-collection-qualified catalogs
      let roots = await this.z.getAlbumRoots();
      this.z.imdbRoots = roots.split(LF);

      // Settings from cookies
      // Language
      let lng = this.z.getCookie('mish_lang');
      if (lng) this.intl.setLocale([lng]);
      this.z.intlCodeCurr = lng;
      // Background
      if (this.z.getCookie('mish_bkgr') === 'dark') {
        this.z.bkgrColor = '#111';
        this.z.textColor = '#fff';
      } else {
        this.z.bkgrColor = '#cbcbcb';
        this.z.textColor = '#111';
      }
      document.querySelector('body').style.background = this.z.bkgrColor;
      document.querySelector('body').style.color = this.z.textColor;
    };
  }

}

const executeOnInsert = modifier((element, [component]) => {
  component.getCred();
});

export default class extends Welcome {
  @service('common-storage') z;
  <template>
    <div {{executeOnInsert this}} style="display:flex;justify-content:space-between;margin:0 0.25rem 0 4rem">
      {{! Html inserted here will appear beneath the buildStamp div }}
      <h1 style="margin:0 4rem 0 0;display:inline">{{t "header"}}</h1>
      <span>

        <button type="button" title="Xperimental" {{on 'click' (fn this.z.toggleDialog dialogXperId)}}>&nbsp;</button>

        <button type="button" title={{t 'button.backgtitle'}} {{on 'click' (fn this.z.toggleBackg)}}>{{t 'dark'}}/{{t 'light'}}</button>

        <button type="button" {{on 'click' (fn this.openRights)}}>{{t 'button.rightsinfo'}}</button>

        <button type="button" {{on 'click' (fn this.openLogIn)}}>{{t 'button.optlogin'}}</button>

      </span>
      <span>
        {{t 'loggedIn'}}: <b>{{this.z.userName}}</b> {{t 'with'}} [{{this.z.userStatus}}]-{{t 'rights'}}
      </span>
    </div>

    <div style="display:flex;justify-content:space-between;margin:0 0.25rem 0 4rem">
      <Language />
      <span>{{t 'time.text'}}
        <span><Clock @locale={{this.z.intlCodeCurr}} /></span>
      </span>
    </div>
    <Header />
    <DialogAlert />
    <DialogLogin />
    <MenuMain />
    <ButtonsLeft />
    <DialogHelp />
    <DialogXper />
    <DialogText />
  </template>;
}
