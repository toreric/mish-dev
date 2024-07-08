//== Mish main display view

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import { dialogAlertId } from './dialog-alert';
// import EmberTooltip from './ember-tooltip';

const LF = '\n'; // LINE_FEED
const SA = '‡';  // SUBALBUM indicator, NOTE! set in server (routes.js)


export class ViewMain extends Component {
  @service('common-storage') z;
  @service intl;

  <template>
    <div style="margin:0 0 0 4rem;width:auto;height:auto">
      <SubAlbums />
    </div>
  </template>

}

class SubAlbums extends Component {
  @service('common-storage') z;
  @service intl;

  get  nsub() {
    let res =  this.z.subaIndex.length;
    if (res < 1) res = this.intl.t('no'); // 'inget'
    return res;
  }

  get sual() {
    if (this.z.subaIndex.length === 1) {
      return this.intl.t('subalbum');
    } else {
      return this.intl.t('subalbums');
    }
  }

  get nadd() {
    // this.z.loli(this.z.imdbDirIndex);
    let coco = '';
    if (this.z.imdbCoco) coco = this.z.imdbCoco[this.z.imdbDirIndex];
    let plus= '';
    if (coco && coco.includes(SA)) { // Avoids error if imdbDirIndex is out of range
      let re = new RegExp(String.raw`${SA}.*$`) // If SA is '*' etc. then use ´\\*'
      // Check if there are more subalbums than the primary subalbums
      let more = Number(coco.replace(re, '').replace(/\ *[(0-9+)]+\ +([0-9]+)$/, '$1')) - this.z.subaIndex.length;

      if (more > 0) plus =' (' + this.intl.t('plus') + ' ' + more + ')';
    }
    return plus;
  }

  wait = async () => {
    await new Promise (z => setTimeout (z, 499)); // Soon allow next
  }

  imdbDirs = (i) => {
    return this.z.imdbDirs[i];
  }

  imdbLabels = (i) => {
    return this.z.imdbLabels[i];
  }

  dirName = (i) => {
    return this.z.imdbDirs[i].replace(/^(.*\/)*([^/]+)$/, '$2').replace(/_/g, ' ');
  }

  // subColor = () => {
  //   return this.z.subColor;
  // }

  <template>
    {{!-- <EmberTooltip /> --}}
    <p class='albumsHdr' draggable="false" ondragstart="return false">
      <div class="miniImgs">
        {{#if this.z.imdbRoot}}
          <span title={{this.z.imdbDir}}
          {{!-- {{this.wait}} --}}
          >
            <b>”{{{this.z.imdbDirName}}}”</b>
            {{t 'has'}} {{this.nsub}} {{this.sual}} {{this.nadd}}
          </span>
          <br>
          {{#each this.z.subaIndex as |i|}}
            <div class="subAlbum" title={{this.imdbDirs i}} {{on 'click' (fn this.z.openAlbum i)}}>
              <a class="imDir" style="background:transparent"
                {{!-- {{ember-tooltip "This is a tooltip!"}} --}}
              >
                {{!-- {{#if suba.image}} --}}
                  <img src="{{this.imdbLabels i}}"><br>
                {{!-- {{/if}} --}}
                <span style="font-size:85%;color:{{this.z.subColor}}">{{this.dirName i}}</span>
              </a>
            </div>
          {{else}}
          {{/each}}
        {{/if}}
      </div>
    </p>
  </template>

}
