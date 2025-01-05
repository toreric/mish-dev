//== Mish experimental dialog
//   Referenced in 'welcome.gjs'

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { htmlSafe } from '@ember/template';
import { MenuImage } from './menu-image';

// import sortableGroup from 'ember-sortable/modifiers/sortable-group';
// import sortableItem from 'ember-sortable/modifiers/sortable-item';

export const dialogXperId = 'dialogXper';
const LF = '\n';


export class DialogXper extends Component {
  @service('common-storage') z;
  @service intl;

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogXperId).open) this.z.closeDialog(dialogXperId);
    }
  }

  toggleTmpHeader = () => {
    let elem = document.querySelector('.tmpHeader');
    let disp = 'none';
    if (elem.style.display) {
      disp = '';
    }
    for(elem of document.querySelectorAll('.tmpHeader')) elem.style.display = disp;
  }

  updateOrder = (n) => {
    if (n === 1) {
      this.z.loli(LF + 'ORIGINALLY LOADED' + LF + this.z.sortOrder, 'color:pink');
    } else if (n === 2) {
      let tmp = this.z.updateOrder();
      this.z.loli(LF + 'ACTUAL IF SAVED' + LF + tmp, 'color:lightcoral');
    }
  }

  <template>
    <dialog id="dialogXper" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <div style="width:99%">
          <p>Experimental dialog<span></span></p>
        </div>
        <div>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>×</button>
        </div>
      </header>
      <main style="text-align:center" style="text-align:center;min-height:10rem">

      <div id="_this_is_no_image" style="position:relative">
        <br>
          {{@content}}
        <br>  <br>
        <button type="button" {{on 'click' this.toggleTmpHeader}}>
          Dölj/visa testkomponenten '&lt;Header /&gt;'
        </button>
        <br>
        <button type="button" {{on 'click' (fn this.updateOrder 1)}}>
          sortOrder
        </button>
        <button type="button" {{on 'click' (fn this.updateOrder 2)}}>
          Ny sortOrder
        </button>
        <div style="display:flex;justify-content:center">
          <div title-2="Här visas CSS: title-2">
          <br>&nbsp; <br>
            För visning av<br>CSS: title-2
          </div>
        </div>
        <br>
        <br>
        <br>
        <br>
      </div>

      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>{{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>
}
