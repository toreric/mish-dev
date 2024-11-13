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

export class MenuImage extends Component {
  @service('common-storage') z;
  @service intl;

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      // Close any open image menu
      for (let list of document.querySelectorAll('.menu_img_list')) list.style.display = 'none';
      // Sorry, no loli message!
    }
    document.getElementById(dialogInfoId).focus();
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

  <template>
    <button class='menu_img' type="button" title="{{t 'imageMenu'}}"
    {{on 'click' (fn this.z.toggleMenuImg 1)}}
    {{on 'keydown' this.detectEscClose}}>⡇</button>

    <ul class="menu_img_list" style="text-align:left;display:none">

      <li><p style="text-align:right;color:deeppink;
        font-size:120%;line-height:80%;padding-bottom:0.125rem"
        {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        × </p>
      </li>

      {{!-- Go-to-origin of linked image --}}
      {{#if this.symlink}}
        <li>
          <p class="goAlbum" style="color:#0b0;font-weight:bold;font-size:90%" title="{{t 'gotext'}} ”{{this.albname}}”"
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

      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        {{t 'editimage'}}</p></li>
      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
          ○</span>{{t 'hideshow'}}</p></li>
      <li><hr style="margin:0.25rem 0.5rem"></li>

      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
          ○</span>{{t 'checkuncheck'}}</p></li>
      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'markhidden'}}</p></li>
      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'invertsel'}}</p></li>
      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        {{t 'placefirst'}}</p></li>
      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        {{t 'placelast'}}</p></li>
      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        {{t 'download'}}</p></li>
      <li><hr style="margin:0.25rem 0.5rem"></li>

      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'linkto'}}</p></li>
      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'moveto'}}</p></li>
      <li><p {{on 'click' (fn this.z.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'remove'}}</p></li>

    </ul>

  </template>

}
