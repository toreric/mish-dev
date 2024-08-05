//== Mish main display view

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
// import { action } from '@ember/object';
// import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { htmlSafe } from '@ember/template';

import sortableGroup from 'ember-sortable/modifiers/sortable-group';
import sortableItem from 'ember-sortable/modifiers/sortable-item';

import { dialogAlertId } from './dialog-alert';

const LF = '\n'; // LINE_FEED
const SA = '‡';  // SUBALBUM indicator, NOTE! set in server (routes.js)


export class ViewMain extends Component {
  @service('common-storage') z;
  @service intl;

  <template>
    <div style="margin:0 0 0 4rem;width:auto;height:auto">
      <SubAlbums />
      <MiniImages />
    </div>
  </template>

}

class SubAlbums extends Component {
  @service('common-storage') z;
  @service intl;

  get nsub() {
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

  imdbDirs = (i) => {
    return this.z.imdbDirs[i];
  }

  dirName = (i) => {
    return this.z.imdbDirs[i].replace(/^(.*\/)*([^/]+)$/, '$2').replace(/_/g, ' ');
  }

  setLabel = (i) => {
    let label = this.z.imdbLabels[i];
    if (!label) label = 'images/empty.gif';
    return label;
  }

  <template>
    <p class='albumsHdr' draggable="false" ondragstart="return false">
      <div class="miniImgs">
        {{#if this.z.imdbRoot}}
          <span title={{this.z.imdbDir}}>
            <b>”{{{this.z.imdbDirName}}}”</b>
            {{t 'has'}} {{this.nsub}} {{this.sual}}
            <span title={{t 'plusExplain'}}>{{this.nadd}}</span>
          </span>
          <br>
          {{#each this.z.subaIndex as |i|}}
            <div class="subAlbum" title={{this.imdbDirs i}}
              {{on 'click' (fn this.z.openAlbum i)}}>
              <a class="imDir" style="background:transparent" title-2="Album ”{{this.dirName i}}”">
                  <img src={{this.setLabel i}} alt="Album ”{{this.dirName i}}”"><br>
                <span style="font-size:85%;color:{{this.z.subColor}}">{{this.dirName i}}</span>
              </a>
            </div>
          {{/each}}
        {{/if}}
      </div>
    </p>
  </template>

}

class MiniImages extends Component {
  @service('common-storage') z;
  @service intl;

  @tracked lastDragged;
  @tracked items = [];

  allFiles = () => {
    this.items = [];
    let m = this.z.allFiles.length;
    for (let i=0;i<m;i++) {
      // this.items.push({img: this.z.allFiles[i].mini, name: this.z.allFiles[i].name});
      this.items.push(this.z.allFiles[i]);
      this.lastDragged = '';
    }
  }

  reorderItems = (itemModels, draggedModel) => {
    this.items = itemModels;
    this.lastDragged = draggedModel;
  }

  shortenNoTags = (txt) => {
    let tmp = txt.toString().replace(/<(?:.|\n)*?>/gm, ""); // Remove <tags>
    return tmp.slice(0, 23) ? tmp.slice(0, 23) : '&nbsp;';
  }

  noTags = (txt) => {
    let tmp = txt.toString().replace(/<(?:.|\n)*?>/gm, ""); // Remove <tags>
    return tmp ? tmp : ' ';
  }

  handleVisualClass = {
    UP: 'sortable-handle-up',
    DOWN: 'sortable-handle-down',
    LEFT: 'sortable-handle-left',
    RIGHT: 'sortable-handle-right',
  };

  itemVisualClass = 'sortable-item--active';

  <template>

    {{#if this.z.imdbRoot}}
      <p>
        <span style="display:none">Press to (re)load images for
        <button id="loadMiniImages" type="button" {{on 'click' this.allFiles}}>{{{this.z.imdbDirName}}}</button></span>
        Last dragged item: {{this.lastDragged.name}}
      </p>
    {{else}}
      <p style="text-align:center">
        {{t 'albumcollselect'}}
      </p>
    {{/if }}

    <div class="alb_mini" style="width:;display:flex;
      flex-wrap:wrap;padding:0;align-items:baseline;
      justify-content:left;position:relative"
      {{sortableGroup
        direction='grid'
        onChange=this.reorderItems
        disabled=false
        itemVisualClass=this.itemVisualClass
        handleVisualClass=this.handleVisualClass
      }}
    >
      {{#each this.items as |item|}}
        <div class="img_mini"
          {{sortableItem
            model=item
            spacing=0
            distance=5
          }}
        >
          <img src="{{item.mini}}" class="left-click" title="" draggable="false" ondragstart="return false">
          <div class="img_name" style="display:none">
            {{item.name}}
          </div>
          <div class="img_txt1" draggable="false" ondragstart="return false" title-2="{{this.noTags item.txt1}}">
            {{{this.shortenNoTags item.txt1}}}
          </div>
          <div class="img_txt2" draggable="false" ondragstart="return false" title-2="{{this.noTags item.txt2}}">
            {{{this.shortenNoTags item.txt2}}}
          </div>
          {{!-- <span class='handle' {{sortableHandle}}>&varr;</span> --}}
        </div>
      {{/each}}
    </div>

  </template>
}
