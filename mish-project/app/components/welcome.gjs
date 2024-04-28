//== Mish main component Welcome

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { modifier } from 'ember-modifier';
import { cell } from 'ember-resources';
import { makeDialogDraggable } from 'dialog-draggable';

import { ButtonsLeft } from './buttons-left';
import { DialogHelp } from './dialog-help';
import { DialogLogin } from './dialog-login'
import { DialogText } from './dialog-text';
import { default as Header } from './header';
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

  init = () => {
    this.z.openModalDialog(dialogLoginId, 0);
  }

  toggleBackg = () => {
    if (this.z.bkgrColor === '#cbcbcb') {
      this.z.bkgrColor = '#000';
    } else {
      this.z.bkgrColor = '#cbcbcb';
    }
    this.z.loli(this.z.bkgrColor);
  }

  getCred = async () => {
    let cred = (await this.z.getCredentials()).split('\n');
    this.z.userStatus = cred[1];
    this.z.freeUsers = cred[3];
  }

}

const executeOnInsert = modifier((element, [component]) => {
  component.getCred();
});

export default class extends Welcome {
  @service('common-storage') z;
  <template>
    <div {{executeOnInsert this}} style="backgrounnd-color:{{this.z.bkgrColor}}">
      {{! Html inserted here will appear beneath the buildStamp div }}
      <h1 style="margin:0 0 0 4rem;display:inline">{{t "header"}}</h1>

      <a class="proid toggbkg" style="margin:0.5em 0 0 0.7em" title="" {{on 'click' (fn this.toggleBackg)}}>{{t 'dark'}}/{{t 'light'}}</a>

      <button type="button" {{on 'click' (fn this.init)}}>{{t 'button.login'}}</button>

      <Header />
      <DialogLogin />
      <MenuMain />
      <ButtonsLeft />
      <DialogHelp />
      <DialogText />
    </div>
  </template>;
}
