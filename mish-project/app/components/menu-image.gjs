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
          // let size = this.z.albumAllImg(i);
          // // Allow for the rendering of mini images and preload of view images
          // await new Promise (z => setTimeout (z, size*60 + 100)); // album load
      this.z.gotoMinipic(fileName);
    }
  }

  get albname() {
    if (this.ixAllFiles < 0) return; //important
    let a = this.z.allFiles[this.ixAllFiles].albname; //name of home album
    return a;
  }
  get orig() {
    if (this.ixAllFiles < 0) return; //important
    let a = this.z.allFiles[this.ixAllFiles].orig; //path to home album
    return a;
  }
  get symlink() {
    if (this.ixAllFiles < 0) return; //important
    let a = this.z.allFiles[this.ixAllFiles].symlink; //has a home album
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
    <button class='menu_img' type="button"
    {{!-- {{on 'click' this.menuImg}}>𝌆</button> --}}
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
          <p class="goAlbum" style="color:#0b0" title="{{t 'gotext'}} ”{{this.albname}}”"
          {{on 'click' (fn this.homeAlbum this.orig this.z.picName)}}> {{t 'goto'}} </p>
        </li>
      {{/if}}

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        Information</p></li>

      {{#if this.z.allow.textEdit}}
        <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
          Redigera text...</p></li>
      {{/if}}

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        Redigera bild...</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ Göm eller visa</p></li>
      <li><hr style="margin:0.25rem 0.5rem"></li>

      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ Markera/avmarkera alla</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ Markera bara dolda</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ Invertera markeringar</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        Placera först</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        Placera sist</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        Ladda ned...</p></li>
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
