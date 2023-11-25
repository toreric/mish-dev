// eslint-disable-next-line no-unused-vars
import Component from '@glimmer/component';
// eslint-disable-next-line no-unused-vars
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

import { makeDialogDraggable } from 'dialog-draggable';
//import focusTrap from 'ember-focus-trap/modifiers/focus-trap';
// eslint-disable-next-line no-unused-vars
import { Modal } from 'ember-primitives';
import { cell } from 'ember-resources';

import { Clock } from './clock';
import { DialogText, dialogTextId, openModalDialog } from './dialog-text';
import { Excite } from './excite';

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

const Header = <template>
  <h1>Welcome to Mish, Polaris revision</h1>
  <Excite />
  <p>The time is <span>{{Clock}}</span></p>
  <p><button type="button" {{on 'click' (fn openDialog dialogTextId 0)}}>Open text dialog</button><button type="button" {{on 'click' (fn openDialog dialogTextId 1)}}>... in original position</button>
  &nbsp;
  <button type="button" {{on 'click' (fn toggleDialog dialogTextId 0)}}>Toggle text dialog</button>
  &nbsp;
  <button type="button" {{on 'click' (fn openModalDialog dialogTextId 1)}}>Open modal text dialog</button>
  </p>
</template>;


//== Dialog open/toggle

function openDialog(dialogTextId, origPos) {
  let diaObj = document.getElementById(dialogTextId);

  diaObj.show();
  if (origPos) diaObj.style = '';
  // eslint-disable-next-line no-console
  console.log(dialogTextId + ' opened');
}

function toggleDialog(dialogTextId, origPos) {
  let diaObj = document.getElementById(dialogTextId);
  let what = ' closed';

  if (diaObj.hasAttribute("open")) {
    diaObj.close();
  } else {
    what = ' opened';
    if (origPos) diaObj.style = '';
    diaObj.show();
  }

  // eslint-disable-next-line no-console
  console.log(dialogTextId + what);
}
