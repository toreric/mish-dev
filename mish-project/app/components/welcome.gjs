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
// import { CommonStorage } from './common-storage';
import { DialogHelp } from './dialog-help';
import { DialogLogin } from './dialog-login'
import { DialogText } from './dialog-text';
import { MenuMain } from './menu-main';

import { openDialog } from './dialog-functions'
import { openModalDialog } from './dialog-functions'
import { toggleDialog } from './dialog-functions'
import { dialogLoginId } from './dialog-login';
import { loli } from './common-functions';

const returnValue = cell('');

makeDialogDraggable();

// const Welcome =
// export class Welcome extends Component {
class Welcome extends Component {
  @service('common-storage') z;
  @action init(user) {
    if (user) {
      this.z.setUserName(user);
    }
    openModalDialog(dialogLoginId, 0);
    loli(this.z.picFound);
  }


<template>
  <div id="userName" style="display:none"> </div>
  {{! Html inserted here will appear beneath the buildStamp div }}
  <h1 style="margin:0 0 0 4rem;display:inline">{{t "header"}}</h1>
  <button type="button" {{on 'click' (fn this.init 'guest')}}>{{t 'button.login'}}</button>

  <!--CommonStorage /-->
  <Header />
  <DialogLogin />
  <MenuMain />
  <ButtonsLeft />
  <DialogHelp />
  <DialogText />
</template>;
}
export default Welcome;
