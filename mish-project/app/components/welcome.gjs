//== Mish main component Welcome

import Component from '@glimmer/component';
//import { fn } from '@ember/helper';
//import { on } from '@ember/modifier';
import { makeDialogDraggable } from 'dialog-draggable';
import { cell } from 'ember-resources';

import { default as Header } from './header'

import { ButtonsLeft } from './buttons-left';
import { MenuMain } from './menu-main';
import { DialogText } from './dialog-text';
import { DialogHelp } from './dialog-help';

// eslint-disable-next-line no-unused-vars
const returnValue = cell('');

makeDialogDraggable();

export var imageId = 'IMG_1234a_2023_november_19'; // dummy
imageId = 'IMG_1234a'; // dummy

const Welcome = <template>
  <Header />
  <ButtonsLeft />
  <MenuMain />
  <DialogHelp />
  <DialogText />
</template>;

export default Welcome;
