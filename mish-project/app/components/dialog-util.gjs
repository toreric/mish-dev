//== Mish dialog for various purposes

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { cached } from '@glimmer/tracking';

import RefreshThis from './refresh-this';

export const dialogUtilId = 'dialogUtil';
const LF = '\n';


export class DialogUtil extends Component {
  @service('common-storage') z;
  @service intl;

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogUtilId).open) this.z.closeDialog(dialogUtilId);
    }
  }

  selUtil = () => {
    let choices = document.querySelectorAll('#dialogUtil input[type="radio"]');
    console.log('choices:', choices);
    return 'atool';
  }

  <template>
    <dialog id="dialogUtil" style="width:min(calc(100vw - 2rem),450px)">
      <header data-dialog-draggable>
        <p>&nbsp;</p>
        <p><b>{{t 'write.utilHeader'}} <span>{{this.z.imdbDirName}}</span></b></p>
        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>×</button>
      </header>
      <main style="padding:0 0.5rem 0 1rem;height:20rem" width="99%">
        <div class="diaMess">
        <div class="orAnd">{{t 'write.find6'}} &nbsp; &nbsp;
          <br>{{t 'write.find7'}}<br>
          <span class="glue">
            <input id="r1" name="searchmode" value="AND" checked="" type="radio">
            <label for="r1">{{{t 'write.find8'}}}</label>
          </span>&nbsp;
          <span class="glue" style="padding-bottom:0.5rem">
            <input id="r2" name="searchmode" value="OR" type="radio">
            <label for="r2">{{{t 'write.find9'}}}</label>
          </span>
        </div>
        </div>
        <Utility @util={{this.selUtil}} />
      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>{{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>

}

const Utility = <template>
    <div style="padding:0 0.5rem 0 1rem;height:20rem" width="99%">

      {{#if (eq this.selUtil 'atool')}}
        This is the album tool
      {{else}}
        This is another tool
      {{/if}}

    </div>
</template>


