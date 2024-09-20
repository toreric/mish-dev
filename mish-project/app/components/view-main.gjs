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
import { MenuImage } from './menu-image'; // Needs parameter = image name!

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

      if (more > 0) plus ='&nbsp;(+' + more + ')';
    }
    return plus;
  }

  hasImages = () => {
    let txt = '';
    if (this.z.hasImages) {
      txt = ', ' + this.z.numOrigin + ' ' + this.intl.t('images');
      if (this.z.numLinked) txt += ' (' + this.intl.t('own') + ') + ' + this.z.numLinked + ' ' + this.intl.t('linked');
    } else {
      txt = ', ' + this.intl.t('no') + ' ' + this.intl.t('images');
    }
    return txt;
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
            {{t 'has'}} {{this.nsub}} {{this.sual}}</span><span title-2={{t 'plusExplain'}}>{{{this.nadd}}}</span><span>{{this.hasImages}}
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

  // @tracked lastDragged; // for ember-sortable
  @tracked items = []; // NOTE: Used for allFiles duplication, below

  detectEsc = (event) => {
    event.stopPropagation();
    if (event.keyCode === 27) { // Esc
      this.z.resetBorders();
    }
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

  // // For ember-sortable:

  // reorderItems = (itemModels, draggedModel) => {
  //   this.items = itemModels;
  //   this.lastDragged = draggedModel;
  // }

  // dragStarted = (item) => {
  //   this.z.loli(`dragStarted: ${item.name}`, 'color:red');
  //   console.log(item);
  // }

  // dragStopped = (item) => {
  //   this.z.loli(`dragStopped: ${item.name}`, 'color:red');
  //   // Close the show image view
  //   document.querySelector('.img_show').style.display = 'none';
  //   // Open the thumbnail view
  //   document.querySelector('.miniImgs.imgs').style.display = 'flex';
  //   this.z.resetBorders();
  //   this.z.markBorders(item.name);
  // }

  // Copies 'allFiles' to 'items' by real-value duplication
  allFiles = async () => {
    this.items = [];
    for (let file of this.z.allFiles) {
      this.items.push(file);
    }
  }

  // The image caption texts (from metadata)
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

  // The 'double classing', seemingly unnecessary and
  // irrational, comes from historic css reasons, sorry.
  toggleSelect = (flag, e) => {
    e.stopPropagation();

    if (flag === 0) { // 0 == thumbnail image
      let thisPic = e.target.closest('.img_mini');
      let clicked = thisPic.querySelector('div[alt="MARKER"]');
      if (thisPic.classList.contains('selected')) {
        thisPic.classList.remove('selected');
        clicked.className = 'markFalse';
      } else {
        thisPic.classList.add('selected');
        clicked.className = 'markTrue';
      }
      this.z.numMarked = document.querySelectorAll('.img_mini.selected').length;
      this.z.numHidden = document.querySelectorAll('.img_mini.hidden').length;
      this.z.ifToggleHide(); // Show/hide the toggleHide left button

    } else { // 1 == slideshow image
      let thisPic = document.querySelector('#i' + this.z.escapeDots(this.z.picName));
    console.log('thisPic', thisPic)
      let clicked = document.querySelector('#markShow');
    console.log('clicked', clicked)
      if (thisPic.classList.contains('selected')) {
        thisPic.classList.remove('selected');
        thisPic.querySelector('div[alt="MARKER"]').className = 'markFalse';
        clicked.className = 'markFalseShow';
    console.log('clicked.className', clicked.className)
      } else {
        thisPic.classList.add('selected');
        thisPic.querySelector('div[alt="MARKER"]').className = 'markTrue';
        clicked.className = 'markTrueShow';
    console.log('clicked.className', clicked.className)
      }
    }
  }

  // itemVisualClass = 'sortable-item--active';

  //============================================================
  // Requires: ember install ember-draggable-modifiers (before: ember-sortable)
  //============================================================
  move = ({ source: { data: draggedItem }, target: { data: dropTarget, edge } }) => {
    this.items = removeItem(this.items, draggedItem);

    if (edge === 'top') {
      this.items = insertBefore(this.items, dropTarget, draggedItem);
    } else {
      this.items = insertAfter(this.items, dropTarget, draggedItem);
    }
  }
  //============================================================

  <template>

    <div style="margin:0 2rem;width:auto;height:auto;text-align:center" {{on 'mousedown' this.z.resetBorders}} {{on 'keydown' this.detectEsc}}>

      {{#if this.z.imdbRoot}}

        {{!-- Here is an invisible button for album images load, used
        programmatically by z.openAlbum, display it for manual use! --}}
        <p class="tmpHeader" style="display:none">
            Press to (re)load images for
            <button id="loadMiniImages" type="button" {{on 'click' this.allFiles}}>{{{this.z.imdbDirName}}}</button>
        </p>

      {{else}}

        {{!-- Remind of choosing a root collection/album --}}
        <span style='border-radius:2.5px;outline:#87cfff double 4px'>
            &nbsp;{{t 'albumcollselect'}}&nbsp;
        </span>

      {{/if}}

      {{!-- The album's div with thumnail images --}}
      {{!-- ================================================ --}}
      <div class="miniImgs imgs" style="display:flex;flex-wrap:wrap">

      {{!-- The heading of the thumbnails' presentation --}}
      {{#if this.z.hasImages}}
        <div style="width:100%">
          <p><b>”{{{this.z.handsomize this.z.imdbDirName}}}”</b>

          {{#if this.z.numHidden}}
            — {{this.z.numShown}} {{t 'shown'}},
            {{this.z.numInvisible}} {{t  'hidden'}}
          {{else}}
            — {{this.z.numShown}} {{t 'shown'}}
          {{/if}}

          ({{this.z.numMarked}} {{t 'marked'}})</p>
        </div>
      {{/if}}

      {{!-- The div of the thumnail images --}}
      <div style="display:flex;flex-wrap:wrap;
        margin:auto;padding:0;align-items:baseline;
        justify-content:center;position:relative"
      >
        {{!-- The thumnail images are displayed --}}
        {{#each this.items as |item|}}
          <div class="img_mini {{item.symlink}}" id="i{{item.name}}"
            {{sortableItem data=item onDrop=this.move}}
            {{on 'mousedown' this.z.resetBorders}}
          >
            {{!-- The thumbnail menu --}}
            <MenuImage />

           <div style="margin:auto auto 0 auto;position:relative;width:max-content;">

            {{!-- The check mark in the thumnail's upper right corner --}}
            <div class="markFalse" alt="MARKER" draggable="false" ondragstart="return false" {{on 'click' (fn this.toggleSelect 0)}}>
              <img src="/images/markericon.svg" draggable="false" ondragstart="return false" class="mark" title={{t 'Mark'}}>
            </div>

            {{!-- Here comes the thumbnail --}}
            <img src="{{item.mini}}" class="left-click" title="{{this.z.imdbRoot}}{{item.linkto}}" draggable="false" ondragstart="return false" {{on 'click' (fn this.z.showImage item.name item.show)}}>

           </div>

            {{!-- This is the image name, should be unique --}}
            <div class="img_name" style="display:{{this.z.displayNames}};background:inherit">
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

    </div>

    {{!-- ================================================ --}}
    {{!-- The album's div with the slideshow image --}}
    <div class="img_show" id="d{{this.z.picName}}" draggable="false" style="display:none;margin:2rem auto 0 auto" {{on 'click' (fn this.z.showImage '')}}>

        {{!-- An extra slideshow wrapping div --}}
        <div id="link_show" draggable="false" ondragstart="return false" style="position:relative">

          {{!-- A midpoint mark (ᵛ) on the slideshow image border --}}
          <p style="margin:0;line-height:0;font-family:sans-serif">ᵛ</p>

          {{!-- The slideshow image comes here, src loaded at runtime --}}
          <img src="" draggable="false" ondragstart="return false">

          {{!-- The check mark in the slideshow image's upper right corner --}}
          <div id="markShow" class="" alt="MARKSHOW" draggable="false" ondragstart="return false" {{on 'click' (fn this.toggleSelect 1)}}  style="background:transparent;position:absolute;top:-15px;right:-15px;width:20px;height:20px">
            <img src="/images/markericon.svg" draggable="false" ondragstart="return false" class="mark" title="{{t 'Mark'}}" style="width:20px">
          </div>

          {{!-- The navigation information overlay of the slideshow image --}}
          <div class="toggleNavInfo" style="opacity:0">

            {{!-- Outside image: return-to-thumbnails click area --}}
            <a class="navReturn" style="top:-2.5rem; left:0%; width:100%; border:0;" draggable="false" ondragstart="return false" {{on 'click' (fn this.z.showImage '')}}><p>{{t 'return'}} <span style="font:normal 1rem Arial!important">[Esc]</span></p></a>

            {{!-- Left backwards click area --}}
            <a style="top: 0%; left: 0%; width: 49.5%; height: 99.5%;"
            draggable="false" ondragstart="return false"
            {{on 'click' (fn this.z.showNext false)}}>
              <p>{{t 'previous'}}<br><span style="font:normal 1rem Arial!important">[&lt;]</span></p><br>&nbsp;<br>&nbsp;
            </a>

            {{!-- Right forwards click area --}}
            <a style="top: 0%; left: 50%; width: 50%; height: 99.5%; border-left:0;"
            draggable="false" ondragstart="return false"
            {{on 'click' (fn this.z.showNext true)}}>
              <p>{{t 'next'}}<br><span style="font:normal 1rem Arial!important">[&gt;]</span></p><br>&nbsp;<br>&nbsp;
            </a>

           </div>

        </div>

        {{!-- The slideshow image's name and texts --}}
        <div id="link_texts" draggable="false" style="display:table-caption;
          caption-side:bottom;min-height:1rem;
          padding:0 0 0.4rem 0.3rem">

          {{!-- This is the image name, should be unique, hidden if 'displayNames'.. --}}
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
