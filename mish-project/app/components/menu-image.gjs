//== Mish image (thumbnail) menu, replaces former context menu

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { MenuMain } from './menu-main';

import { TrackedArray } from 'tracked-built-ins';
import RefreshThis from './refresh-this';

import { dialogAlertId } from './dialog-alert';
import { dialogChooseId } from './dialog-choose';
import { dialogInfoId } from './dialog-info';
import { dialogTextId } from './dialog-text';

const LF = '\n';   // Line Feed == New Line
const BR = '<br>'; // HTML line break
const SP = '&nbsp;'; // single space
const SP2 = '&nbsp;&nbsp;'; // double space
const SP3 = '&nbsp;&nbsp;&nbsp;'; // triple space
const SP4 = '&nbsp;&nbsp;&nbsp;&nbsp;'; // four spaces

// let albumsIndex = [];
// let albums = [];

// Get the thumbnail-containing elements to be operated on,
// either one unselected, or all co-selected elements:
const selMinImgs = (picName) => {
  //close view image (and nav-links) if open:
  if (!document.querySelector('div.nav_links').style.display) {
    document.getElementById('go_back').click();
  }
  if (document.getElementById('i' + picName).classList.contains('selected'))
    return document.querySelectorAll('.img_mini.selected');
  // If only this unselected image, get an array of a single element:
  // Don't forget escapeDots (see common-storage.js)
  else return document.querySelectorAll('#i' + picName.replace(/\./g, "\\."));
}

export class MenuImage extends Component {
  @service('common-storage') z;
  @service intl;

  // @tracked albums = [];
  // @tracked albumsIndex = [];
  albums = new TrackedArray([]);
  albumsIndex = new TrackedArray([]);

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogAlertId).open) this.z.closeDialog('chooseAlbum');
    }
  }

  // Detect closing Esc key
  detectClose = (e) => {
    e.stopPropagation();
    if (e.type === 'keydown' && e.keyCode === 27 || e.type === 'click') { // Esc key
      // Close any open image menu
      for (let list of document.querySelectorAll('.menu_img_list')) list.style.display = 'none';
      // Sorry, no loli message!
    }
    document.querySelector('body').focus();
  }

  get chooseText() {
    // A single image wouldn't have a choice!
    if (this.z.numMarked === 2) {
      return this.intl.t('write.chooseBoth');
    } else {
      return this.intl.t('write.chooseMany', {n: this.z.numMarked});
    }
  }

  get chooseHide() {
    return this.intl.t('write.chooseHide');
  }

  get chooseFirst() {
    return this.intl.t('write.chooseFirst');
  }

  get chooseLast() {
    return this.intl.t('write.chooseLast');
  }

  get chooseLink() {
    return this.intl.t('write.chooseLink');
  }

  get chooseMove() {
    return this.intl.t('write.chooseMove');
  }

  // Hide or show one, or some checked, thumbnail images
  hideShow = async () => {
    let imgs = selMinImgs(this.z.picName);

    // begin local function ---------
    const perform = async () => {
      await new Promise (z => setTimeout (z, 99)); // hideShow 1
      for (let pic of imgs) {
        if (pic.classList.contains('hidden')) {
          pic.classList.remove('hidden');
          pic.classList.remove('invisible');
        } else {
          pic.classList.add('hidden');
          if (this.z.ifHideSet()) pic.classList.add('invisible');
        }
      }
    }// end local function -----------

    this.z.toggleMenuImg(0); //close image menu
    if (imgs.length > 1) {
      this.z.chooseText = this.chooseText + '<br>' + this.chooseHide;
      this.z.infoHeader = this.intl.t('write.chooseHeader'); // default header
      this.z.buttonNumber = 0;
      await new Promise (z => setTimeout (z, 99)); // hideShow 2
      this.z.openDialog(dialogChooseId);
      while (!this.z.buttonNumber) {
        await new Promise (z => setTimeout (z, 199)); // hideShow 3
        if (this.z.buttonNumber === 1) { await perform(); } // first button confirms
      } // if another button leave and close
    } else { await perform(); } // a single img needs no confirmation
    this.z.countNumbers();
    this.z.closeDialogs();
    this.z.sortOrder = this.z.updateOrder();
  }

  // Mark (check as selected) only hidden images
  markHidden = () => {
    if (!document.querySelector('div.nav_links').style.display) {
      document.getElementById('go_back').click();
    }
    for (let pic of document.querySelectorAll('.img_mini')) {
      if (pic.classList.contains('hidden')) {
        pic.classList.add('selected');
        pic.querySelector('div[alt="MARKER"]').className = 'markTrue';
      } else {
        pic.classList.remove('selected');
        pic.querySelector('div[alt="MARKER"]').className = 'markFalse';
      }
    }
    this.z.countNumbers();
    this.z.toggleMenuImg(0); //close image menu
    this.z.sortOrder = this.z.updateOrder();
  }

  // Check or uncheck all thumbnail images (check = mark as selected)
  checkUncheck = () => {
    //close view image (and nav-links) if open (not 'display:none'):
    if (!document.querySelector('div.nav_links').style.display) {
      document.getElementById('go_back').click();
    }
    if (document.getElementById('i' + this.z.picName).classList.contains('selected')) {
      let pics =  document.querySelectorAll('.img_mini.selected');
      for (let pic of pics) {
        pic.classList.remove('selected');
        pic.querySelector('div[alt="MARKER"]').className = 'markFalse';
      }
    } else {
      let pics = document.querySelectorAll('.img_mini');
      for (let pic of pics) {
        pic.classList.add('selected');
        pic.querySelector('div[alt="MARKER"]').className = 'markTrue';
      }
    }
    this.z.countNumbers();
    this.z.sortOrder = this.z.updateOrder();
  }

  // Invert selections (marked/checked)
  invertSelection = () => {
    if (!document.querySelector('div.nav_links').style.display) {
      document.getElementById('go_back').click();
    }
    for (let pic of document.querySelectorAll('.img_mini')) {
      if (pic.classList.contains('selected')) {
        pic.classList.remove('selected');
        pic.querySelector('div[alt="MARKER"]').className = 'markFalse';
      } else {
        pic.classList.add('selected');
        pic.querySelector('div[alt="MARKER"]').className = 'markTrue';
      }
    }
    this.z.countNumbers();
    this.z.sortOrder = this.z.updateOrder();
  }

  // Move (within the screen) one, or some checked, thumbnail image(s),
  // if (isTrue === true): to the beginning,     placeFirst
  // if (isTrue === false): to the end,          placeLast
  placeFirst = async (isTrue) => { // NOTE: 'placeLast()' is 'placeFirst(false)'!

    // begin local function ---------
    const perform = async () => {
      await new Promise (z => setTimeout (z, 99)); // placeFirst 1
      // When you add an element that is already in the DOM,
      // this element will be moved, not copied.
      for (let pic of imgs) {
        if (isTrue) parent.insertBefore(pic, parent.firstChild);
        else parent.appendChild(pic);
      }
      this.z.closeDialogs();
      this.z.toggleMenuImg(0); //close image menu
    }// end local function ----------

    var parent = document.getElementById('imgWrapper');
    let imgs = selMinImgs(this.z.picName);
    let addline;

    if (imgs.length > 1) {
      if (isTrue) addline = this.chooseFirst;
      else addline = this.chooseLast;
      this.z.chooseText = this.chooseText + '<br>' + addline;
      this.z.infoHeader = this.intl.t('write.chooseHeader'); // default header
      this.z.buttonNumber = 0;
      await new Promise (z => setTimeout (z, 99)); // placeFirst 2
      this.z.openDialog(dialogChooseId);
      while (!this.z.buttonNumber) {
        await new Promise (z => setTimeout (z, 199)); // placeFirst 3
        if (this.z.buttonNumber === 1) { // first button confirms
          await perform();
          this.z.toggleMenuImg(0); //close image menu
          this.z.alertMess(this.z.intl.t('write.afterSort')); // TEMPORARY
        }
        // if another button leave and close
      }
    } else { // a single img needs no confirmation
      await perform();
      this.z.toggleMenuImg(0); //close image menu
      this.z.alertMess(this.z.intl.t('write.afterSort')); // TEMPORARY
    }
    this.z.closeDialog(dialogChooseId);
    this.z.countNumbers();
    this.z.sortOrder = this.z.updateOrder();
  }

  get albname() {
    let a = '';
    let i = this.z.picIndex;
    if (i < 0) return a; //important
    let b = this.z.allFiles[i];
    if (b) a = b.albname; //name of home album
    return a;
  }
  get orig() {
    let a = '';
    let i = this.z.picIndex;
    if (i < 0) return a; //important
    let b = this.z.allFiles[i];
    if (b) a = b.orig; //path to home album
    return a;
  }
  get symlink() {
    let a = '';
    let i = this.z.picIndex;
    if (i < 0) return a; //important
    let b = this.z.allFiles[i];
    if (b) a = b.symlink; //has a home album
    return a;
  }

  getAlbum = (i) => {
    return this.albums[i];
  }

  // Link (into another album within the collection)
  // a single image, or a number of checked images.
  linkFunc = async () => {
    let imgs = selMinImgs(this.z.picName);
    await new Promise (z => setTimeout (z, 99)); // linkFunc 1
    let sym = false;
    for (let img of imgs) {
      if (img.classList.contains('symlink')) sym = true;
    }
    if (sym) {
      this.z.alertMess(this.intl.t('write.noLinkLink'));
      return;
    }
    this.z.toggleMenuImg(0); //close image menu
    if (imgs.length > 1) {
      this.z.chooseText = this.chooseText + '<br>' + this.chooseLink;
      this.z.infoHeader = this.intl.t('write.chooseHeader'); // default header
      this.z.buttonNumber = 0;
      await new Promise (z => setTimeout (z, 99)); // linkFunc 2
      this.z.openDialog(dialogChooseId);
      while (!this.z.buttonNumber) {
        await new Promise (z => setTimeout (z, 99)); // linkFunc 3
        if (this.z.buttonNumber === 1) { this.z.openDialog('chooseAlbum'); } // 1 confirms
      } // if another button: leave and close
    } else {
      // a single img needs no confirmation but we mark it
      this.z.markBorders(this.z.picName);
      this.z.toggleDialog('chooseAlbum');
    }
    this.z.countNumbers();
    this.z.closeDialogs();
    this.z.sortOrder = this.z.updateOrder();
    return;
  }

  // Move (to another album within the collection)
  // a single image, or a number of checked images.
  moveFunc = async () => {
    let imgs = selMinImgs(this.z.picName);
    await new Promise (z => setTimeout (z, 99)); // moveFunc 1
    this.z.toggleMenuImg(0); //close image menu
    if (imgs.length > 1) {
      this.z.chooseText = this.chooseText + '<br>' + this.chooseMove;
      this.z.infoHeader = this.intl.t('write.chooseHeader'); // default header
      this.z.buttonNumber = 0;
      await new Promise (z => setTimeout (z, 99)); // moveFunc 2
      this.z.openDialog(dialogChooseId);
      while (!this.z.buttonNumber) {
        await new Promise (z => setTimeout (z, 99)); // moveFunc 3
        if (this.z.buttonNumber === 1) { this.z.openDialog('chooseAlbum'); } // 1 confirms
      } // if another button leave and close
    } else {
      // a single img needs no confirmation but we mark it
      this.z.markBorders(this.z.picName);
      this.z.toggleDialog('chooseAlbum');
    }
    this.z.countNumbers();
    this.z.closeDialogs();
    this.z.sortOrder = this.z.updateOrder();
    return;
  }

  <template>
    <button class='menu_img' type="button" title="{{t 'imageMenu'}}"
    {{on 'click' (fn this.z.toggleMenuImg 1)}}
    {{on 'keydown' this.detectClose}}>⡇</button>
    <ul class="menu_img_list" style="text-align:left;display:none">

      <li><p style="text-align:right;color:deeppink;
        font-size:120%;line-height:80%;padding-bottom:0.125rem"
        {{!-- {{on 'click' this.closeMenuImg}}> --}}
        {{on 'click' this.detectClose}}>
        × </p>
      </li>

      {{!-- Go-to-origin of linked image --}}
      {{#if this.symlink}}
        <li>
          <p class="goAlbum" style="color:#0b0;font-weight:bold;font-size:90%" title-2="{{t 'gotext'}} ”{{this.albname}}”"
          {{on 'click' (fn this.z.homeAlbum this.orig this.z.picName)}}> {{t 'goto'}} </p>
        </li>
      {{/if}}

      {{!-- Open image file information dialog --}}
      <li><p {{on 'click' (fn this.z.toggleDialog dialogInfoId)}}>
        {{t 'information'}}</p></li>

      {{!-- Open image text edit dialog --}}
      {{#if this.z.allow.textEdit}}
        <li><p {{on 'click' (fn this.z.toggleDialog dialogTextId)}}>
          {{t 'editext'}}</p></li>
      {{/if}}

      {{!-- Edit this image --}}
      {{#if this.z.allow.imgEdit}}
        <li><p {{on 'click' (fn this.z.futureNotYet 'editimage')}}>
          {{t 'editimage'}}</p></li>
      {{/if}}

      {{!-- Hide or show image(s) --}}
      {{#if this.z.allow.imgHidden}}
        <li><p {{on 'click' (fn this.hideShow)}}>
          <span style="font-size:124%;line-height:50%">
            ○</span>{{t 'hideshow'}}</p></li>

      {{!-- Mark (check) only hidden images --}}
      <li><p {{on 'click' (fn this.markHidden)}}>
        {{t 'markhidden'}}</p></li>
      {{/if}}
      <li><hr style="margin:0.25rem 0.5rem"></li>

      {{!-- Check or uncheck all images --}}
      <li><p {{on 'click' (fn this.checkUncheck)}}>
        <span style="font-size:124%;line-height:50%">
          ○</span>{{t 'checkuncheck'}}</p></li>

      {{!-- Invert selection (marked/checked) --}}
      <li><p {{on 'click' (fn this.invertSelection)}}>
        <span style="font-size:124%;line-height:50%">
          ○</span>{{t 'invertsel'}}</p></li>

      {{#if this.z.allow.imgReorder}}
        {{!-- Place image(s) first --}}
        <li><p {{on 'click' (fn this.placeFirst true)}}>
          <span style="font-size:124%;line-height:50%">
            ○</span>{{t 'placefirst'}}</p></li>

        {{!-- Placeimages(s) a the end --}}
        <li><p {{on 'click' (fn this.placeFirst false)}}>
          <span style="font-size:124%;line-height:50%">
            ○</span>{{t 'placelast'}}</p></li>
      {{/if}}

      {{!-- Download images to this album --}}
      {{#if this.z.allow.imgUpload}}
        <li><p {{on 'click' (fn this.z.futureNotYet 'download')}}>
          {{t 'download'}}</p></li>
      {{/if}}
      <li><hr style="margin:0.25rem 0.5rem"></li>

      {{!-- Link image(s) to another album --}}
      <li><p {{on 'click' (fn this.linkFunc)}}>
        <span style="font-size:124%;line-height:50%">
        ○</span>{{t 'linkto'}}</p></li>

      {{!-- Move image(s) to another album --}}
      <li><p {{on 'click' (fn this.moveFunc)}}>
        <span style="font-size:124%;line-height:50%">
        ○</span>{{t 'moveto'}}</p></li>

      {{!-- Erase image(s)  --}}
      <li><p {{on 'click' (fn this.z.futureNotYet 'remove')}}>
        <span style="font-size:124%;line-height:50%">
        ○</span>{{t 'remove'}}</p></li>

    </ul>
  </template>

}

export class ChooseAlbum extends Component {
  @service('common-storage') z;

  @tracked which = -1;

  doMove = () => {
    this.z.alertMess('perform doMove');
    this.z.closeDialog('chooseAlbum');
  }

  whichAlbum = () => {
    const elRadio = e.target.closest('input[type="radio"]');
    if (!elRadio) return; // Not a radio element
      // this.z.loli(`${elRadio.id} ${elRadio.checked}`, 'color:red');
    this.which = Number(elRadio.id.slice(5));
  }

  filterAlbum = (index) => {
    return this.z.imdbDirs[index] === this.z.imdbDir || this.z.imdbDirs[index].slice(1) === this.z.picFound ? false : true;
  }

  <template>
    <dialog id="chooseAlbum" style="z-index:999" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <div style="width:99%">
          <p style="color:blue">{{t 'selectTarget'}}<span></span></p>
        </div><div>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog 'chooseAlbum')}}>×</button>
        </div>
      </header>
      <main style="padding:0.5rem">
        <b>{{t 'selectAlbum'}}</b>
        <span>(”.” = ”{{this.z.imdbRoot}}”)</span><br>
        <div class="albumList">

          {{#each this.z.imdbDirs as |album index|}}
            {{#if (this.filterAlbum index)}}
              <span class="pselect glue">
                <input id="album{{index}}" type="radio" name="albumList" {{on 'click' this.whichAlbum}}>
                <label for="album{{index}}" style="display:block;margin-left:1rem">
                  &nbsp;<span style="font-size:77%;vertical-align:top">{{index}}</span>&nbsp;”.{{album}}”
                </label>
              </span>
            {{/if}}
          {{else}}
            {{t 'write.foundNoAlbums'}}
          {{/each}}

        </div>
        {{#if (eq this.which -1)}}
          No album chosen, select one!<br>
        {{else}}
          Album {{this.which}} was chosen<br>
        {{/if}}
        <button type="button" {{on 'click' (fn this.doMove)}}>{{t 'button.move'}}</button><br>
      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog 'chooseAlbum')}}>{{t 'button.cancel'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>

}
