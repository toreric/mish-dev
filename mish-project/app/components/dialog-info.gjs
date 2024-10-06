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
    // e.stopPropagation();
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

  inform = (what) => {
    let obj = document.getElementById(dialogAlertId);
    switch(what) {
      case 'dups':
        if (obj.hasAttribute('open')) {obj.close(); break;}
        this.z.alertMess(this.intl.t('futureFacility'), 5); break;
      case 'qual':
        if (obj.hasAttribute('open')) {obj.close(); break;}
        this.z.alertMess(this.intl.t('xplErrImg'), 5); break;
    }
  }

  // Get information about this image from the server
  actualGetStat = async () => { // ixAlFi is
    let ixAlFi = this.z.allFiles.findIndex(a => {return a.name === this.z.picName;});
      // console.log('ixAlFi = ' + ixAlFi);
    if (ixAlFi > -1) return await this.z.getFilestat(this.z.allFiles[ixAlFi].linkto);
  }
  get getStat() {
    let recordPromise = this.actualGetStat();
    let tmp = new TrackedAsyncData(recordPromise);
    return tmp;
  }

  showStat0 = (stat) => {
    if (!stat) return; // Dismiss any initial reactivity
    let arr = stat.split(BR);
      console.log(arr);
    let txt = BR;

    // Image file path
    if (arr[4]) {
      txt += '<i>' + this.intl.t('Filename') + '</i>: ' + arr[4] + BR;
    } else {
      txt += '<i>' + this.intl.t('Filename') + '</i>: ' + arr[6] + BR;
    }

    // Image quality status
    arr[5] = arr[5].replace(/, /, '\n').replace(/ /g, '&nbsp;')
    txt += '<a class="hoverDark" title-2="' + arr[5] + '" style="font-family:sans-serif;font-variant:small-caps">' + this.intl.t('status') + '</a>';

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

    // Find duplicates
    txt += '<a class="hoverDark" title-1="' + this.intl.t('findImageDups') + '" style="font-family:sans-serif;font-variant:small-caps">';
    txt += this.intl.t('findDuplicates') + '</a> ' + this.intl.t('simiThres');
    txt += ' = <form style="display:inline-block"><input class="threshold" type="number" min="40" max="100" value="70" title="Välj tröskelvärde 40&ndash;100%"></form>%';

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
          <a class="hoverDark" style="border:1px solid #333;border-radius:0.5rem;width:1rem;display:inline-block;height:1rem;font-size:85%;font-weight:bold;text-decoration:none" {{on 'click' (fn this.inform 'qual')}}>&nbsp;?&nbsp;</a>
          {{{this.showStat this.getStat.value}}}
          <a class="hoverDark" style="border:1px solid #333;border-radius:0.5rem;width:1rem;display:inline-block;height:1rem;font-size:85%;font-weight:bold;text-decoration:none" {{on 'click' (fn this.inform 'dups')}}>&nbsp;?&nbsp;</a>
          <br>
        {{else if this.getStat.isPending}}
          . . .
          {{!-- Do nothing, just wait --}}
        {{else if this.getStat.isRejected}}
          <p>REJECTED</p>
        {{/if}}

        {{!-- {{#if this.symlink}}
          <i>Filnamn</i>: {{this.linkto}}<br>
          <a title-2="{{this.errimg}}"
            style="font-family:sans-serif;font-size:80%">STATUS</a><br>
          <span style="color:#0a4;font-size:80%">VISAS HÄR SOM LÄNKAD BILD</span><br>
          <i>Länknamn</i>: <span style="color:#0a4">{{this.filex}}</span><br><br>
        {{else}}
          <i>Filnamn</i>: {{this.filex}}<br>
          <a title-2="{{this.errimg}}"
            style='font-family:sans-serif;font-size:80%'>STATUS</a><br><br>
        {{/if}} --}}

      </main>

      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogInfoId)}}>{{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>
}
