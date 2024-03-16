//== Mish main component Welcome

import Component from '@glimmer/component';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { makeDialogDraggable } from 'dialog-draggable';
import { cell } from 'ember-resources';

import { default as Header } from './header';

import { ButtonsLeft } from './buttons-left';
import { CommonStorage } from './common-storage';
import { DialogHelp } from './dialog-help';
import { DialogLogin } from './dialog-login'
import { DialogText } from './dialog-text';
import { MenuMain } from './menu-main';

import { openDialog } from './dialog-functions'
import { openModalDialog } from './dialog-functions'
import { toggleDialog } from './dialog-functions'
import { dialogLoginId } from './dialog-login';
//import { logIn } from './common-storage';

// eslint-disable-next-line no-unused-vars
const returnValue = cell('');

makeDialogDraggable();

export var userName = 'tore';
export function loli(text) { // loli = log list
  console.log(userName, text);
}
export var imageId = 'IMG_1234a_2023_november_19'; // dummy
//imageId = 'IMG_1234a'; // dummy

const Welcome = <template>
  {{! Html inserted here will appear beneath the buildStamp div }}
  <h1 style="margin:0 0 0 4rem;display:inline">{{t "header"}}</h1>

  <button type="button" {{on 'click' (fn openModalDialog dialogLoginId 0)}}>{{t 'button.login'}}</button>

  <!--CommonStorage /-->
  <Header />
  <DialogLogin />
  <MenuMain />
  <ButtonsLeft />
  <DialogHelp />
  <DialogText />
</template>;

export default Welcome;
