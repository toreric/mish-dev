//== Mish dialog for image searches (in texts: captions etc.)

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
    if (document.getElementById('dialogFindHelp').open) {
      document.getElementById('dialogFindHelp').close();
      console.log('-"-: closed dialogFindHelp');
    } else if (document.getElementById(dialogFindId).open) {
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
      if (document.getElementById('dialogFindHelp').open) {
        this.z.closeDialog('dialogFindHelp');
      } else if (document.getElementById(dialogFindId).open) {
        this.z.closeDialog(dialogFindId);
      }
    }
  }

  findit = () => {
    this.z.loli('findit', 'color:red');
  }
  <template>

    <div style="display:flex" {{on 'keydown' this.detectEscClose}}>

      <dialog id='dialogFind' style="width: min(calc(100vw - 1rem),700px)">
        <header data-dialog-draggable >
          <p>&nbsp;</p>
          <p><b>{{t 'dialog.find.header'}}</b> <span></span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogFindId)}}>×</button>
        </header>
        <main>

          <textarea name="searchtext" placeholder="{{t 'write.searchTerms'}}" style="width:calc(100% - 8px)" rows="4"></textarea>

          <div class="diaMess">
            <div class="edWarn" style="font-weight:normal;text-align:right"></div>
            <div class="srchIn"> {{t 'write.find0'}}&nbsp;
              <span class="glue">
                <input id="t1" name="search1" value="description" checked="" type="checkbox">
                <label for="t1">&nbsp;{{t 'write.find1'}}</label>&nbsp;
              </span>
              <span class="glue">
                <input id="t2" name="search2" value="creator" checked="" type="checkbox">
                <label for="t2">&nbsp;{{t 'write.find2'}}</label>&nbsp;
              </span>
              <span class="glue" style="display: none;">
                <input id="t3" name="search3" value="source" type="checkbox">
                <label for="t3">&nbsp;{{t 'write.find3'}}</label>&nbsp;
              </span>
              <span class="glue">
                <input id="t4" name="search4" value="album" checked="" type="checkbox">
                <label for="t4">&nbsp;{{t 'write.find4'}}</label>&nbsp;
              </span>
              <span class="glue">
                <input id="t5" name="search5" value="name" checked="" type="checkbox">
                <label for="t5">&nbsp;{{t 'write.find5'}}</label>
              </span>
            </div>
            <div class="orAnd">{{t 'write.find6'}} &nbsp; &nbsp;
                <a class="hoverDark" style="font-family:sans-serif;font-variant:all-small-caps" tabindex="-1" {{on 'click' (fn this.z.toggleDialog 'dialogFindHelp')}}>{{t 'searchHelp'}}</a>
              <br>{{t 'write.find7'}}<br>
              <span class="glue">
                <input id="r1" name="searchmode" value="AND" checked="" type="radio">
                <label for="r1">{{{t 'write.find8'}}}</label>
              </span>&nbsp;
              <span class="glue">
                <input id="r2" name="searchmode" value="OR" type="radio">
                <label for="r2">{{{t 'write.find9'}}}</label>
              </span>
            </div>
          </div>

        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.findit)}}>{{t 'button.findIn'}} <b>{{this.z.imdbRoot}}</b></button>&nbsp;
          <button type="button" {{on 'click' (fn this.z.closeDialog dialogFindId)}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

      <dialog id='dialogFindHelp' style="width:min(calc(100vw - 2rem),450px)">
        <header data-dialog-draggable>
          <p>&nbsp;</p>
          <p>{{t 'write.findHelpHeader'}} <span></span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog 'dialogFindHelp')}}>×</button>
        </header>
        <main style="padding:0 0.5rem 0 1rem;height:20rem" width="99%">

          <p style="padding-top:0.3em"><strong>{{{t 'write.findHelp0'}}}</strong> <br> </p>
          <p>
            {{{t 'write.findHelp1'}}}
          </p>
          <p>
            {{{t 'write.findHelp2'}}}
          </p>
          <p>
            {{{t 'write.findHelp3'}}}
          </p>
          <p>
            {{{t 'write.findHelp4'}}}
          </p>
          <p>
            {{{t 'write.findHelp5'}}}
          </p>
          <p>
           {{{t 'write.findHelp6'}}}
          </p>

        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.z.closeDialog 'dialogFindHelp')}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

    </div>

  </template>
}
