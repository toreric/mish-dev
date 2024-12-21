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

  @tracked notPicFound = true;
  @tracked tool = '';

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogUtilId).open) this.z.closeDialog(dialogUtilId);
    }
  }

  detectRadio = (e) => {
    const elRadio = e.target.closest('[type="radio"]');
    if (!elRadio) return; // Not a radio element
    console.log(`${elRadio.id} ${elRadio.checked}`);
    this.tool = elRadio.id;
  }

  get picFound() {
    return this.z.picFound;
  }

  get imdbDir() {
    // Reset all at album change
    this.tool = '';
    let elRadio = document.querySelectorAll('#dialogUtil input[type="radio"]');
    for (let i=0; i<elRadio.length; i++) {
      elRadio[i].checked = false;
    }
    return this.z.imdbDir.slice(1);
  }

  <template>
    <dialog id="dialogUtil" style="width:min(calc(100vw - 2rem),auto)" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <p>&nbsp;</p>
        <p><b>{{t 'write.utilHeader'}} <span>{{this.z.imdbDirName}}</span></b></p>
        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>×</button>
      </header>
      <main style="padding:0.5rem 0.75rem;height:20rem" width="99%">
        {{!-- <RefreshThis @for={{this.z.imdbDir}}> --}}
        <div style="line-height:1.4rem">{{t 'write.tool0'}}<br>
          {{#if (eq this.imdbDir this.picFound)}}
            {{!-- skip if 'found album' --}}
          {{else if (eq this.imdbDir '')}}
            {{!-- skip if 'root album' --}}
          {{else}}
            <span class="glue">
              <input id="util1" name="searchmode" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util1"> &nbsp;{{{t 'write.tool1' album=this.z.imdbDirName}}}</label>
            </span><br>
          {{/if}}
          {{#if (eq this.imdbDir this.picFound)}}
            {{!-- skip if 'found album' --}}
          {{else}}
            <span class="glue" style="padding-bottom:0.5rem">
              <input id="util2" name="searchmode" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util2"> &nbsp;{{{t 'write.tool2' album=this.z.imdbDirName}}}</label>
            </span>
          {{/if}}
        </div>
        <Utility @tool={{this.tool}} @album={{this.z.imdbDirName}} />
        {{!-- </RefreshThis> --}}
      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>{{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>

}

const Utility = <template>
  <div style="line-height:1.4rem">
    {{!-- The album tool is {{@tool}}:<br> --}}
    {{#if (eq @tool '')}}
      No tool chosen, choose one!
    {{else if (eq @tool 'util1')}}
      Delete {{@album}}
    {{else if (eq @tool 'util2')}}
      Create a     subalbum to {{@album}}
    {{/if}}
  </div>
</template>
