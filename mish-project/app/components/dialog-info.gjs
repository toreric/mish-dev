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

export const dialogInfoId = "dialogInfo";
const LF = '\n'   // Line Feed == New Line
const BR = '<br>' // HTML line break

export class DialogInfo extends Component {
  @service('common-storage') z;
  @service intl;

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogInfoId).open) this.z.closeDialog(dialogInfoId);
    }
  }

  // Get information about this image from the server
  actualGetStat = async () => { // ixAlFi is
    let ixAlFi = await this.z.allFiles.findIndex(a => {return a.name === this.z.picName;});
console.log('ixAlFi = ' + ixAlFi);
    if (ixAlFi > -1) return await this.z.getFilestat(this.z.allFiles[ixAlFi].linkto);
  }
  @cached
  get getStat() {
    let recordPromise = this.actualGetStat();
    return new TrackedAsyncData(recordPromise);
  }

  // getStat = () => {
  //   let ixAlFi = this.z.allFiles.findIndex(a => {return a.name === this.z.picName;});
  //   return new Promise((resolve, reject) => {
  //     if (ixAlFi > -1) this.z.getFilestat(this.z.allFiles[ixAlFi].linkto).then((result) => {
  //       return String(result);
  //     });
  //   });
  // }

  <template>
    <dialog id="dialogInfo" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <div style="width:99%">
          <p>{{t 'dialog.info.header'}}<span></span></p>
        </div>
        <div>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogInfoId)}}>×</button>
        </div>
      </header>

      <main style="padding:1rem;text-align:center;min-height:10rem;color:blue">

        <i>{{t 'Name'}}</i>: <span style="color:black">{{this.z.picName}}</span>
        <br>
        {{!-- {{{this.z.infotext}}} --}}

        {{#if this.getStat.isResolved}}
          {{{this.getStat.value}}}
        {{else if this.getStat.isPending}}
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

        <br><a onclick="" title-2="Sök dubletter till den här bilden" style="font-family:sans-serif;font-size:80%">SÖK DUBLETTBILDER</a>
          &nbsp;med likhetströskel =
        <form action="javascript:void(0)" style="display:inline-block"><input class="threshold" type="number" min="40" max="100" value="70" title="Välj tröskelvärde 40&ndash;100%"></form>%<br>

      </main>

      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogInfoId)}}>{{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>
}
