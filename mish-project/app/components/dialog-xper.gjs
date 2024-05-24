//== Mish experimental dialog

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { DTree } from './dtree';

export const dialogXperId = "dialogXper";

export class DialogXper extends Component {
  @service('common-storage') z;

  // Detect closing Esc key
  detectEscClose = (e) => {
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogXperId).open) this.z.closeDialog(dialogXperId);
    }
  }

  <template>

  <dialog id="dialogXper" {{on 'keydown' this.detectEscClose}}>
    <header data-dialog-draggable>
      <div style="width:99%">
        <p>Experimental dialog<span></span></p>
      </div><div>
        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>×</button>
      </div>
    </header>
    <main>
      <p>Mish experimental dialog</p>
      <h2>Example</h2>
      <div class="dtree">
        <DTree />
      </div>
    </main>
    <footer data-dialog-draggable>
      <button type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>{{t 'button.close'}}</button>&nbsp;
    </footer>
  </dialog>

  </template>
}
