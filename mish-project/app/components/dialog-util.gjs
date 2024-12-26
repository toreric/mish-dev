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

  @tracked tool = ''; // utility tool id
  @tracked noTools = true; // no tool flag

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
      // this.z.loli(`${elRadio.id} ${elRadio.checked}`, 'color:red');
    this.tool = elRadio.id;
  }

  clearInput = () => {
    let elem = document.querySelector('#newAlbNam');
    elem.value = '';
    elem.style.background = '#f0f0b0';
    elem.focus();
  }

  get imdbDir() {
    // Reset all at album change
    this.tool = '';
    this.noTools = true;
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

  // Shoud be first called from the template, RESETS with this.imdbDir:
  get okDelete() { // true if delete allowed
    let found = this.imdbDir === this.z.picFound;
    if (found || !this.z.imdbDir) { // root == ''
      return false;
    } else {
      this.noTools = false;
      return true;
    }
  }

  get okSubalbum() { // true if subalbums allowed
    if (this.z.imdbDir.slice(1) === this.z.picFound) {
      return false;
    } else {
      this.noTools = false;
      return true;
    }
  }

  get okSort() { // true if sorting by name is allowed
    if (this.z.numImages > 1) {
      this.noTools = false;
      return true;
    } else {
      return false;
    }
  }

  get okNameDups() { // true if at root to search the collection
    if (this.z.imdbDir) {
      return false;
    } else {
      this.noTools = false;
      return true;
    }
  }

  doDelete = () => {
    this.z.alertMess(this.intl.t('futureFacility'))
  }

  doSort = () => {
    this.z.alertMess(this.intl.t('futureFacility'))
  }

  doSubalbum = (n) => {
    let elem = document.getElementById('newAlbNam');
    elem.focus();
    let name = elem.value;
    // Buttons 'continue' and 'make-album'
    let bucont = document.querySelector('#newAlbNam + a + br + button');
    let bumake = document.querySelector('#newAlbNam + a + br + button + button');
    if (n === 1) { // continue
      name = name.trim().replace(/ +/g, '_');
      elem.value = name;
      if (name && this.z.acceptedDirName(name)) {
        elem.style.background = '#dfd'; // green
        bucont.setAttribute('disabled', true);
        bumake.removeAttribute('disabled');
      } else {
        elem.style.background = 'pink'; // reddish
        bumake.setAttribute('disabled', true);
      }
    }
    if (n > 1) { // reset
      bucont.removeAttribute('disabled');
      bumake.setAttribute('disabled', true);
      elem.style.background = '#f0f0b0'; // yellow
      if (n === 3) { // make
        this.z.alertMess('"' + document.getElementById('newAlbNam').value + '"');
      }
    }
  }

  doDupnames = () => {
    this.z.alertMess(this.intl.t('futureFacility'))
  }

  get notEmpty() { // true if the album is empty
    return this.z.subaIndex.length > 0 || this.z.numImages > 0;
  }

  <template>
    <dialog id="dialogUtil" style="width:min(calc(100vw - 2rem),auto)" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <p>&nbsp;</p>
        <p><b>{{t 'write.utilHeader'}} <span>{{{this.imdbDirName}}}</span></b><br>({{this.z.imdbRoot}}{{this.z.imdbDir}})</p>
        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>×</button>
      </header>
      <main style="padding:0 0.75rem;max-height:24rem" width="99%">

        {{!-- <RefreshThis @for={{this.z.imdbDir}}> --}}
        <div style="padding:0.5rem 0;line-height:1.4rem">
          {{{t 'write.tool0' album=this.imdbDirName}}}<br>
          {{#if this.okDelete}}
            <span class="glue">
              <input id="util1" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util1"> &nbsp;{{t 'write.tool1'}}</label>
            </span><br>
          {{/if}}
          {{#if this.okSubalbum}}
            <span class="glue">
              <input id="util2" name="albumUtility" value="" type="radio" autofocus {{on 'click' this.detectRadio}}>
              <label for="util2"> &nbsp;{{t 'write.tool2'}}</label>
            </span><br>
          {{/if}}
          {{#if this.okSort}}
            <span class="glue">
              <input id="util3" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util3"> &nbsp;{{t 'write.tool3'}}</label>
            </span><br>
          {{/if}}
          {{#if this.okNameDups}}
            <span class="glue">
              <input id="util4" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util4"> &nbsp;{{t 'write.tool4'}}</label>
            </span><br>
          {{/if}}
        </div>

        <div style="padding:0.5rem 0;line-height:1.4rem">
          {{#if this.noTools}}
            <span style="color:blue">{{t 'write.tool99'}}</span>

          {{else if (eq this.tool '')}}
            {{t 'write.chooseTool'}}

          {{!-- === Delete the album === --}}
          {{else if (eq this.tool 'util1')}}
              <b>{{t 'write.tool1'}}</b>
            {{#if this.notEmpty}}
              <br><span style="color:blue">{{t 'write.notEmpty'}}</span>
            {{else}}
              – {{t 'write.isEmpty'}}<br>
              <button type="button" {{on 'click' (fn this.doDelete)}}>{{{t 'button.delete' name=this.imdbDirName}}}</button>
            {{/if}}

          {{!-- === Make a new subalbum === --}}
          {{else if (eq this.tool 'util2')}}
            <b>{{t 'write.tool2'}}</b><br>

            <input id="newAlbNam" type="text" class="cred user nameNew" size="36" title="" placeholder="{{t 'write.albumName'}}" style="margin:0.2rem 0 0.5rem 0" {{on 'keydown' (fn this.doSubalbum 2)}}><a title={{t 'erase'}} {{on 'click' (fn this.clearInput)}}> ×&nbsp;</a><br>

            <button type="button" {{on 'click' (fn this.doSubalbum 1)}}>{{t 'button.continue'}}</button>
            <button type="button" {{on 'click' (fn this.doSubalbum 3)}} disabled>{{t 'button.dosub'}}</button>

          {{!-- === Sort images by names === --}}
          {{else if (eq this.tool 'util3')}}
            <b>{{t 'write.tool3'}}</b>
            <form style="line-height:1.4rem">
              <span class="glue">
                <input id="util31" name="albumUtility" value="" type="radio" checked>
                <label for="util31"> &nbsp;{{t 'write.tool31'}}</label>
              </span><br>
              <span class="glue">
                <input id="util32" name="albumUtility" value="" type="radio">
                <label for="util32"> &nbsp;{{t 'write.tool32'}}</label>
              </span>
            </form>

            <button type="button" {{on 'click' (fn this.doSort)}}>{{t 'button.sort'}}</button>

          {{!-- === Find duplicate image names === --}}
          {{else if (eq this.tool 'util4')}}
            <b>{{t 'write.tool4'}}</b><br>

            <button type="button" {{on 'click' (fn this.doDupnames)}}>{{t 'button.findDupNames'}}</button>

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
