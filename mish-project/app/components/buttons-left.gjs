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

  someFunction = (param) => {this.z.loli(param);}

  toggleMainMenu = () => {
    if (document.getElementById("menuMain").style.display === "") {
      this.z.closeMainMenu('main menu button');
    } else {
      this.z.openMainMenu();
    }
  }

  toggleNameView = () => {
    let value = document.querySelector('div.img_name').style.display ? '' : 'none';
    for (let name of document.querySelectorAll('div.img_name')) {
      name.style.display = value;
    }
  }

  <template>

    <iframe class="intro" src="start.html" style="display:none"></iframe>

    <div id="smallButtons" draggable="false" ondragstart="return false" style="z-index:10">

      <a id="menuButton" class="smBu" title-2={{t 'buttons.left.main'}} draggable="false" ondragstart="return false" {{on 'click' this.toggleMainMenu}} style="font-family: Comic Sans MS;width:2rem;line-height:80%"><span class="menu">☰</span></a>

      <a id="questionMark" class="smBu" title-2={{t 'buttons.left.help'}} draggable="false" ondragstart="return false" {{on 'click' (fn this.z.toggleDialog dialogHelpId false)}}>?</a>

      <a id="reFr" {{on 'click' (fn this.someFunction 'refresh')}} title="NOTE: refresh was reLd" style="display:none"></a>

      <a id="reLd" class="smBu" title-2={{t 'buttons.left.reload'}} draggable="false" ondragstart="return false" {{on 'click' (fn this.someFunction 'reload')}} src="/images/reload.png"></a>

      <a id="toggleName" class="smBu" title-2={{t 'buttons.left.name'}} draggable="false" ondragstart="return false" style="display:" {{on 'click' (fn this.toggleNameView)}}>N</a>

      <a id="toggleHide" class="smBu" title-2={{t 'buttons.left.hide'}} draggable="false" ondragstart="return false" style="display:" {{on 'click' (fn this.someFunction 'toggleHideFlagged')}}></a>

      <a id="saveOrder" class="smBu" title-2={{t 'buttons.left.save'}} draggable="false" ondragstart="return false" {{on 'click' (fn this.someFunction 'saveOrder(true)')}}>S</a>

      <a id="do_mail" class="smBu" title-2={{t 'buttons.left.mail'}} {{on 'click' (fn this.someFunction 'doMail')}} src="/images/mail.svg" style="display:"></a>

      <a class="smBu" draggable="false" ondragstart="return false" title-2={{t 'buttons.left.up'}} style="font:bold 190% sans-serif;line-height:90%" onclick="window.scrollTo(0,0)">↑</a>

      <a id="netMeeting" class="smBu" title-2={{t 'buttons.left.meet'}}
      href="https://meet.jit.si/Minnenfr%C3%A5nS%C3%A4var%C3%A5dalenochHolm%C3%B6n" target="jitsi_window" draggable="false" ondragstart="return false" style="display:;padding:0 0.25em 0.2em 0.125em;line-height:1.25em" onclick="this.hide">▣</a>

    </div>
  </template>
}
