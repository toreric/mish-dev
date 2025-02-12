import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import { dialogAlertId } from './dialog-alert';
export const dialogChooseId = 'dialogChoose';

export class DialogChoose extends Component {
  @service('common-storage') z;
  @service intl;

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogAlertId).open) this.z.closeDialog(dialogAlertId);
      if (document.getElementById(dialogChooseId).open) this.z.closeDialog(dialogChooseId);
    }
  }

  <template>
   <dialog id="dialogChoose" style="max-width:36rem;z-index:999" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <div style="width:99%">
          <p style="color:blue">{{{this.z.infoHeader}}}<span></span></p>
        </div><div>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogChooseId)}}>×</button>
        </div>
      </header>
      <main draggable="false" ondragstart="return false">

      {{!-- <RefreshThis @for={{this.z.numMarked}}> --}}
        <p style="padding:1rem;font-weight:bold;color:blue">{{{this.z.chooseText}}}</p>
      {{!-- </RefreshThis> --}}

      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.selectChoice 1)}}>{{t 'button.ok'}}</button>&nbsp;
        <button autofocus type="button" {{on 'click' (fn this.z.selectChoice 2)}}>{{t 'button.cancel'}}</button>
      </footer>
    </dialog>
  </template>
}
