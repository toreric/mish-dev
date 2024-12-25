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
  // @tracked imdbDirName = this.z.handsomize2sp(this.z.imdbDirName);

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogUtilId).open) this.z.closeDialog(dialogUtilId);
    }
  }

  detectRadio = (e) => {
    const elRadio = e.target.closest('input[type="radio"]');
    if (!elRadio) return; // Not a radio element
    console.log(`${elRadio.id} ${elRadio.checked}`);
    this.tool = elRadio.id;
  }

  get imdbDir() {
    // Reset all at album change
    this.tool = '';
    let elRadio = document.querySelectorAll('#dialogUtil input[type="radio"]');
    for (let i=0; i<elRadio.length; i++) {
      elRadio[i].checked = false;
    }
    // and remove slash (except root: already empty)
    return this.z.imdbDir.slice(1);
  }

  get imdbDirName() {
    return this.z.handsomize2sp(this.z.imdbDirName);
  }

  get label() {
    let text = document.querySelector('#dialogUtil label[for=' + this.tool + ']').innerTHTML;
      this.z.loli(this.tool + ': ' + text, 'color:red');
    return text;
  }

  get okDelete() { // true if delete allowed
    let noroot = this.imdbDir.length > 0;
    let nofind = this.imdbDir !== this.z.picFound;
    return noroot && nofind;
  }

  get okSubalbum() { // true if subalbums allowed
    return this.imdbDir !== this.z.picFound;
  }

  get okSort() { // true if sorting by name is allowed
    return true;
  }

  <template>
    <dialog id="dialogUtil" style="width:min(calc(100vw - 2rem),auto)" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <p>&nbsp;</p>
        <p><b>{{t 'write.utilHeader'}} <span>{{{this.imdbDirName}}}</span></b><br>({{this.z.imdbRoot}}{{this.z.imdbDir}})</p>
        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>×</button>
      </header>
      <main style="padding:0 0.75rem;height:20rem" width="99%">
        {{!-- <RefreshThis @for={{this.z.imdbDir}}> --}}
        <div style="padding:0.5rem 0;line-height:1.4rem">{{{t 'write.tool0' album=this.imdbDirName}}}<br>
          {{#if this.okDelete}}
            <span class="glue">
              <input id="util1" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util1"> &nbsp;{{t 'write.tool1'}}</label>
            </span><br>
          {{/if}}
          {{#if this.okSubalbum}}
            <span class="glue">
              <input id="util2" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util2"> &nbsp;{{t 'write.tool2'}}</label>
            </span><br>
          {{/if}}
          {{#if this.okSort}}
            <span class="glue">
              <input id="util3" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util3"> &nbsp;{{t 'write.tool3'}}</label>
            </span><br>
          {{/if}}
              <span class="glue">
              <input id="util4" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util4"> &nbsp;{{t 'write.tool4'}}</label>
            </span><br>
        </div>
        <div style="padding:0.5rem 0;line-height:1.4rem">
          {{#if (eq this.tool '')}}
            No tool chosen, choose one!
          {{else if (eq this.tool 'util1')}}
              {{this.imdbDirName}} ({{this.z.imdbRoot}}{{this.z.imdbDir}})<br>{{t 'write.tool1'}}
            {{#if (eq this.z.numImages 0)}}
              – {{t 'write.isEmpty'}}
            {{else}}
              <br><span style="color:blue">{{t 'write.notEmpty'}}</span>
            {{/if}}
          {{else if (eq this.tool 'util2')}}
            {{this.imdbDirName}} ({{this.z.imdbRoot}}{{this.z.imdbDir}})<br>{{t 'write.tool2'}}
          {{else if (eq this.tool 'util3')}}
            {{this.imdbDirName}} ({{this.z.imdbRoot}}{{this.z.imdbDir}})<br>{{t 'write.tool3'}}
          {{else if (eq this.tool 'util4')}}
            {{this.imdbDirName}} ({{this.z.imdbRoot}}{{this.z.imdbDir}})<br>{{t 'write.tool4'}}
          {{else}}
            {{this.imdbDirName}} ({{this.z.imdbRoot}}{{this.z.imdbDir}})<br>{{t 'write.tool99'}}
          {{/if}}
        </div>
        {{!-- </RefreshThis> --}}
      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>{{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>

}
