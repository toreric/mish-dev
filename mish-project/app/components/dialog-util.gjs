//== Mish dialog for various purposes

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { cached } from '@glimmer/tracking';

export const dialogUtilId = 'dialogUtil';
const LF = '\n';

export class DialogUtil extends Component {
  @service('common-storage') z;
  @service intl;

  @tracked tool = ''; // utility tool id
  @tracked noTools = true; // no tool flag
  @tracked countImgs = 0; // duplicate image name counter

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

  // Reset all at album change. Called from okDelete, which is the first
  // of 'ok...' checks called from the template. 'imdbDir' is used for
  // resetting before the simple return of the sliced imdbDir value:
  get imdbDir() { // this.imdbDir
    this.tool = '';
    this.noTools = true;
    let elRadio = document.querySelectorAll('#dialogUtil input[type="radio"]');
    for (let i=0; i<elRadio.length; i++) {
      elRadio[i].checked = false;
    }
    // remove initial slash (except root: already empty)
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

  // This button is inserted into alertMess when browser reload is required.
  // Then alertMess cannot be closed by closeDialog (but with closeDialogs!).
  get restart() {
    return '<br><div style="text-align:center"><button class="unclosable" type="button" onclick="location.reload(true);return false">' + this.intl.t('button.restart') + '</button></div>'
  }

  // Should be the first called from the template
  // The first and ONLY use of this.imdbDir is here:
  get okDelete() { // true if delete allowed
    let found = this.imdbDir === this.z.picFound;
    if (!found && this.z.imdbDir && this.z.allow.albumEdit) { // root == ''
      this.noTools = false;
      return true;
    } else {
      return false;
    }
  }

  get okTexts() { // true if images shown
      // this.z.loli('numShown ' + this.z.numShown, 'color:red');
    if (this.z.numShown > 0) {
      this.noTools = false;
      return true;
    } else {
      return false;
    }
  }

  get okSubalbum() { // true if subalbums allowed
    if (this.z.imdbDir.slice(1) !== this.z.picFound && this.z.allow.albumEdit) {
      this.noTools = false;
      return true;
    } else {
      return false;
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

  get okDupNames() {
    // true to search the collection if at root, alternatively
    // at any 'node' except picFound, if there is some reason:
    // if (this.z.imdbDir.slice(1) === this.z.picFound) { //malfunction!

    // search only the entire collection from root:
    if (this.z.imdbDir) {
      return false;
    } else {
      this.noTools = false;
      return true;
    }
  }

  get okDupImages() {
    // true to search the collection if at root:
    if (this.z.imdbDir) {
      return false;
    } else {
      this.noTools = false;
      return true;
    }
  }

  get okUpload() {
    if (this.z.imdbDir.slice(1) !== this.z.picFound && this.z.allow.deleteImg) {
      this.noTools = false;
      return true
    } else {
      return false;
    }
  }

  get okDbUpdate() {
    //only at collection root
    if (this.z.imdbDir) {
      return false;
    }
    if (this.z.allow.albumEdit) {
      this.noTools = false;
      return true
    }
  }

  get notEmpty() { // true if the album is empty
    return this.z.subaIndex.length > 0 || this.z.numImages > 0;
  }

  doDelete = async () => {
    // this.z.alertMess(this.intl.t('futureFacility'))
    let cmd = 'rm -rf ' + this.z.imdbPath + this.z.imdbDir;
      // this.z.loli(cmd, 'color:red');
    let msg = await this.z.execute(cmd);
    if (msg) {
      // failure is really not possible with 'rm -rf ...'
      this.z.loli(this.z.imdbRoot + this.z.imdbDir + ': delete failed', 'color:red');
    } else {
      this.z.loli(this.z.imdbRoot + this.z.imdbDir + ' deleted', 'color:lightgreen');
      this.z.alertMess(this.z.imdbRoot + this.z.imdbDir + ' ' + this.intl.t('deleted') + this.intl.t('write.reloadRequired') + this.restart);
    }
  }

  doSort = async () => {
    document.querySelector('img.spinner').style.display = '';
    let minis = document.querySelectorAll('div.miniImgs.imgs div.img_mini');
    let names = [];
    for (let i=0; i<minis.length; i++) {
      names.push(minis[i].id.slice(1));
    }
    // Sort example: a.sort((a,b) => {return a.value - b.value});
    // Applied to text (though exact conformity should also consider equality
    // using a more accurate function that correspondingly returns 1, 0, or -1):
    names.sort((a, b) => {return a.toLowerCase() > b.toLowerCase()});
    // The id for reverse sort radio button is 'util32' (see template)
    if (document.getElementById('util32').checked) names.reverse();
      // console.log(names);

    // When you add an element that is already in the DOM,
    // this element will be moved, not copied.
    let wrap = document.getElementById('imgWrapper');
    for (let i=0; i<minis.length; i++) {
      wrap.appendChild(document.getElementById('i' + names[i]))
    }
    this.z.closeDialogs();
    await new Promise (z => setTimeout (z, 399)); // doSort
    document.querySelector('img.spinner').style.display = 'none';
    this.z.alertMess(this.z.intl.t('write.afterSort')); // TEMPORARY
    this.z.displayNames = 'block';
  }

  doSubalbum = async (n) => {
    let elem = document.getElementById('newAlbNam');
    let name = elem.value;
    // Buttons 'continue' and 'make-album'
    let bucont = document.querySelector('#newAlbNam + a + br + button');
    let bumake = document.querySelector('#newAlbNam + a + br + button + button');
    elem.focus();
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
        let pathNew = this.z.imdbPath + this.z.imdbDir;
        let nameNew = '/' + document.getElementById('newAlbNam').value;
        let cmd = 'mkdir ' + pathNew + nameNew + ' && touch ' + pathNew + nameNew + '/.imdb';
            // this.z.loli(cmd, 'color:red');
        let msg = await this.z.execute(cmd);
        if (msg) {
          // don't show msg: reveals paths
          let mayExist = this.intl.t('mayExist');
          this.z.loli(this.z.imdbRoot + this.z.imdbDir + nameNew + ' not created ' + mayExist, 'color:red');
          this.z.alertMess(this.z.imdbRoot + this.z.imdbDir + nameNew + ' ' + this.intl.t('createfail') + ' ' + mayExist);
        } else {
          this.z.loli(this.z.imdbRoot + this.z.imdbDir + nameNew + ' created', 'color:lightgreen');
          this.z.alertMess(this.z.imdbRoot + this.z.imdbDir + nameNew + ' ' + this.intl.t('created') + this.intl.t('write.reloadRequired') + this.restart);
        }
      }
    }
  }

  doDupNames = async () => {
      // return new Promise (async function (resolve, reject) {
    document.querySelector('img.spinner').style.display = '';
    this.z.closeDialog('dialogUtil');
    let path = this.z.imdbPath + this.z.imdbDir;
    try { // Start try
      let duplist = await this.z.execute('finddupnames 2 ' + path);
        // this.z.loli('\n' + duplist, 'color:brown');
      let paths = duplist.toString().trim().split('\n');
        // this.z.loli('"'+paths[0]+'"', 'color:red');
      if (paths.length === 1 && paths[0].length === 0) paths = [];
        // this.z.loli('paths:', 'color:deeppink');
        // console.log(paths);
      this.countImgs = paths.length;
      let lpath = this.z.imdbPath + '/' + this.z.picFound; // The path to picFound
      // Clean up picFound
      await this.z.execute('rm -rf ' + lpath + '/*');
      await this.z.execute('touch ' + lpath + '/.imdb');
      for (let i=paths.length; i>0; i--) { // work backwards
        let linkfrom = '../' + paths[i-1].replace(/^[^/]*\//, ''); // make relative
        let fname = paths[i-1].replace(/^.*\/([^/]+$)/, '$1'); // clean from catalogs
        // Make a four character random 'intrusion' in the file name
        fname = this.z.addRandom(fname);
          // this.z.loli(fname, 'color:red');
        let linkto = lpath + '/' + fname; // absolute path
        // Create a link to this found image
        let command = 'ln -sf ' + linkfrom + ' ' + linkto;
          // this.z.loli(command, 'color:red');
        await this.z.execute(command);
      }
      this.z.openDialog('dialogDupResult');
      document.querySelector('img.spinner').style.display = 'none';
    } catch (err) {
      console.error('doDupNames of DialogUtil:', err.message);
    } // End try
      // }) // End promise
      // The Promise way makes 'async' superfluous but hides 'this'
  }
  doDupNamesShow = async () => {
    document.querySelector('img.spinner').style.display = '';
    this.z.openAlbum(this.z.picFoundIndex);
    this.z.closeDialog('dialogDupResult');
    await new Promise (z => setTimeout(z, this.countImgs*50 + 99)); // doDupNamesShow
    this.z.displayNames = 'block';
    document.querySelector('img.spinner').style.display = 'none';
  }

  doDupImages = () => {
    this.z.futureNotYet('write.tool7');
  }

  doTexts = () => {
    this.z.futureNotYet('write.tool8');
  }

  doUpload = () => {
    this.z. futureNotYet('write.tool5');
  }

  doDbUpdate = async () => {
    document.querySelector('img.spinner').style.display = '';
    let cmd = './ld_imdb.js -e ' + this.z.imdbPath;
      // this.z.loli(cmd, 'color:red');
    await this.z.execute(cmd);
    document.querySelector('img.spinner').style.display = 'none';
    this.z.loli('uppdated text database');
    this.z.alertMess(this.intl.t('write.dbUpdated'));
  }

  // NOTE, within the <template></template>:
  // *** The utility numbering is not always in sequence ***

  <template>

    <dialog id="dialogUtil" style="width:min(calc(100vw - 2rem),auto);max-width:480px" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <p>&nbsp;</p>
        <p><b>{{t 'write.utilHeader'}} <span>{{{this.imdbDirName}}}</span></b><br>({{this.z.imdbRoot}}{{this.z.imdbDir}})</p>
        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>×</button>
      </header>
      <main style="padding:0 0.75rem;max-height:24rem" width="99%">

        <div style="padding:0.5rem 0;line-height:1.4rem">
          {{{t 'write.tool0' album=this.imdbDirName}}}<br>
          {{!-- This only reference to okDelete resets radio buttons, noTools, etc. --}}
          {{#if this.okDelete}}
            <span class="glue">
              <input id="util1" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util1"> &nbsp;{{t 'write.tool1'}}</label>
            </span>
          {{/if}}
          {{#if this.okTexts}}
            <span class="glue">
              <input id="util8" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util8"> &nbsp;{{{t 'write.tool8'}}}</label>
            </span>
          {{/if}}
          {{#if this.okSubalbum}}
            <span class="glue">
              <input id="util2" name="albumUtility" value="" type="radio" autofocus {{on 'click' this.detectRadio}}>
              <label for="util2"> &nbsp;{{t 'write.tool2'}}</label>
            </span>
          {{/if}}
          {{#if this.okSort}}
            <span class="glue">
              <input id="util3" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util3"> &nbsp;{{t 'write.tool3'}}</label>
            </span>
          {{/if}}
          {{#if this.okDupNames}}
            <span class="glue">
              <input id="util4" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util4"> &nbsp;{{t 'write.tool4'}}</label>
            </span>
          {{/if}}
          {{#if this.okDupImages}}
            <span class="glue">
              <input id="util7" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util7"> &nbsp;{{{t 'write.tool7'}}}</label>
            </span>
          {{/if}}
          {{#if this.okUpload}}
            <span class="glue">
              <input id="util5" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util5"> &nbsp;{{t 'write.tool5'}}</label>
            </span>
          {{/if}}
          {{#if this.okDbUpdate}}
            <span class="glue">
              <input id="util6" name="albumUtility" value="" type="radio" {{on 'click' this.detectRadio}}>
              <label for="util6"> &nbsp;{{t 'write.tool6'}}</label>
            </span>
          {{/if}}
        </div>

        <div style="padding:0.5rem 0">
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

          {{!-- === Make text list === --}}
          {{else if (eq this.tool 'util8')}}

              <button type="button" {{on 'click' (fn this.doTexts)}}>{{{t 'write.tool8' a=this.imdbDirName}}}</button>

          {{!-- === Make a new subalbum === --}}
          {{else if (eq this.tool 'util2')}}
            <b>{{t 'write.tool2'}}</b><br>

            <input id="newAlbNam" type="text" class="cred user nameNew" size="36" title="" placeholder="{{t 'write.albumName'}}" style="margin:0.2rem 0 0.5rem 0" {{on 'keydown' (fn this.doSubalbum 2)}} autofocus><a title={{t 'erase'}} {{on 'click' (fn this.clearInput)}}> ×&nbsp;</a><br>

            <button type="button" {{on 'click' (fn this.doSubalbum 1)}}>{{t 'button.continue'}}</button>
            <button type="button" {{on 'click' (fn this.doSubalbum 3)}} disabled>{{t 'button.dosub'}}</button>

          {{!-- === Sort images by names === --}}
          {{else if (eq this.tool 'util3')}}
            {{!-- <b>{{t 'write.tool3'}}</b><br> --}}

            <button type="button" {{on 'click' (fn this.doSort)}}>{{t 'write.tool3'}}</button>

            <form style="line-height:1.35rem">
              <span class="glue">
                <input id="util31" name="albumUtility" value="" type="radio" checked>
                <label for="util31"> &nbsp;{{t 'write.tool31'}}</label>
              </span>
              <span class="glue">
                <input id="util32" name="albumUtility" value="" type="radio">
                <label for="util32"> &nbsp;{{t 'write.tool32'}}</label>
              </span>
            </form>

          {{!-- === Find duplicate image names === --}}
          {{else if (eq this.tool 'util4')}}

            {{#if this.z.imdbDir}} {{!-- subtree --}}
              <button type="button" {{on 'click' (fn this.doDupNames)}}>{{{t 'write.tool41' a=this.imdbDirName}}}</button>
            {{else}} {{!-- root --}}
              <button type="button" {{on 'click' (fn this.doDupNames)}}>{{{t 'write.tool42'}}}</button>
            {{/if}}

          {{!-- === Find duplicate images === --}}
          {{else if (eq this.tool 'util7')}}

              <button type="button" {{on 'click' (fn this.doDupImages)}}>{{{t 'write.tool7' a=this.imdbDirName}}}</button>

          {{!-- === Upload images === --}}
          {{else if (eq this.tool 'util5')}}

            <button type="button" {{on 'click' (fn this.doUpload)}}>{{t 'write.tool5'}}</button>

            <form style="line-height:1.35rem">
              <span class="glue">
                <input id="util51" name="albumUtility" value="" type="radio" checked>
                <label for="util51"> &nbsp;{{t 'placeFirst'}}</label>
              </span>
              <span class="glue">
                <input id="util52" name="albumUtility" value="" type="radio">
                <label for="util52"> &nbsp;{{t 'placeLast'}}</label>
              </span>
            </form>

          {{!-- === Update search data for the entire album collection === --}}
          {{else if (eq this.tool 'util6')}}

            <button type="button" {{on 'click' (fn this.doDbUpdate)}}>{{t 'write.tool6'}}</button>

          {{/if}}

        </div>

      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>{{t 'button.cancel'}}</button>&nbsp;
      </footer>
    </dialog>

    <dialog id="dialogDupResult" style="max-width:calc(100vw - 2rem);z-index:15;max-width:480px"{{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <p>&nbsp;</p>
        <p>{{{t 'write.dialogDupResult' a=this.imdbDirName}}}</p>
        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog 'dialogDupResult')}}>×</button>
      </header>
      <main style="padding:0 0.5rem 0 1rem;height:auto;line-height:150%;overflow:auto" width="99%">

        <div style="padding:0.5rem 0;line-height:1.4rem">
          {{#if this.countImgs}}
            {{t 'found'}} {{t 'dupImgNames'}}: {{{this.countImgs}}}<br>
            <button class="show" type="button" {{on 'click' this.doDupNamesShow}}>
              {{t 'button.show'}} <b>{{this.z.handsomize2sp this.z.picFound}}</b>
            </button><br>
          {{else}}
            {{{t 'write.noDupNamesFound' a=this.imdbDirName}}}<br>
          {{/if}}
        </div>

      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog 'dialogDupResult')}}>
          {{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>

  </template>

}
