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
import { DialogHelp } from './dialog-help';
import { DialogLogin } from './dialog-login'
import { DialogText } from './dialog-text';
import { default as Header } from './header';
import { Language } from './language';
import { MenuMain } from './menu-main';

import { dialogLoginId } from './dialog-login';

const returnValue = cell('');

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

  openLogIn = async () => {
    this.z.openModalDialog(dialogLoginId, 0);
    // this.z.openDialog(dialogLoginId, 0);
  }

  toggleBackg = () => {
    if (this.z.bkgrColor === '#cbcbcb') {
      this.z.bkgrColor = '#000';
      this.z.textColor = '#fff';
      this.z.loli('set dark background');
    } else {
      this.z.bkgrColor = '#cbcbcb';
      this.z.textColor = '#000';
      this.z.loli('set light background');
    }
    document.querySelector('body').style.background = this.z.bkgrColor;
    document.querySelector('body').style.color = this.z.textColor;
  }

  getCred = async () => {
    if (!this.z.userStatus) { // only once
      // Set a guest user and corresponding allowances
      let allow = await this.z.getCredentials('Get allowances');
      console.log(allow);
      this.z.allowances = allow;
      await new Promise (z => setTimeout (z, 99));
      // Get all recorded user statuses and their allowances + passwordless users
      let cred = (await this.z.getCredentials('Get user name')).split('\n');
      this.z.userStatus = cred[1];
      this.z.allowvalue = cred[2];
      this.z.freeUsers = cred[3];
      await new Promise (z => setTimeout (z, 99));
      // Get album-collection-qualified catalogs
      let roots = await this.z.getAlbumRoots();
      this.z.imdbRoots = roots.split('\n');
    };
  }

}

const executeOnInsert = modifier((element, [component]) => {
  component.getCred();
});

export default class extends Welcome {
  @service('common-storage') z;
  <template>
    <div {{executeOnInsert this}} style="display:flex;justify-content:space-between" >
      {{! Html inserted here will appear beneath the buildStamp div }}
      <h1 style="margin:0 0 0 4rem;display:inline">{{t "header"}}</h1>&nbsp;

      <button type="button" title={{t 'button.backgtitle'}} {{on 'click' (fn this.toggleBackg)}}>{{t 'dark'}}/{{t 'light'}}</button>&nbsp;
      <button type="button" {{on 'click' (fn this.openLogIn)}}>{{t 'button.optlogin'}}</button>&nbsp;
      <span>{{t 'time.text'}}
        <span><Clock @locale={{t 'intlcode'}} /></span>
      </span>
      <Language />
    </div>
    <Header />
    <DialogLogin />
    <MenuMain />
    <ButtonsLeft />
    <DialogHelp />
    <DialogText />
  </template>;
}
