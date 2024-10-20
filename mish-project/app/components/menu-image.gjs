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

  homeAlbum = async (path, fileName) => { // was parAlb
    this.z.loli('path:' + path + ':');
    this.z.loli('fileName:' + fileName + ':');
    // Convert the relative path of the linked-file target,
    // to conform with z.imdbDirs server list, rooted at album root
    let dir = path.replace(/^([.]*\/)*/, '/').replace(/\/[^/]+$/, '');
    let name = path.replace(/^([^/]*\/)*([^/]+)\/[^/]+$/, "$2")
    // dir is the home album (with index i) for path
    let i = this.z.imdbDirs.indexOf(dir);
    if (i < 0) {
      if (document.getElementById(dialogAlertId).open) {
        this.z.closeDialog(dialogAlertId);
      } else {
        this.z.alertMess(this.intl.t('albumMissing') + ':<br><br><p style="width:100%;text-align:center;margin:0">”' + this.z.removeUnderscore(name) + '”</p>');
      }
    } else {
      this.z.openAlbum(i);
      // Allow for the rendering of mini images and preload of view images
      let size = this.z.albumAllImg(i);
      await new Promise (z => setTimeout (z, size*60 + 100)); // album load
      this.z.gotoMinipic(fileName);
    }
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

  toggleMenuImg = (open, e) => {
    if (e) e.stopPropagation();
    let tgt = e.target.closest('.img_mini');
    if (!tgt) return;
    let id = tgt.id;
    let name = id.slice(1);
    this.z.picName = name;
    this.z.loli(this.z.picName + ' txt:', 'color:red');
    console.log(this.z.allFiles[this.z.picIndex])
    let list = tgt.querySelector('.menu_img_list');
    if (!list.style.display) open = 0; // If open, close

    const loliClose = (name) => this.z.loli('closed menu of image ' + name + ' in album ' + this.z.imdbRoot + this.z.imdbDir);

    if (open) { // 1 == do open
      let allist = document.querySelectorAll('.menu_img_list');
      // If another image menu is open, close it:
      for (let list of allist) {
        if (!list.style.display) {
          list.style.display = 'none';
          let name = list.closest('.img_mini').id.slice(1);
          loliClose(name);
          break;
        }
      }
      list.style.display = '';
      this.z.loli('opened menu of image ' + name + ' in album ' + this.z.imdbRoot + this.z.imdbDir);

    } else { // 0 == do close
      list.style.display = 'none';
      loliClose(name);
    }
  }

  <template>
    <button class='menu_img' type="button" title="{{t 'imageMenu'}}"
    {{on 'click' (fn this.toggleMenuImg 1)}}
    {{on 'keydown' this.detectEscClose}}>⡇</button>

    <ul class="menu_img_list" style="display:none">

      <li><p style="text-align:right;color:deeppink;
        font-size:120%;line-height:80%;padding-bottom:0.125rem"
        {{on 'click' (fn this.toggleMenuImg 0)}}>
        × </p>
      </li>

      {{!-- Go-to-origin of linked image --}}
      {{#if this.symlink}}
        <li>
          <p class="goAlbum" style="color:#0b0;font-weight:bold;font-size:90%" title="{{t 'gotext'}} ”{{this.albname}}”"
          {{on 'click' (fn this.homeAlbum this.orig this.z.picName)}}> {{t 'goto'}} </p>
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

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        {{t 'editimage'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
          ○</span>{{t 'hideshow'}}</p></li>
      <li><hr style="margin:0.25rem 0.5rem"></li>

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
          ○</span>{{t 'checkuncheck'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'markhidden'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'invertsel'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        {{t 'placefirst'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        {{t 'placelast'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        {{t 'download'}}</p></li>
      <li><hr style="margin:0.25rem 0.5rem"></li>

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'linkto'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'moveto'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        <span style="font-size:130%;line-height:50%">
        ○</span>{{t 'remove'}}</p></li>

    </ul>

  </template>

}
