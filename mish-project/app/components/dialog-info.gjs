//== Mish individual file information dialog

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { htmlSafe } from '@ember/template';
import { MenuImage } from './menu-image';

import { cached } from '@glimmer/tracking';
import { TrackedAsyncData } from 'ember-async-data';

import { dialogAlertId } from './dialog-alert';

export const dialogInfoId = "dialogInfo";
const LF = '\n';   // Line Feed == New Line
const BR = '<br>'; // HTML line break

// Detect closing Esc key
const detectEscClose = (e) => {
  e.stopPropagation();
  if (e.keyCode === 27) { // Esc key
    let diaObj = document.getElementById(dialogInfoId);
    if (diaObj.open) {
      diaObj.close();
      console.log('-"-: closed ' + dialogInfoId);
    }
  }
}

export class DialogInfo extends Component {
  @service('common-storage') z;
  @service intl;

  @tracked imQual = '?';

  inform = (what) => {
    let obj = document.getElementById(dialogAlertId);
    switch(what) {
      case 'dups':
        if (obj.hasAttribute('open')) {obj.close(); break;}
        this.z.alertMess('<div style="text-align:center;font-weight:normal;color:#000">' + this.intl.t('findImageDups') + '</div>' + BR + this.intl.t('futureFacility'), 15); break;
      case 'qual':
        if (obj.hasAttribute('open')) {obj.close(); break;}
        this.z.alertMess(this.intl.t('xplErrImg') + BR + BR + '<div style="text-align:center;font-weight:normal;color:#000">' + this.imQual + '</div>', 15); break;
    }
  }

  // Get information about this image from the server
  actualGetStat = async () => {
    let i = this.z.picIndex;
    if (i > -1) return await this.z.getFilestat(this.z.allFiles[i].linkto);
  }
  get getStat() {
    let recordPromise = this.actualGetStat();
    let tmp = new TrackedAsyncData(recordPromise);
    return tmp;
  }

  showStat0 = (stat) => {
    if (!stat) return; // Dismiss any initial reactivity
    let arr = stat.split(BR);
    // Image quality status
    if (arr[5] === 'NA') {
      this.imQual = this.intl.t('notAvailable');
    } else {
      this.imQual = arr[5].replace(/, /, '\n');//.replace(/ /g, '&nbsp;');
    }
      // this.z.loli('DialogInfo triggered for ' + arr[6] + ':', 'color:#ff7de9');
      // console.log(arr);
    let txt = BR;

    // Image file path
    txt += '<i>' + this.intl.t('Filename') + '</i>: ';
    if (arr[4]) {
      txt += arr[4] + BR;
    } else {
      txt += arr[6] + BR;
    }

    return txt;
  }

  showStat = (stat) => {
    if (!stat) return; // Dismiss any initial reactivity
    let arr = stat.split(BR);
    let txt = BR;

    // Linked image
    if (arr[4]) {
      txt += '<span style="color:#0a4;font-family:sans-serif;font-variant:small-caps">' + this.intl.t('explainLink') + ':</span>' + BR;
      txt += '<i>' + this.intl.t('Linkname') + '</i>:<span style="color:#0a4"> ' + arr[6] + '</span>' + BR;
    }

    let NA = '<span style="color:#b0f">' + this.intl.t('notAvailable') + '</span>';

    // Image size
    txt += '' + BR + '<i>' + this.intl.t('Size') + '</i>: ' + arr[0] + BR;
    if (arr[1] === 'NA') arr[1] = NA;
    txt += '<i>' + this.intl.t('Dimension') + '</i>: ' + arr[1] + BR + BR;

    // Date-time information
    if (arr[2] === 'NA') arr[2] = NA;
    txt += '<i>' + this.intl.t('Phototime') + '</i>: ' + arr[2] + BR;
    txt += '<i>' + this.intl.t('Moditime') + '</i>: ' + arr[3] + BR + BR;

    return txt;
  }

  <template>
    <dialog id="dialogInfo" {{on 'keydown' detectEscClose}}>
      <header data-dialog-draggable>
        <div style="width:99%">
          <p>{{t 'dialog.info.header'}}<span></span></p>
        </div>
        <div>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogInfoId)}}>×</button>
        </div>
      </header>

      <main style="padding:1rem 1rem 1.5rem 1rem;text-align:center;min-height:10rem;color:blue">

        <i>{{t 'Name'}}</i>: <span style="color:black">{{this.z.picName}}</span>
        <br>
        {{!-- {{{this.z.infotext}}} --}}

        {{#if this.getStat.isResolved}}
          {{{this.showStat0 this.getStat.value}}}
          <a class="hoverDark" style="font-family:sans-serif;font-variant:small-caps" title-2="{{{this.imQual}}}" {{on 'click' (fn this.inform 'qual')}}>{{t 'status'}}</a>

          {{{this.showStat this.getStat.value}}}

          {{!-- Find duplicates --}}
          <a class="hoverDark" title-1="{{t 'findImageDups'}}" style="font-family:sans-serif;font-variant:small-caps" {{on 'click' (fn this.inform 'dups')}}>{{t 'findDuplicates'}}</a> {{t 'simiThres'}} = <form style="display:inline-block"><input class="threshold" type="number" min="40" max="100" value="70" title="{{t 'selectTreshold'}} 40&ndash;100%"></form>%
          <br>
        {{else if this.getStat.isPending}}
          . . .
          {{!-- Do nothing, just wait --}}
        {{else if this.getStat.isRejected}}
          <p>REJECTED</p>
        {{/if}}

      </main>

      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogInfoId)}}>{{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>
}
