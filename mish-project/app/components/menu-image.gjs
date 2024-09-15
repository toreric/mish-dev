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

  toggleMenuImg = (e) => {

    const allow = this.z.allow; // permissions

    if (e) e.stopPropagation();
    let id = e.target.closest('.img_mini').id;
    let name = id.slice(1);
    let list = document.querySelector('#' + this.z. escapeDots(id) + ' .menu_img_list');
    if (list.style.display) {
      list.style.display = ''
      this.z.loli('opened menu of image ' + name + ' in album ' + this.z.imdbRoot + this.z.imdbDir);
    } else {
      list.style.display = 'none'
      this.z.loli('closed menu of image ' + name + ' in album ' + this.z.imdbRoot + this.z.imdbDir);
    }
  }

  <template>
    <button class='menu_img' type="button"
    {{!-- {{on 'click' this.menuImg}}>𝌆</button> --}}
    {{on 'click' this.toggleMenuImg}}>⡇</button>
    <ul class="menu_img_list" style="display:none">
      <li><a {{on 'click' this.toggleMenuImg}}>&nbsp;</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>Information</a></li>

      {{#if this.z.allow.textEdit}}
        <li><a {{on 'click' this.toggleMenuImg}}>Redigera text...</a></li>
      {{/if}}

      <li><a {{on 'click' this.toggleMenuImg}}>Redigera bild...</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>○Göm eller visa</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>───────────────</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>○Markera/avmarkera alla</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>○Markera bara dolda</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>○Invertera markeringar</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>Placera först</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>Placera sist</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>Ladda ned...</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>───────────────</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>○Länka till...</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>○Flytta till...</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>○RADERA...</a></li>
      <li><a {{on 'click' this.toggleMenuImg}}>&nbsp;</a></li>
    </ul>

  </template>

}
