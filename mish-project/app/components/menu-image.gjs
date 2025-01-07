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
import { dialogInfoId } from './dialog-info';
import { dialogTextId } from './dialog-text';

const LF = '\n'   // Line Feed == New Line
const BR = '<br>' // HTML line break

// document.addEventListener('mousedown', async (event) => {
//   event.preventDefault(); // Kills everything
// });

export class MenuImage extends Component {
  @service('common-storage') z;
  @service intl;

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

  toggleDialog = (id) => {
    // this.z.markBorders(this.z.picName); //seems unnecessary
    this.z.toggleDialog(id);
  }

  futureNotYet = (menuItem) => {
    // this.z.markBorders(this.z.picName);
    let alrt = document.getElementById(dialogAlertId);
    if (alrt.open) {
      alrt.close();
    } else {
      this.z.alertMess('<div style="text-align:center">' + this.intl.t(menuItem) + ':' + BR + BR + this.intl.t('futureFacility') + '</div>');
    }
  }

  hideShow = () => {
    let pics;
    if (document.getElementById('i' + this.z.picName).classList.contains('selected'))
      pics = document.querySelectorAll('.img_mini.selected');
    else pics = document.querySelectorAll('#i' + this.z.escapeDots(this.z.picName));
    for (let pic of pics) {
      if (pic.classList.contains('hidden')) pic.classList.remove('hidden');
      else pic.classList.add('hidden');
    }
    this.z.sortOrder = this.z.updateOrder();
    this.z.toggleMenuImg(0);
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
      <li><p {{on 'click' (fn this.toggleDialog dialogInfoId)}}>
        {{t 'information'}}</p></li>

      {{!-- Open image text edit dialog --}}
      {{#if this.z.allow.textEdit}}
        <li><p {{on 'click' (fn this.toggleDialog dialogTextId)}}>
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

      {{!-- Check or uncheck all images --}}
      <li><p {{on 'click' (fn this.futureNotYet 'checkuncheck')}}>
        <span style="font-size:124%;line-height:50%">
          ○</span>{{t 'checkuncheck'}}</p></li>

      {{!-- Mark (check) only hidden images --}}
      <li><p {{on 'click' (fn this.futureNotYet 'markhidden')}}>
        <span style="font-size:124%;line-height:50%">
          ○</span>{{t 'markhidden'}}</p></li>

      {{!-- Invert selection (marked/checked) --}}
      <li><p {{on 'click' (fn this.futureNotYet 'invertsel')}}>
        <span style="font-size:124%;line-height:50%">
          ○</span>{{t 'invertsel'}}</p></li>

      {{#if this.z.allow.imgReorder}}
        {{!-- Place image(s) first --}}
        <li><p {{on 'click' (fn this.futureNotYet 'placefirst')}}>
          <span style="font-size:124%;line-height:50%">
            ○</span>{{t 'placefirst'}}</p></li>

        {{!-- Placeimages(s) a the end --}}
        <li><p {{on 'click' (fn this.futureNotYet 'placelast')}}>
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
