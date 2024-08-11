//== Mish main display view

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
// import { action } from '@ember/object';
import { eq } from 'ember-truth-helpers';
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

  get nsub() { // No of subalbums to this album
    let res =  this.z.subaIndex.length;
    if (res < 1) res = this.intl.t('no'); // 'inget'
    return res;
  }

  get sual() { // Subalbum(s) text
    if (this.z.subaIndex.length === 1) {
      return this.intl.t('subalbum');
    } else {
      return this.intl.t('subalbums');
    }
  }

  get nadd() { // No of addititonal subsub...albums to this album
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
          <span title-2="{{this.z.imdbRoot}}{{this.z.imdbDir}}">
            <b>”{{{this.z.imdbDirName}}}”</b>
            {{t 'has'}} {{this.nsub}} {{this.sual}}
            <span title-2={{t 'plusExplain'}}>{{this.nadd}}</span>
          </span>
          <br>
          {{#each this.z.subaIndex as |i|}}
            <div class="subAlbum" title="" {{on 'click' (fn this.z.openAlbum i)}}>
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

  allFiles = () => { // Copies 'allFiles' to 'items'
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

  noTags = (txt) => {
    let tmp = txt.toString().replace(/<(?:.|\n)*?>/gm, ""); // Remove <tags>
    return tmp ? tmp : ' ';
  }

  noTagsShort = (txt) => {
    let tmp = txt.toString().replace(/<(?:.|\n)*?>/gm, ""); // Remove <tags>
    return tmp.slice(0, 23) ? tmp.slice(0, 23) : '&nbsp;';
  }

  homeAlbum = async (path, fileName) => { // was parAlb
    // Convert the relative path of the linked-file target,
    // to conform with z.imdbDirs server list, rooted at album root
    let dir = path.replace(/^([.]*\/)*/, '/').replace(/\/[^/]+$/, '');
    let name = path.replace(/^([^/]*\/)*([^/]+)\/[^/]+$/, "$2")
    // dir is the home album (w index i) for path
    let i = this.z.imdbDirs.indexOf(dir);
    if (i < 0) {
      this.z.alertRemove();
      this.z.alertMess(this.intl.t('albumMissing') + ':<br><br><p style="width:100%;text-align:center;margin:0">”' + this.z.removeUnderscore(name) + '”</p>');
      return;
    } else {
      this.z.openAlbum(i);
      let size = this.z.albumAllImg(i);
      // Allow for the rendering of mini images and preload of view images
      await new Promise (z => setTimeout (z, size*60 + 100));
      this.z.gotoMinipic(fileName);
    }
  }

  itemVisualClass = 'sortable-item--active';

  <template>

    {{#if this.z.imdbRoot}}

      {{!-- Here is an invisible button for album images load, used
            programmatically by z.openAlbum, display it for manual use! --}}
      <p><span style="display:none">Press to (re)load images for
      <button id="loadMiniImages" type="button" {{on 'click' this.allFiles}}>{{{this.z.imdbDirName}}}</button></span>
      Last dragged item: {{this.lastDragged.name}}</p>

    {{else}}

      {{!-- Remind of choosing a root collection/album --}}
      <p style="text-align:center">{{t 'albumcollselect'}}</p>

    {{/if }}

    {{!-- The album's thumnail images are a display group --}}
    <div class="alb_mini" style="width:;display:flex;
      flex-wrap:wrap;padding:0;align-items:baseline;
      justify-content:left;position:relative"
      {{sortableGroup
        direction='grid'
        onChange=this.reorderItems
        disabled=false
        itemVisualClass=this.itemVisualClass
      }}
    >
      {{!-- The thumnail images are displayed --}}
      {{#each this.items as |item|}}
        <div id="i{{item.name}}" class="img_mini {{item.symlink}}"
          {{sortableItem
            model=item
            spacing=0
            distance=5
          }}
        >
          {{!-- Arrange the go-to-origin-button for linked images --}}
          {{#if item.symlink}}
            <button class="goAlbum" title-2="{{t 'gotext'}} ”{{item.albname}}”" {{on 'click' (fn this.homeAlbum item.orig item.name)}}> {{t 'goto'}} </button>
          {{/if}}

          {{!-- Here comes the thumbnail --}}
          <img src="{{item.mini}}" class="left-click" title="{{this.z.imdbRoot}}{{item.linkto}}" draggable="false" ondragstart="return false">

          {{!-- This is the image name, should be unique --}}
          <div class="img_name" style="display:{{this.z.displayName}}">
            {{item.name}}
          </div>

          {{!-- The text for Xmp.dc.description metadata --}}
          <div class="img_txt1" draggable="false" ondragstart="return false" title-2="{{this.noTags item.txt1}}">
            {{{this.noTagsShort item.txt1}}}
          </div>

          {{!-- The text for Xmp.dc.creator metadata --}}
          <div class="img_txt2" draggable="false" ondragstart="return false" title-2="{{this.noTags item.txt2}}">
            {{{this.noTagsShort item.txt2}}}

          </div>
          {{!-- <span class='handle' {{sortableHandle}}>&varr;</span> --}}

        </div>
      {{/each}}
    </div>

  </template>
}
