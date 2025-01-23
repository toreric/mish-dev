//== Mish main component Welcome
//   It is referenced in 'templates/applications.hbs'

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
import { DialogChoose } from './dialog-choose';
import { DialogFind } from './dialog-find';
import { DialogHelp } from './dialog-help';
import { DialogInfo } from './dialog-info';
import { DialogLogin } from './dialog-login';
import { DialogText } from './dialog-text';
import { DialogXper } from './dialog-xper';
import { DialogUtil } from './dialog-util';
import { default as Header } from './header';
import { Language } from './language';
import { MenuMain } from './menu-main';
import { ViewMain } from './view-main';
import { Spinner } from './spinner';

import { dialogAlertId } from './dialog-alert';
import { dialogFindId } from './dialog-find';
import { dialogHelpId } from './dialog-help';
import { dialogInfoId } from './dialog-info';
import { dialogLoginId } from './dialog-login';
import { dialogRightsId } from './dialog-login';
import { dialogXperId } from './dialog-xper';

const returnValue = cell(''); // Never used?
const LF = '\n';
const CRLF = '&#13;&#10;'; // May be used in 'title': the only mod.possible!

// NOTE: Here makeDialogDraggable() declares 'data-dialog-draggable'
// so it may be further referenced in child elements of any <dialog>
makeDialogDraggable();

// Detect various keys
document.addEventListener('keydown', (event) => {
  event.stopPropagation();
  var key = event.keyCode;
      // console.log('Key ' + key + ' pressed');
  switch(key) {
    case 27:  // Esc
        // console.log(event.target);
      resetBorders();
      for (let d of document.querySelectorAll('dialog')) {
        if (d.hasAttribute('open')) {
          if (d.id === dialogInfoId) d.close();
          return;
        }
      }
      let allist = document.querySelectorAll('.menu_img_list');
      for (let list of allist) list.style.display = 'none';
      if (!document.querySelector('#menuMain').style.display)
        document.querySelector('#menuButton').click(); //close menu
      // The view image is displayed with its navigation buttons:
      if (!document.querySelector('div.nav_links').style.display)
        document.getElementById('go_back').click(); //close view image
      break;
    case 37:  // <
      if (document.activeElement.nodeName === 'TEXTAREA') break;
      document.querySelector('.nav_.prev').click();
      break;
    case 39:  // >
      if (document.activeElement.nodeName === 'TEXTAREA') break;
      document.querySelector('.nav_.next').click();
      break;
    case 65:  // A
      if (document.activeElement.nodeName === 'TEXTAREA') break;
      break;
    case 70:  // F
      if (document.activeElement.nodeName === 'TEXTAREA') break;
      event.preventDefault();
      document.getElementById('searchText').click();
      break;
    case 112: // F1
      toggleDialog(dialogHelpId);
  }
});

// ALL bubbling mousedowns are caught, even programmatical clicks!
document.addEventListener('mousedown', async (event) => {
  // event.preventDefault(); // Kills everything
      // console.log('event:', event);
      // console.log(event.target);
  var tgt = event.target;
  if (
    event.button !== 0 ||// 0=left, 1=wheel, 2=right
    // Within these there should be no extra 'mousedown' action,
    // since there is rather another 'click' detection:
    tgt.closest('.menu_img_list') ||
    tgt.closest('.toggleNavInfo') ||
    tgt.closest('#link_show ul') ||
    tgt.closest('#smallButtons') ||
    tgt.closest('#upperButtons') ||
    tgt.closest('#link_texts') ||
    tgt.closest('.nav_links') ||
    tgt.closest('.tmpHeader') ||
    tgt.closest('.img_show') ||
    tgt.closest('#markShow') ||
    tgt.closest('.menu_img') ||
    tgt.closest('#do_mail') ||
    tgt.closest('dialog')
  ) { return; }
  resetBorders();

  // Close any open image menu
  let allist = document.querySelectorAll('.menu_img_list');
  for (let list of allist) list.style.display = 'none';

  // Detect closing click outside menuMain (tricky case!)
  var tmp0 = document.getElementById('menuButton');
  var tmp1 = document.getElementById('menuMain');
  if (
    tmp1.style.display !== 'none' &&
    tgt !== tmp0 &&
    tgt !== tmp1 &&
    !tmp0.contains(tgt) &&
    !tmp1.contains(tgt)
  ) tmp0.click();
  // Close the show image view, if open
  if (!document.querySelector('div.nav_links').style.display)
    document.getElementById('go_back').click();
  return;
});

const resetBorders = () => { //copy from z
  var minObj = document.querySelectorAll('.img_mini img.left-click');
  for (let min of minObj) {
    min.classList.remove('dotted');
  }
}
const toggleDialog = (dialogId, origPos) => { //copy from z
  let diaObj = document.getElementById(dialogId);
  let what = 'closed ';
  if (diaObj.hasAttribute('open')) {
    diaObj.close();
  } else {
    what = 'opened ';
    if (origPos) diaObj.style.display = '';
    diaObj.show();
  }
  console.log('-"-: ' + what + dialogId);
}

class Welcome extends Component {
  @service('common-storage') z;
  @service intl;

  someFunction = (param) => {this.z.loli(param, 'color:red');}

  get album() {
    return this.z.imdbRoot + this.z.imdbDir;
  }

  openRights = () => {
    this.z.openModalDialog(dialogRightsId, 0);
  }
  openLogIn = () => {
    this.z.openModalDialog(dialogLoginId, 0);
  }

  // To be executed only once before a user is defined with userStatus
  getCred = async () => {
    await new Promise (z => setTimeout (z, 99)); // Allow userStatus to settle
    if (!this.z.userStatus) { // only once

      // Various settings
      this.z.initBrowser();         // Manipulate browser back-arrow
      this.z.maxWarning = 50;       // Set recommended album size, about 100
      this.z.displayNames = 'none'; // Hide image names
      await new Promise (z => setTimeout (z, 99)); // Before awakening the system
      document.querySelector('#toggleName').click(); // Initially hide (donowhy)

      // Read the build stamp files (nodestamp.txt may be initially missing) etc.
      this.z.aboutThis = 'Mish ' + await this.z.execute('cat buildstamp.txt') + ' ' + await this.z.execute('cat nodestamp.txt') + ' and Glimmer by Ember<br>' + await this.z.execute('head -n1 LICENSE.txt');

      // Set a guest user and corresponding allowances
      let allowances = await this.z.getCredentials('Get allowances');
      console.log(allowances); // this is the text table of rights
      this.z.allowances = allowances;

      // Language cookie
      let lng = this.z.getCookie('mish_lang');
      if (lng) this.intl.setLocale([lng]);
      this.z.intlCodeCurr = lng;
      this.z.picFound = this.z.picFoundBaseName +"."+ Math.random().toString(36)
        .slice(2,6); // Each language must update it's found pics name

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

      // NOTE: Language should be set before getCredentials()
      // Get all recorded user statuses and their allowances + passwordless users
      let cred = (await this.z.getCredentials('Get user name')).split(LF);
      this.z.userStatus = cred[1];
      this.z.allowvalue = cred[2];
      this.z.freeUsers = cred[3];
      this.z.allowFunc(); // SET ALLOWANCES PATTERN important!

      // Get album-collection-qualified catalogs
      let roots = await this.z.getAlbumRoots();
      this.z.imdbRoots = roots.split(LF);
    }
    this.z.openMainMenu();
    this.openLogIn();
  }
}

const executeOnInsert = modifier((element, [component]) => {
  component.getCred();
});

export default class extends Welcome {
  <template>

    <div id='highUp'></div>

    <div id="upperButtons" style="position:relative;top:0;left:0;width:100%;padding-top:0.5rem">
      <div {{executeOnInsert this}} class="sameBackground" style="display:flex;justify-content:space-between;margin:0 3.25rem 0 4rem">
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
        <span style="line-height:3rem" info="Also spacing!">

          {{!-- NOTE: This extra commented-out  link is for emergency only if the
          browser's back arrow fails due to problems in the initBrowser-goBack
          cooperation in the CommonStorage service:
          <a {{on 'click' (fn this.z.goBack)}}>&nbsp;&lt;- go back&nbsp;</a> --}}

          {{#if this.z.imdbRoot}}
            {{#if this.z.imdbDir}}
              <a class="" {{on 'click' (fn this.z.openAlbum 0)}}>
                <span style="font:small-caps 0.9rem sans-serif;text-decoration:underline">⌂&nbsp;{{t 'home'}}</span>&nbsp;
              </a>
            {{/if}}
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

    <ButtonsLeft />
    <MenuMain />
    <ButtonsRight />
    <Header />
    <ViewMain />

    <div id='lowDown'></div>
    <p style="font:small-caps 0.9rem sans-serif;color:#ff1493;text-align:center">
      {{this.z.edgeImage}}
    </p>

    <p class="footer" style="text-align:center;font:77% sans-serif">
      {{{this.z.aboutThis}}}
      <br>

      <a id="do_mail" style="font-size:2rem;margin:0" class="smBu" title={{t 'buttons.left.mail'}} {{on 'click' (fn this.someFunction 'doMail')}} src="/images/mail.svg">
      </a>

      <a id="netMeeting" class="smBu" title={{t 'buttons.left.meet'}}
      href="https://meet.jit.si/Minnenfr%C3%A5nS%C3%A4var%C3%A5dalenochHolm%C3%B6n" target="jitsi_window" draggable="false" ondragstart="return false" style="font-size:1.85rem;margin:0;padding:0 0.4rem 0.3rem 0.2rem" onclick="this.hide">▣</a>

    </p>

    <DialogLogin />
    <DialogText />
    <DialogFind />
    <DialogHelp />
    <DialogInfo />
    <DialogAlert />
    <DialogChoose />
    <DialogXper @content={{this.album}} />
    <DialogUtil />
    <Spinner />

  </template>;
}
