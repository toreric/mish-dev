//== Mish left vertical buttons

import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import { closeDialog, toggleDialog } from './dialog-functions'

import { menuMainId } from './menu-main'
import { dialogHelpId } from './dialog-help';

const someFuntion = (param) => console.log(param);

// Left buttons, most without href attribute
export const ButtonsLeft = <template>
  <!-- Start "home" page: the Information page-->
  <iframe class="intro" src="start.html" style="display:none"></iframe>

  <div id="smallButtons" draggable="false" ondragstart="return false">

    <a id="menuButton" class="smBu" title={{t 'buttons.left.main'}} draggable="false" ondragstart="return false" {{on "click" (fn someFuntion 'toggleMainMenu(imdbRoot)')}} style="z-index:16;font-family: Comic Sans MS;width:1.25em;line-height:80%">☰</a>

    <a id="questionMark" class="smBu" title={{t 'buttons.left.help'}} draggable="false" ondragstart="return false" {{on "click" (fn toggleDialog dialogHelpId)}}>?</a>

    <a id="reFr" {{on "click" (fn someFuntion 'refresh')}} title="NOTE: refresh was reLd" style="display:none"></a>

    <a id="reLd" class="smBu" title={{t 'buttons.left.reload'}} draggable="false" ondragstart="return false" {{on "click" (fn someFuntion 'reload')}} src="/images/reload.png"></a>

    <a id="toggleName" class="smBu" title={{t 'buttons.left.name'}} draggable="false" ondragstart="return false" style="display:" {{on "click" (fn someFuntion 'toggleNameView')}}>N</a>

    <a id="toggleHide" class="smBu" title={{t 'buttons.left.hide'}} draggable="false" ondragstart="return false" style="display:" {{on "click" (fn someFuntion 'toggleHideFlagged')}}></a>

    <a id="saveOrder" class="smBu" title={{t 'buttons.left.save'}} draggable="false" ondragstart="return false" {{on "click" (fn someFuntion 'saveOrder(true)')}}>S</a>

    <a id="do_mail" class="smBu" title={{t 'buttons.left.mail'}} {{on "click" (fn someFuntion 'doMail')}} src="/images/mail.svg" style="display:"></a>

    <a class="smBu" draggable="false" ondragstart="return false" title={{t 'buttons.left.up'}} style="font:bold 190% sans-serif;line-height:90%" onclick="window.scrollTo(0,0)">↑</a>

    <a id="netMeeting" class="smBu" title={{t 'buttons.left.meet'}}
    href="https://meet.jit.si/Minnenfr%C3%A5nS%C3%A4var%C3%A5dalenochHolm%C3%B6n" target="jitsi_window" draggable="false" ondragstart="return false" style="display:;padding:0 0.25em 0.2em 0.125em;line-height:1.25em" onclick="this.hide">▣</a>

  </div>
</template>
