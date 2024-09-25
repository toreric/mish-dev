

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { htmlSafe } from '@ember/template';
import { MenuImage } from './menu-image';

export const dialogInfoId = "dialogInfo";
const LF = '\n';

export class DialogInfo extends Component {
  @service('common-storage') z;
  @service intl;

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogInfoId).open) this.z.closeDialog(dialogInfoId);
    }
  }

  infotext = () => {
    return this.z.infoMessage;
  }

  <template>
    <dialog id="dialogInfo" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <div style="width:99%">
          <p>Information om originalbildfilen<span></span></p>
        </div>
        <div>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogInfoId)}}>×</button>
        </div>
      </header>
      <main style="padding:1rem;text-align:center;min-height:10rem;color:blue">
        {{{this.infotext}}}
      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogInfoId)}}>{{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>
}
