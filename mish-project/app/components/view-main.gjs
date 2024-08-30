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
import he from 'he';
// USE: <div title={{he.decode 'text'}}></div> he = HTML entities
// or  txt = he.decode('text')  or  txt = he.encode('text')

import sortableItem from 'ember-draggable-modifiers/modifiers/sortable-item';
import { insertBefore, insertAfter, removeItem } from 'ember-draggable-modifiers/utils/array';

// import sortableGroup from 'ember-sortable/modifiers/sortable-group';
// import sortableItem from 'ember-sortable/modifiers/sortable-item';

import { dialogAlertId } from './dialog-alert';

const LF = '\n'; // LINE_FEED
const SA = '‡';  // SUBALBUM indicator, NOTE! set in server (routes.js)

export class ViewMain extends Component {
  @service('common-storage') z;
  @service intl;

  <template>
      <SubAlbums />
      <AllImages />
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
      <div class="miniImgs albs">
        {{#if this.z.imdbRoot}}
          <span title-2="{{this.z.imdbRoot}}{{this.z.imdbDir}}">
            <b>”{{{this.z.handsomize this.z.imdbDirName}}}”</b>
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

class AllImages extends Component {
  @service('common-storage') z;
  @service intl;

  @tracked lastDragged;
  @tracked items = []; // NOTE: Used for allFiles duplication, below

  reorderItems = (itemModels, draggedModel) => {
    this.items = itemModels;
    this.lastDragged = draggedModel;
  }

  noTags = (txt) => {
    let tmp = txt.toString().replace(/<(?:.|\n)*?>/gm, ""); // Remove <tags>
    tmp = he.decode(tmp); // for attributes
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
      if (document.getElementById(dialogAlertId).open) {
        this.z.alertRemove();
      } else {
        this.z.alertMess(this.intl.t('albumMissing') + ':<br><br><p style="width:100%;text-align:center;margin:0">”' + this.z.removeUnderscore(name) + '”</p>');
      }
    } else {
      this.z.openAlbum(i);
      let size = this.z.albumAllImg(i);
      // Allow for the rendering of mini images and preload of view images
      await new Promise (z => setTimeout (z, size*60 + 100));
      this.z.gotoMinipic(fileName);
    }
  }

  dragStarted = (item) => {
    this.z.loli(`dragStarted: ${item.name}`, 'color:red');
    console.log(item);
  }

  dragStopped = (item) => {
    this.z.loli(`dragStopped: ${item.name}`, 'color:red');
    // Close the show image view
    document.querySelector('.img_show').style.display = 'none';
    // Open the thumbnail view
    document.querySelector('.miniImgs.imgs').style.display = 'flex';
    this.z.resetBorders();
    this.z.markBorders(item.name);
  }

  // Copies 'allFiles' to 'items' by real value duplication
  allFiles = () => {
    this.items = [];
    let m = this.z.allFiles.length;
    for (let i=0;i<m;i++) {
      // this.items.push({img: this.z.allFiles[i].mini, name: this.z.allFiles[i].name});
      this.items.push(this.z.allFiles[i]);
      this.lastDragged = '';
    }
  }

  txt = (no, name) => {
    let i = this.items.findIndex(item => {return item.name === name;});
    let r = '';
    if (i > -1) {
      if (no === 1) {
        r = this.items[i].txt1;
      } else {
        r = this.items[i].txt2;
      }
    }
    return r;
  }

  // Edit the image texts using DialogText
  editext = (event) => {
    event.stopPropagation();
    // todo, catches clicks so far
  }

  // itemVisualClass = 'sortable-item--active';


  //=================================================================================
  // Requires: ember install ember-draggable-modifiers
  //=================================================================================
  move = ({ source: { data: draggedItem }, target: { data: dropTarget, edge } }) => {
    this.items = removeItem(this.items, draggedItem);

    if (edge === 'top') {
      this.items = insertBefore(this.items, dropTarget, draggedItem);
    } else {
      this.items = insertAfter(this.items, dropTarget, draggedItem);
    }
  }
  //=================================================================================


  <template>

    <div style="margin:0 0 0 4rem;width:auto;height:auto" {{on 'mousedown' this.z.resetBorders}}>

      {{#if this.z.imdbRoot}}

        <p class="tmpHeader" style="display:none">

          {{!-- Here is an invisible button for album images load, used
          programmatically by z.openAlbum, display it for manual use! --}}
          <span style="display:none">
            Press to (re)load images for
            <button id="loadMiniImages" type="button" {{on 'click' this.allFiles}}>{{{this.z.imdbDirName}}}</button>
          </span>

          Last dragged item: {{this.lastDragged.name}}
        </p>

      {{else}}

        {{!-- Remind of choosing a root collection/album --}}
        <p style="text-align:center;margin-right:4rem">{{t 'albumcollselect'}}</p>

      {{/if }}

      {{!-- The album's div with thumnail images --}}
      <div class="miniImgs imgs" style="width:;display:flex;
        flex-wrap:wrap;padding:0;align-items:baseline;
        justify-content:left;position:relative"
      >
        {{!-- The thumnail images are displayed --}}
        {{#each this.items as |item|}}
          <div class="img_mini {{item.symlink}}" id="i{{item.name}}"
            {{sortableItem data=item onDrop=this.move}}
            {{on 'mousedown' this.z.resetBorders}}
          >
            {{!-- Arrange the go-to-origin-button for linked images --}}
            {{#if item.symlink}}
              <button class="goAlbum" title-2="{{t 'gotext'}} ”{{item.albname}}”" {{on 'click' (fn this.homeAlbum item.orig item.name)}}> {{t 'goto'}} </button>
            {{/if}}

            {{!-- Here comes the thumbnail --}}
            <img src="{{item.mini}}" class="left-click" title="{{this.z.imdbRoot}}{{item.linkto}}" draggable="false" ondragstart="return false" {{on 'click' (fn this.z.showImage item.name item.show)}}>

            {{!-- This is the image name, should be unique --}}
            <div class="img_name" style="display:{{this.z.displayNames}}">
              {{item.name}}
            </div>

            {{!-- The text from Xmp.dc.description metadata --}}
            <div class="img_txt1" draggable="false" ondragstart="return false" title-2={{this.noTags item.txt1}}>
              {{{this.noTagsShort item.txt1}}}
            </div>

            {{!-- The text from Xmp.dc.creator metadata --}}
            <div class="img_txt2" draggable="false" ondragstart="return false" title-2={{this.noTags item.txt2}}>
              {{{this.noTagsShort item.txt2}}}

            </div>
            {{!-- <span class='handle' {{sortableHandle}}>&varr;</span> --}}

          </div>
        {{/each}}
      </div>
    </div>

    {{!-- The album's slideshow image comes here --}}
    <div class="img_show" id="d{{this.z.picName}}" draggable="false" style="display:none;margin:1.5rem auto" {{on 'click' (fn this.z.showImage '')}}>

        <div id="link_show" draggable="false">
          <p style="margin:0;line-height:0;font-family:sans-serif">ᵛ</p>
          <img src="" draggable="false" ondragstart="return false">

          <div class="toggleNavInfo" style="opacity:0">
            <a class="navReturn" style="top:-2.5rem; left:0%; width:100%; border:0;" draggable="false" ondragstart="return false" {{on 'click' (fn this.z.showImage '')}}><p>{{t 'return'}} <span style="font:normal 1rem Arial!important">[Esc]</span></p></a>

            <a style="top: 0%; left: 0%; width: 49.5%; height: 99.5%;"
            draggable="false" ondragstart="return false"
            {{on 'click' (fn this.z.showNext false)}}>
              <p>{{t 'previous'}}<br><span style="font:normal 1rem Arial!important">[&lt;]</span></p><br>&nbsp;<br>&nbsp;
            </a>

            <a style="top: 0%; left: 50%; width: 50%; height: 99.5%; border-left:0;"
            draggable="false" ondragstart="return false"
            {{on 'click' (fn this.z.showNext true)}}>
              <p>{{t 'next'}}<br><span style="font:normal 1rem Arial!important">[&gt;]</span></p><br>&nbsp;<br>&nbsp;
            </a>
          </div>
        </div>

        <div id="link_texts" draggable="false" style="display:table-caption;
          caption-side:bottom;background:#3b3b3b;padding:0 0 0.4rem 0.3rem">
          {{!-- This is the image name, should be unique --}}
          <div class="img_name" style="display:{{this.z.displayNames}}" draggable="false" ondragstart="return false" title="" {{on 'click' this.editext}}>
            {{this.z.picName}}
          </div>

          {{!-- The text from Xmp.dc.description metadata --}}
          <div class="img_txt1" draggable="false" ondragstart="return false" title=""
            {{on 'click' this.editext}}
          >
            {{{this.txt 1 this.z.picName}}}
          </div>

          {{!-- The text from Xmp.dc.creator metadata --}}
          <div class="img_txt2" draggable="false" ondragstart="return false" title=""
            {{on 'click' this.editext}}
          >
            {{{this.txt 2 this.z.picName}}}
          </div>
        </div>

    </div>

  </template>
}
