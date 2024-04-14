//== Mish main component Welcome

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { makeDialogDraggable } from 'dialog-draggable';
import { cell } from 'ember-resources';

import { default as Header } from './header';

import { ButtonsLeft } from './buttons-left';
import { DialogHelp } from './dialog-help';
import { DialogLogin } from './dialog-login'
import { DialogText } from './dialog-text';
import { MenuMain } from './menu-main';

import { dialogLoginId } from './dialog-login';

const returnValue = cell('');

makeDialogDraggable();

// Detect closing Click outside menuMain (tricky case!)
document.addEventListener('mousedown', (event) => {
  var tmp0 = document.getElementById('menuButton');
  var tmp1 = document.getElementById('menuMain');
  if (tmp1.style.display !== 'none' && event.target !== tmp0 && event.target !== tmp1 && !tmp0.contains(event.target) && !tmp1.contains(event.target)) {
    tmp0.innerHTML = '<span class="menu">☰</span>';
    tmp1.style.display = 'none';
    console.log('?: closed main menu');
  }
});

class Welcome extends Component {
  @service('common-storage') z;

  @action async init(user) {
    if (user) {
      this.z.userName = user;
    }
    this.z.loli(this.z.userName);
    this.z.openModalDialog(dialogLoginId, 0);
    // await new Promise (z => setTimeout (z, 50));
  }

  @action toggleBackg() {
    if (this.z.bkgrColor === '#cbcbcb') {
      this.z.bkgrColor = '#000';
    } else {
      this.z.bkgrColor = '#cbcbcb';
    }
    this.z.loli(this.z.bkgrColor);
  }

  <template>
    {{! Html inserted here will appear beneath the buildStamp div }}
    <h1 style="margin:0 0 0 4rem;display:inline">{{t "header"}}</h1>

    <a class="proid toggbkg" style="margin:0.5em 0 0 0.7em" title="" {{on 'click' (fn this.toggleBackg)}}><small>MÖRK/LJUS</small></a>

    <button type="button" {{on 'click' (fn this.init 'guest')}}>{{t 'button.login'}}</button>

    <Header />
    <DialogLogin />
    <MenuMain />
    <ButtonsLeft />
    <DialogHelp />
    <DialogText />
  </template>;
}
export default Welcome;
