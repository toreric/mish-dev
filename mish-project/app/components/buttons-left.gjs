//== Mish left vertical buttons

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import { dialogHelpId } from './dialog-help';

// Left buttons, most without href attribute
export class ButtonsLeft extends Component {
  @service('common-storage') z;
  @service intl;

  someFunction = (param) => {this.z.loli(param, 'color:red');}

  toggleHideFlagged = (e) => {
    if (e) e.stopPropagation();
    if (document.querySelector('.img_mini.hidden')) {
      if (document.querySelector('.img_mini.hidden.invisible')) {
        this.z.showHidden();
      } else {
        this.z.hideHidden();
      }
    }
  }

  toggleMainMenu = (e) => {
    if (e) e.stopPropagation();
    if (document.getElementById("menuMain").style.display === "") {
      this.z.closeMainMenu('');
    } else {
      this.z.openMainMenu();
    }
  }

  toggleNameView = (e) => {
    if (e) e.stopPropagation();
    let value = this.z.displayNames ? '' : 'block';
    this.z.displayNames = value;
  }

  <template>

    <iframe class="intro" src="start.html" style="display:none"></iframe>

    {{!-- LEFT BUTTONS without href attributes --}}
    <div id="smallButtons" draggable="false" ondragstart="return false" style="z-index:10">

      <a id="menuButton" class="smBu" title-2={{t 'buttons.left.main'}} draggable="false" ondragstart="return false" {{on 'click' this.toggleMainMenu}} style="font-family: Comic Sans MS;width:2rem;line-height:80%"><span class="menu">𝌆</span></a>

      <a id="questionMark" class="smBu" title={{t 'buttons.left.help'}} draggable="false" ondragstart="return false" {{on 'click' (fn this.z.toggleDialog dialogHelpId false)}}>?</a>

      {{!-- <a id="reFr" {{on 'click' (fn this.someFunction 'refresh')}} title="NOTE: refresh was reLd" style="display:none"></a> --}}

      <a id="reLd" class="smBu" title={{t 'buttons.left.reload'}} draggable="false" ondragstart="return false" {{on 'click' (fn this.z.openAlbum this.z.imdbDirIndex)}} src="/images/reload.png"></a>

      <a id="toggleName" class="smBu" title={{t 'buttons.left.name'}} draggable="false" ondragstart="return false" style="display:" {{on 'click' (fn this.toggleNameView)}}>N</a>

      <a id="toggleHide" class="smBu" title={{t 'buttons.left.hide'}} draggable="false" ondragstart="return false" style="display:none" {{on 'click' (fn this.toggleHideFlagged)}}></a>

      <a id="saveOrder" class="smBu" title={{t 'buttons.left.save'}} draggable="false" ondragstart="return false" {{on 'click' (fn this.z.saveOrder)}}>S</a>

      <a class="smBu" draggable="false" ondragstart="return false" title={{t 'buttons.left.up'}} style="font:bold 190% sans-serif;line-height:90%" onclick="window.scrollTo(0,0)">↑</a>

    </div>
  </template>
}
