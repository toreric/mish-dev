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

const LF = '\n'; // LINE_FEED
const SA = '‡';  // SUBALBUM indicator, set in server (routes.js)


export class ViewMain extends Component {
  @service('common-storage') z;
  @service intl;

  <template>
    <div style="margin:0 0 0 4rem;width:auto;height:auto;border:0.5px solid lightgray">
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
    if (coco.includes(SA)) {
      let re = new RegExp(String.raw`${SA}.*$`) // If SA is '*' etc. then use ´\\*'
      // Check if there are more subalbums than the primary subalbums
      let more = Number(coco.replace(re, '').replace(/\ *[(0-9+)]+\ +([0-9]+)$/, '$1')) - this.z.subaIndex.length;

      if (more > 0) plus =' (' + this.intl.t('plus') + ' ' + more + ')';
    }
    return plus;
  }

  subaList = () => {return []};  // Subalbum links

  <template>
    {{#if this.z.imdbRoot}}
      <span title={{this.z.imdbDir}}>
        <b>”{{{this.z.imdbDirName}}}”</b>
        {{t 'has'}} {{this.nsub}} {{this.sual}} {{this.nadd}}
      </span>
    {{/if}}
    <p class='albumsHdr' draggable="false" ondragstart="return false">
      <div class="miniImgs">
        {{#each this.subaList as |suba|}}
          <div class="subAlbum" {{fn  (thiz.z.subaSelect suba.album)}}>
            <a class="imDir BLUET" style="background:transparent" title-2="Album ”{{suba.name}}”">
              {{#if suba.image}}
                <img src="rln{{suba.image}}"><br>
              {{/if}}
              <span>{{{suba.name}}}</span>
            </a>
          </div>
        {{else}}
        {{/each}}
      </div>
    </p>
  </template>

}
