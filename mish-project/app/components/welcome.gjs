//== Mish main component Welcome

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { modifier } from 'ember-modifier';
import { cell } from 'ember-resources';
import { makeDialogDraggable } from 'dialog-draggable';

import { Clock } from './clock';
import { ButtonsLeft } from './buttons-left';
import { ButtonsRight } from './buttons-right';
import { DialogAlert } from './dialog-alert';
import { DialogHelp } from './dialog-help';
import { DialogLogin } from './dialog-login'
import { DialogText } from './dialog-text';
import { DialogXper } from './dialog-xper';
import { default as Header } from './header';
import { Language } from './language';
import { MenuMain } from './menu-main';
import { ViewMain } from './view-main';
import { Spinner } from './spinner';

import { dialogLoginId } from './dialog-login';
import { dialogRightsId } from './dialog-login';
import { dialogXperId } from './dialog-xper';

const returnValue = cell(''); // Never used?
const LF = '\n';
const CRLF = '&#13;&#10;'; // May be used in 'title': the only mod.possible!

makeDialogDraggable();

const resetBorders = () => { //Copy of this.z.resetBorders()
  // Reset all mini-image borders and SRC attributes
  var minObj = document.querySelectorAll('.img_mini img.left-click');
  for (let min of minObj) {
    min.style.border = '0.25px solid #888';
    min.classList.remove('dotted');
  }
}

// Detect any mouse click
document.addEventListener('click', (event) => {
  resetBorders();
});

// Detect closing click outside menuMain (tricky case!)
document.addEventListener('mousedown', (event) => {
  var tmp0 = document.getElementById('menuButton');
  var tmp1 = document.getElementById('menuMain');
  if (tmp1.style.display !== 'none' && event.target !== tmp0 && event.target !== tmp1 && !tmp0.contains(event.target) && !tmp1.contains(event.target)) {
    tmp0.innerHTML = '<span class="menu">𝌆</span>';
    tmp1.style.display = 'none';
    console.log('-"-: closed main menu');
  }
});

class Welcome extends Component {
  @service('common-storage') z;
  @service intl;

  openRights = () => {
    this.z.openModalDialog(dialogRightsId, 0);
  }
  openLogIn = () => {
    this.z.openModalDialog(dialogLoginId, 0);
  }
  getCred = async () => {
    if (!this.z.userStatus) { // only once
      this.z.initBrowser(); // Manipulate browser back-arrow

      // Set default background and text colors
      // Question: Why misfunctions this (here and below) for '.sameBackground'
      // elements, while the same code DOES in the 'this.z.toggleBackg' function?
      document.querySelector('body').style.background = this.z.bkgrColor;
      document.querySelector('body').style.color = this.z.textColor;
      for (let a of document.querySelectorAll('.sameBackground')) a.style.background = this.bkgrColor;
      for (let a of document.querySelectorAll('.sameBackground')) a.style.color = this.textColor;

      // Set a guest user and corresponding allowances
      let allowances = await this.z.getCredentials('Get allowances');
      console.log(allowances);
      this.z.allowances = allowances;

     // Get all recorded user statuses and their allowances + passwordless users
      let cred = (await this.z.getCredentials('Get user name')).split(LF);
      this.z.userStatus = cred[1];
      this.z.allowvalue = cred[2];
      this.z.freeUsers = cred[3];
      this.z.allowFunc(); // SET ALLOWANCES PATTERN important!

      // Get album-collection-qualified catalogs
      let roots = await this.z.getAlbumRoots();
      this.z.imdbRoots = roots.split(LF);

      // Language cookie
      let lng = this.z.getCookie('mish_lang');
      if (lng) this.intl.setLocale([lng]);
      this.z.intlCodeCurr = lng;
      // Background cookie
      if (this.z.getCookie('mish_bkgr') === 'dark') {
        this.z.bkgrColor = '#111';
        this.z.textColor = '#fff';
        this.z.subColor = '#aef';
      }
      if (this.z.getCookie('mish_bkgr') === 'light') {
        this.z.bkgrColor = '#cbcbcb';
        this.z.textColor = '#111';
        this.z.subColor = '#146';
      }
      document.querySelector('body').style.background = this.z.bkgrColor;
      document.querySelector('body').style.color = this.z.textColor;
      for (let a of document.querySelectorAll('.sameBackground')) a.style.background = this.bkgrColor;
      for (let a of document.querySelectorAll('.sameBackground')) a.style.color = this.textColor;
    }
    this.z.openMainMenu();
  }

}

const executeOnInsert = modifier((element, [component]) => {
  component.getCred();
});

export default class extends Welcome {
  <template>

    <div style="position:relative;top:0.5rem;left:0;width:100%;z-index:-2">
      <div {{executeOnInsert this}} class="sameBackground" style="display:flex;justify-content:space-between;margin:-0.9rem 3.25rem 0 4rem;padding-top:0.5rem">
        {{!-- Html inserted here will appear above upon the buildStamp div --}}
        {{!-- So, better give some visibility space for the buildstamp:    --}}
        {{!-- <div style="background:transparent;height:0.75rem;width:100%">&nbsp;</div><br> --}}
        <h1 style="margin:0 4rem 0 0;display:inline">{{t "header"}}</h1>
        <span>

          <button type="button" title="Xperimental" style="background:blueviolet" {{on 'click' (fn this.z.toggleDialog dialogXperId)}}>&nbsp;</button>

          <button type="button" title={{t 'button.backgtitle'}} {{on 'click' (fn this.z.toggleBackg)}}>{{t 'dark'}}/{{t 'light'}}</button>

          <button type="button" {{on 'click' (fn this.openRights)}}>{{t 'button.rightsinfo'}}</button>

          <button type="button" {{on 'click' (fn this.openLogIn)}}>{{t 'button.optlogin'}}</button>

        </span> &nbsp;

        <span>
          {{t 'loggedIn'}}: <b>{{this.z.userName}}</b> {{t 'with'}} [{{this.z.userStatus}}]-{{t 'rights'}}
        </span>
      </div>

      <div class="sameBackground" style="display:flex;justify-content:space-between;margin:0 3.25rem 0 4rem">
        <Language />
        <span>

          {{!-- NOTE: This link is for emergency only if the browser's back arrow fails
          due to problems in the initBrowser-goBack cooperation in the CommonStorage
          service:
          <a {{on 'click' (fn this.z.goBack)}}>&nbsp;&lt;- go back&nbsp;</a> --}}

          {{#if this.z.imdbRoot}}
            <b>”{{this.z.imdbRoot}}”</b>
          {{else}}
            {{t 'noCollSelected'}}
          {{/if}}

        </span>
        <span>{{t 'time.text'}}
          <span><Clock @locale={{this.z.intlCodeCurr}} /></span>
        </span>
      </div>
    </div>
    <div id='highUp'></div>
    <ButtonsLeft />
    <ButtonsRight />
    <Header />
    <ViewMain />
    <MenuMain />
    <DialogLogin />
    <DialogText />
    <DialogHelp />
    <DialogAlert />
    <DialogXper />
    <Spinner />
    <div id='lowDown'></div>
  </template>;
}
