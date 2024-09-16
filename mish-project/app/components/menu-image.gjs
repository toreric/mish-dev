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

  toggleMenuImg = async (open, e) => {

    const allow = this.z.allow; // permissions

    if (e) e.stopPropagation();
    let tgt = e.target.closest('.img_mini');
    if (!tgt) return;
    let id = tgt.id;
    let name = id.slice(1);
    let list = tgt.querySelector('.menu_img_list');
    // document.querySelector('#' + this.z. escapeDots(id) + ' .menu_img_list');
    // if (!list.style.display) open = 0;
    if (open) { // 1 == do open
      list.style.display = '';
      this.z.loli('opened menu of image ' + name + ' in album ' + this.z.imdbRoot + this.z.imdbDir);
    } else { // 0 == do close
      list.style.display = 'none';
      await new Promise (z => setTimeout (z, 99));
      this.z.loli('closed menu of image ' + name + ' in album ' + this.z.imdbRoot + this.z.imdbDir);
    }
  }

  <template>
    <button class='menu_img' type="button"
    {{!-- {{on 'click' this.menuImg}}>𝌆</button> --}}
    {{on 'click' (fn this.toggleMenuImg 1)}}>⡇</button>
    <ul class="menu_img_list" style="display:none">
      <li><p style="text-align:right;color:deeppink;font-size:120%" {{on 'click' (fn this.toggleMenuImg 0)}}>
        ×</p></li>
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
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        <hr></p></li>
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
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        <hr></p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ Länka till...</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ Flytta till...</p></li>
      <li><p {{on 'click' (fn this.toggleMenuImg 0)}}>
        ○ RADERA...</p></li>
    </ul>

  </template>

}
