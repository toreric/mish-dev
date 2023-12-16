// eslint-disable-next-line no-unused-vars
//import Component from '@glimmer/component';

//import { fn } from '@ember/helper';
//import { on } from '@ember/modifier';
import { makeDialogDraggable } from 'dialog-draggable';
//import focusTrap from 'ember-focus-trap/modifiers/focus-trap';
//import { Modal } from 'ember-primitives';
import { cell } from 'ember-resources';

//import { DialogText, dialogTextId, openModalDialog } from './dialog-text';
import { DialogText } from './dialog-text';
import { Header } from './header'

// eslint-disable-next-line no-unused-vars
const returnValue = cell('');

makeDialogDraggable();

export var imageId = 'IMG_1234a_2023_november_19'; // dummy
//imageId = 'IMG_1234a'; // dummy

const Welcome = <template>
  <Header />
  <DialogText />
</template>;

export default Welcome;
