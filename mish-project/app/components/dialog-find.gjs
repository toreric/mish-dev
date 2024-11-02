//== Mish dialogs for image texts (captions etc.)

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { TrackedAsyncData } from 'ember-async-data';

import RefreshThis from './refresh-this';

// Note: Dialog-functions in Header needs dialogFindId:
export const dialogFindId = 'dialogFind';

document.addEventListener('mousedown', async (e) => {
  e.stopPropagation();
});

document.addEventListener('keydown', async (e) => {
  if (e.keyCode === 27) {
    e.stopPropagation();
    if (document.getElementById(dialogFindId).open) {
      document.getElementById(dialogFindId).close();
      console.log('-"-: closed ' + dialogFindId);
    }
  }
});

//== Component DialogFind with <dialog> tags
export class DialogFind extends Component {
  @service('common-storage') z;
  @service intl;

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogFindId).open) this.z.closeDialog(dialogFindId);
    }
  }

  findit = () => {
    this.z.loli('findit', 'color:red');
  }
  <template>
    <div style="display:flex" {{on 'keydown' this.detectEscClose}}>

      <dialog id='dialogFind'>
        <header data-dialog-draggable >
          <p>&nbsp;</p>
          <p><b>{{t 'dialog.find.header'}}</b> <span>{{t 'dialog.find.nolinks'}}</span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogFindId)}}>×</button>
        </header>
        <main>

          <textarea name="searchtext" placeholder="Skriv här sökbegrepp, åtskilda av blanktecken, små/stora bokstäver oviktigt (välj nedan texter du vill söka i)" rows="4" style="min-width:700px;width: 635px;"></textarea>

        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.findit)}}>{{t 'button.findIn'}} <b>{{this.z.imdbRoot}}</b></button>&nbsp;
          <button type="button" {{on 'click' (fn this.z.closeDialog dialogFindId)}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

    </div>
  </template>
}
