//== Mish experimental dialog

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

export const dialogXperId = "dialogXper";

export class DialogXper extends Component {
  @service('common-storage') z;
  @service intl;

  // get tree() {
  //   // this.z.loli(JSON.stringify(this.z.imdbTree, null, 2));
  //   return this.args.tree ?? this.z.imdbTree;
  // }

  // Detect enter key in input field
  detectOpenEnter = (e) => {
    if (e.keyCode === 13) { // Enter key
      let etv = e.target.value;
      if (!etv || Number(etv) > this.aMax) return;
      if (!this.z.imdbRoot) {
        this.z.alertMess(this.intl.t('needaroot'));
        document.activeElement.blur();
        e.target.style.zIndex = 999;
        this.z.toggleMainMenu();
        document.querySelector('.mainMenu select').focus();
        return;
      }
      this.z.openAlbum(etv);
      this.z.toggleMainMenu();
      // This below may finally be removed
      // document.querySelector('.albumTree').style.display = '';
      // document.querySelector('.mainMenu select').blur();
    }
  }

  // Detect closing Esc key
  detectEscClose = (e) => {
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogXperId).open) this.z.closeDialog(dialogXperId);
    }
  }

  // Max index of albums
  get aMax() {
    let i = this.z.imdbDirs.length;
    if (i > 0) return i - 1;
    return 0;
  }

  <template><dialog id="dialogXper" {{on 'keydown' this.detectEscClose}}>
    <header data-dialog-draggable>
      <div style="width:99%">
        <p>Experimental dialog<span></span></p>
      </div><div>
        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>×</button>
      </div>
    </header>
    <main>
      <p>Mish experimental dialog Mish experimental dialog</p>
      Open album number
      <input type="number" pattern="[0-9]+" min="0" max={{this.aMax}} style="width:3rem" required autofocus {{on 'keydown' this.detectOpenEnter}}>
      <br><br>
    </main>
    <footer data-dialog-draggable>
      <button type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>{{t 'button.close'}}</button>&nbsp;
    </footer>
  </dialog></template>
}
