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

export const menuMainClass = 'menu_img'; // needed??
const LF = '\n'; // LINE_FEED

export class MenuImage extends Component {
  @service('common-storage') z;
  @service intl;

  @tracked ixAllFiles = -1;

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
        this.z.alertRemove();
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
    if (this.ixAllFiles < 0) return a; //important
    let b = this.z.allFiles[this.ixAllFiles];
    if (b) a = b.albname; //name of home album
    return a;
  }
  get orig() {
    let a = '';
    if (this.ixAllFiles < 0) return a; //important
    let b = this.z.allFiles[this.ixAllFiles];
    if (b) a = b.orig; //path to home album
    return a;
  }
  get symlink() {
    let a = '';
    if (this.ixAllFiles < 0) return a; //important
    let b = this.z.allFiles[this.ixAllFiles];
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
    this.ixAllFiles = this.z.allFiles.findIndex(a => {return a.name === name;});
    let list = tgt.querySelector('.menu_img_list');
    if (!list.style.display) open = 0;

    const loliClose = (name) => this.z.loli('closed menu of image ' + name + ' in album ' + this.z.imdbRoot + this.z.imdbDir);

    if (open) { // 1 == do open
      // If another image menu is open, close it:
      let allist = document.querySelectorAll('.menu_img_list');
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
    {{on 'click' (fn this.toggleMenuImg 1)}}>⡇</button>

    <ul class="menu_img_list" style="display:none">
      <li><p style="text-align:right;color:deeppink;
        font-size:120%;line-height:80%;padding-bottom:0.125rem"
        {{on 'click' (fn this.toggleMenuImg 0)}}>
        × </p>
      </li>

      {{!-- Go-to-origin of linked image --}}
      {{#if this.symlink}}
        <li>
          <p class="goAlbum" style="color:#0b0;font-weight:bold;font-size:85%" title="{{t 'gotext'}} ”{{this.albname}}”"
          {{on 'click' (fn this.homeAlbum this.orig this.z.picName)}}> {{t 'goto'}} </p>
        </li>
      {{/if}}

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        {{t 'information'}}</p></li>

      {{#if this.z.allow.textEdit}}
        <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
          {{t 'editext'}}</p></li>
      {{/if}}

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        {{t 'editimage'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ {{t 'hideshow'}}</p></li>
      <li><hr style="margin:0.25rem 0.5rem"></li>

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ {{t 'checkuncheck'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ {{t 'markhidden'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ {{t 'invertsel'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        {{t 'placefirst'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        {{t 'placelast'}}</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        {{t 'download'}}</p></li>
      <li><hr style="margin:0.25rem 0.5rem"></li>

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ Länka till...</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ Flytta till...</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ RADERA...</p></li>
    </ul>

  </template>

}
