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

  menuImg = (e) => {
    if (e) e.stopPropagation();
    let name = e.target.parentElement.id.slice(1);
    this.z.loli('opened menu of image ' + name + ' in album ' + this.z.imdbRoot + this.z.imdbDir);
  }

  <template>
      <button class='menu_img' type="button"
      {{!-- {{on 'click' this.menuImg}}>𝌆</button> --}}
      {{on 'click' this.menuImg}}>⡇</button>
  </template>

}
