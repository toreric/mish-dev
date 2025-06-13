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
  @tracked countImgs = 0; // duplicate image name counter
  @tracked amTools = 0; // album tools flag
  @tracked cnTools = 0; // common tools flag

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogUtilId).open) this.z.closeDialog(dialogUtilId);
    }
  }

  // Which tool was selected?
  detectRadio = async (e) => {
    var elRadio = e.target;
      // this.z.loli(`${elRadio.id} ${elRadio.checked}`, 'color:red');
    this.tool = elRadio.id;
  }

  clearInput = () => {
    let elem = document.querySelector('#newAlbNam');
    elem.value = '';
    elem.style.background = '#f0f0a0';
    elem.focus();
  }

  // Reset all at album change. Called from okDelete, which is the first
  // of 'ok...' checks in the template. 'imdbDir' is used for resetting
  // before the simple return of the 1-sliced-off imdbDir value. WARNING:
  // 'this.imdbDir' MUSTS NOT BE USE ELSEWHERE TO REPLACE 'this.z.imdbDir.slice(1)'!
  get imdbDir() {
    // this.amTools = 0;
    this.cnTools = 0;
    this.tool = '';
    // document.querySelector('#dialogUtil footer').innerHTML = '';
    // let elRadio = document.querySelectorAll('#dialogUtil input[type="radio"]');
    // for (let i=0; i<elRadio.length; i++) {
    //   elRadio[i].checked = false;
    // }
    // remove initial slash (except root: already empty)
    return this.z.imdbDir.slice(1);
  }

  get imdbDirName() {
  // imdbDirName = () => {
    let tmp = this.z.imdbDirName;
    return this.z.handsomize2sp(tmp);
  }

  // This button is inserted into alertMess when browser reload is required.
  // Then alertMess cannot be closed by closeDialog (but with closeDialogs!).
  get restart() {
    return '<br><div style="text-align:center"><button class="unclosable" type="button" onclick="location.reload(true);return false">' + this.intl.t('button.restart') + '</utton></div>'
  }

  // Must be the first called from the template.
  // THE FIRST AND ONLY USE IN DialogUtil OF 'this.imdbDir' IS HERE:
  get okDelete() { // true if delete album is allowed
    // this.amTools = 0;
    this.cnTools = 0;
    this.tool = '';
      // this.z.loli('numShown ' + this.z.numShown, 'color:#444'); // Printout to wait
    let found = this.imdbDir === this.z.picFound;
      // this.z.loli('imdbDir: ' +  this.imdbDir, 'color:yellow');
      // this.z.loli('picFound: ' +  this.z.picFound, 'color:yellow');
    if (!found && this.z.imdbDir && this.z.allow.albumEdit) { // Don't erase ''=root
      this.tool = '';
      // if (this.z.albumTools) this.amTools = 1;
      return true
    } else {
      return false;
    }
  }

  get okTexts() { // true if images shown
      // this.z.loli('numShown ' + this.z.numShown, 'color:#111'); // Printout to wait
    // await new Promise (z => setTimeout (z, 39));
      // this.z.loli('numShown ' + this.z.numShown, 'color:brown ');
    if (this.z.numShown > 0) {
      this.tool = '';
      // if (this.z.albumTools) this.amTools = 1;
      return true;
    } else {
      return false;
    }
  }

  get okSubalbum() { // true if subalbums allowed
    if (this.z.imdbDir.slice(1) !== this.z.picFound && this.z.allow.albumEdit) {
      this.tool = '';
      // if (this.z.albumTools) this.amTools = 1;
      return true;
    } else {
      return false;
    }
  }

  get okSort() { // true if sorting by name is possible
    if (this.z.numShown > 1) {
      this.tool = '';
      // if (this.z.albumTools) this.amTools = 1;
      return true;
    } else {
      return false;
    }
  }

  get okDupNames() {
    if (!this.z.albumTools) this.cnTools = 1;
    this.tool = '';
    return true;
  }

  get okDupImages() {
    if (!this.z.albumTools) this.cnTools = 1;
    this.tool = '';
    return true;
  }

  get okUpload() {
    if (this.z.imdbDir.slice(1) !== this.z.picFound && this.z.allow.deleteImg) {
      this.tool = '';
    // if (this.z.albumTools) this.amTools = 1;
      return true;
    } else {
      return false;
    }
  }

  get okDbUpdate() {
    if (!this.z.albumTools) this.cnTools = 1;
    this.tool = '';
    return true;
  }

  get notEmpty() { // true if the album is not empty
    return this.z.subaIndex.length > 0 || this.z.numImages > 0;
  }

  doDelete = async () => { // Delete an empty album
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
    for (let minisi of minis) {
      names.push(minisi.id.slice(1));
    }
      // this.z.loli('\n' + names.join('\n'), 'color:yellow');
    // Sort example: a.sort((a,b) => {return a.value - b.value});
    // Applied to text, exact conformity should also consider equality
    // using a more accurate function that correspondingly returns 1, 0, or -1:
    names.sort((a, b) => {
      let x = a.toLowerCase();
      let y = b.toLowerCase();
      if (x < y) return -1;
      if (x > y) return 1;
      return 0;
    })
    // The id for reverse sort radio button is 'util32' (see template)
    if (document.getElementById('util32').checked) names.reverse();
      // this.z.loli('\n' + names.join('\n'), 'color:yellow');

    // When you add an element that is already in the DOM,
    // this element will be moved, not copied.
    let wrap = document.getElementById('imgWrapper');
    for (let i=0; i<minis.length; i++) {
      wrap.appendChild(document.getElementById('i' + names[i]));
    }
    this.z.closeDialogs(); // Why this?
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
      elem.style.background = '#f0f0a0'; // yellow
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
    // let path = this.z.imdbPath + this.z.imdbDir;
    let path = this.z.imdbPath; //OVERRIDE! I.e. search all albums.
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

  get zeroTools1() {
    this.amTools = 0;
    return '';
  }

  get addTools1() {
    this.amTools ++;
    return '';
  }

  // NOTE, within the <template></template>:
  // *** The utility numbering is not always in sequence ***

  <template>

    <dialog id="dialogUtil" style="width:min(calc(100vw - 2rem),auto);max-width:480px" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>

        <p>&nbsp;</p>

        {{#if this.z.albumTools}}
          <p><b>{{t 'write.utilHeader'}} <span>{{this.imdbDirName}}</span></b><br>({{this.z.imdbRoot}}{{this.z.imdbDir}})</p>
        {{else}}
          <p><b>{{t 'write.utilHeader0'}}</b></p>
        {{/if}}

        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogUtilId)}}>×</button>

      </header>
      <main style="padding:0 0.75rem;max-height:24rem" width="99%">

        <div style="padding:0.5rem 0;line-height:1.4rem">

        {{#if this.z.albumTools}}
        {{!-- Album tools --}}{{this.zeroTools1}}

          {{!-- Here are tools specific for the actual album --}}
          {{{t 'write.tool0' a=this.imdbDirName}}}<br>
          {{!-- This reference to okDelete resets radio buttons etc. --}}
          {{#if this.okDelete}}
            <span class="glue">
              <input id="util1" {{this.addTools1}} name="albumUtility" type="radio" {{on 'click' (fn this.detectRadio)}}>
              <label for="util1"> &nbsp;{{t 'write.tool1'}}</label>
            </span>
          {{/if}}
          {{#if this.okTexts}}
            <span class="glue">
              <input id="util8" {{this.addTools1}} name="albumUtility" type="radio" {{on 'click' (fn this.detectRadio)}}>
              <label for="util8"> &nbsp;{{{t 'write.tool8'}}}</label>
            </span>
          {{/if}}
          {{#if this.okSubalbum}}
            <span class="glue">
              <input id="util2" {{this.addTools1}} name="albumUtility" type="radio" autofocus {{on 'click' (fn this.detectRadio)}}>
              <label for="util2"> &nbsp;{{t 'write.tool2'}}</label>
            </span>
          {{/if}}
          {{#if this.okSort}}
            <span class="glue">
              <input id="util3" {{this.addTools1}} name="albumUtility" type="radio" {{on 'click' (fn this.detectRadio)}}>
              <label for="util3"> &nbsp;{{t 'write.tool3'}}</label>
            </span>
          {{/if}}
          {{#if this.okUpload}}
            <span class="glue">
              <input id="util5" {{this.addTools1}} name="albumUtility" type="radio" {{on 'click' (fn this.detectRadio)}}>
              <label for="util5"> &nbsp;{{t 'write.tool5'}}</label>
            </span>
          {{/if}}

        {{else}}
        {{!-- Common tools --}}

          {{!-- Here are tools for the entire album collection --}}
          <div style="margin:0.5rem 0 0 0">{{{t 'write.tool01'}}}</div>
          {{#if this.okDupNames}}
            <span class="glue">
              <input id="util4" name="albumUtility" type="radio" {{on 'click' (fn this.detectRadio)}}>
              <label for="util4"> &nbsp;{{t 'write.tool4'}}</label>
            </span>
          {{/if}}
          {{#if this.okDupImages}}
            <span class="glue">
              <input id="util7" name="albumUtility" type="radio" {{on 'click' (fn this.detectRadio)}}>
              <label for="util7"> &nbsp;{{{t 'write.tool7'}}}</label>
            </span>
          {{/if}}
          {{#if this.okDbUpdate}}
            <span class="glue">
              <input id="util6" name="albumUtility" type="radio" {{on 'click' (fn this.detectRadio)}}>
              <label for="util6"> &nbsp;{{t 'write.tool6'}}</label>
            </span>
          {{/if}}

        {{/if}}

        </div>

        <div style="padding:0.5rem 0">
        {{!-- “{{this.tool}}“ {{this.amTools}} {{this.cnTools}} --}}

          {{#if this.z.albumTools}}
            {{#if this.amTools}}
              {{t 'write.chooseTool'}}<br>
            {{else}}
              {{t 'write.tool99'}}
            {{/if}}
          {{else}}
            {{t 'write.chooseTool'}}<br>
          {{/if}}

          {{!-- === Delete the album === --}}
          {{#if (eq this.tool 'util1')}}
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
                <input id="util31" name="albumUtility" type="radio" checked>
                <label for="util31"> &nbsp;{{t 'write.tool31'}}</label>
              </span>
              <span class="glue">
                <input id="util32" name="albumUtility" type="radio">
                <label for="util32"> &nbsp;{{t 'write.tool32'}}</label>
              </span>
            </form>

          {{!-- === Find duplicate image names === --}}
          {{else if (eq this.tool 'util4')}}

            {{!-- {{#if this.z.imdbDir}} subtree OVERRIDE!
              <button type="button" {{on 'click' (fn this.doDupNames)}}>{{{t 'write.tool41' a=this.imdbDirName}}}</button>
            {{else}} root --}}
              <button type="button" {{on 'click' (fn this.doDupNames)}}>{{{t 'write.tool42'}}}</button>
            {{!-- {{/if}} --}}

          {{!-- === Find duplicate images === --}}
          {{else if (eq this.tool 'util7')}}

              <button type="button" {{on 'click' (fn this.doDupImages)}}>{{{t 'write.tool7' a=this.imdbDirName}}}</button>

          {{!-- === Upload images === --}}
          {{else if (eq this.tool 'util5')}}

            <button type="button" {{on 'click' (fn this.doUpload)}}>{{t 'write.tool5'}}</button>

            <form style="line-height:1.35rem">
              <span class="glue">
                <input id="util51" name="albumUtility" type="radio" checked>
                <label for="util51"> &nbsp;{{t 'placeFirst'}}</label>
              </span>
              <span class="glue">
                <input id="util52" name="albumUtility" type="radio">
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
