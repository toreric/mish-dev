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

import { dialogAlertId } from './dialog-alert';
import { dialogChooseId } from './dialog-choose';
import { dialogInfoId } from './dialog-info';
import { dialogTextId } from './dialog-text';

const LF = '\n'   // Line Feed == New Line
const BR = '<br>' // HTML line break

// Get the image array to be operated on
const pics = (picName) => {
  //close view image (and nav-links) if open:
  if (!document.querySelector('div.nav_links').style.display) {
    document.getElementById('go_back').click();
  }
  if (document.getElementById('i' + picName).classList.contains('selected'))
    return document.querySelectorAll('.img_mini.selected');
  // If only this unselected image, get an array of a single element:
  // Don't forget escapeDots (like in common-storage)
  else return document.querySelectorAll('#i' + picName.replace (/\./g, "\\."));
}


export class MenuImage extends Component {
  @service('common-storage') z;
  @service intl;

  get chooseText() {
    // The case one wouldn't have a choice!
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

  // Hide or show one, or some checked, thumbnail images
  hideShow = async () => {
    let imgs = pics(this.z.picName);

    // begin local function ---------
    const hs = async () => {
      // let imgs = pics(this.z.picName);
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

    // let imgs = pics(this.z.picName);
    this.z.toggleMenuImg(0); //close image menu
    if (imgs.length > 1) {
      this.z.chooseText = this.chooseText + '<br>' + this.chooseHide;
      this.z.infoHeader = this.intl.t('write.chooseHeader'); // default header
      this.z.buttonNumber = 0;
      await new Promise (z => setTimeout (z, 99)); // hideShow 2
      this.z.openDialog(dialogChooseId);
      while (!this.z.buttonNumber) {
        await new Promise (z => setTimeout (z, 199)); // hideShow 3
        if (this.z.buttonNumber === 1) { await hs(); } // first button confirms
      } // if another button leave and close
    } else { await hs(); } // a single img need no confirm
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
    // this.z.toggleMenuImg(0); //close image menu
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
    this.z.toggleMenuImg(0); //close image menu
    this.z.sortOrder = this.z.updateOrder();
  }

  // Move one, or some checked, thumbnail image(s),
  // if (isTrue === true): to the beginning,
  // if (isTrue === false): to the end
  placeFirst = async (isTrue) => {

    // begin local function ---------
    const hs = async () => {
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
    let imgs = pics(this.z.picName);
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
          await hs();
          this.z.alertMess(this.z.intl.t('write.afterSort')); // TEMPORARY
        }
      } // if another button leave and close
    } else { // a single img need no confirm
      await hs();
      this.z.alertMess(this.z.intl.t('write.afterSort')); // TEMPORARY
    }
    this.z.countNumbers();
    this.z.sortOrder = this.z.updateOrder();
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

  futureNotYet = (menuItem) => {
    let alrt = document.getElementById(dialogAlertId);
    if (alrt.open) {
      alrt.close();
    } else {
      this.z.alertMess('<div style="text-align:center">' + this.intl.t(menuItem) + ':' + BR + BR + this.intl.t('futureFacility') + '</div>');
    }
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
        <li><p {{on 'click' (fn this.futureNotYet 'editimage')}}>
          {{t 'editimage'}}</p></li>
      {{/if}}

      {{!-- Hide or show image(s) --}}
      {{#if this.z.allow.imgHidden}}
        <li><p {{on 'click' (fn this.hideShow)}}>
          <span style="font-size:124%;line-height:50%">
            ○</span>{{t 'hideshow'}}</p></li>
      {{/if}}
      <li><hr style="margin:0.25rem 0.5rem"></li>

      {{!-- Mark (check) only hidden images --}}
      <li><p {{on 'click' (fn this.markHidden)}}>
        {{t 'markhidden'}}</p></li>

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
        <li><p {{on 'click' (fn this.futureNotYet 'download')}}>
          {{t 'download'}}</p></li>
      {{/if}}
      <li><hr style="margin:0.25rem 0.5rem"></li>

      {{!-- Link image(s) to another album --}}
      <li><p {{on 'click' (fn this.futureNotYet 'linkto')}}>
        <span style="font-size:124%;line-height:50%">
        ○</span>{{t 'linkto'}}</p></li>

      {{!-- Move image(s) to another album --}}
      <li><p {{on 'click' (fn this.futureNotYet 'moveto')}}>
        <span style="font-size:124%;line-height:50%">
        ○</span>{{t 'moveto'}}</p></li>

      {{!-- Erase image(s)  --}}
      <li><p {{on 'click' (fn this.futureNotYet 'remove')}}>
        <span style="font-size:124%;line-height:50%">
        ○</span>{{t 'remove'}}</p></li>

    </ul>
  </template>

}
