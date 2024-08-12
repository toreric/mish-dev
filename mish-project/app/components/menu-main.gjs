//== Mish main menu, select image root directoriy, display album tree

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import { dialogAlertId } from './dialog-alert';

export const menuMainId = 'menuMain';
const LF = '\n'; // LINE_FEED
const OP = '⊕'; // OPENS
const CL = '⊖'; // CLOSES
const SA = '‡';  // SUBALBUM indicator, NOTE! set in server (routes.js)

// Detect closing Esc key for menuMain or open dialogs
const detectEsc = (event) => {
  if (event.keyCode === 27) { // Esc key
    closeMainMenu();
  }
}
document.addEventListener ('keydown', detectEsc, false);

// Close the main menu
const closeMainMenu = () => {
  var tmp0 = document.getElementById('menuButton');
  var tmp1 = document.getElementById('menuMain');
  if (tmp1.style.display !== 'none') {
    tmp1.style.display = 'none';
    tmp0.innerHTML = '<span class="menu">☰</span>';
    console.log('-"-: closed main menu');
  }
}


export class MenuMain extends Component {
  @service('common-storage') z;
  @service intl;
  @tracked hasHidden = false;

  // Choose collection = album root directory and its album (sub)directories
  // and convert them into an object tree with an amended property set.
  // Finally indicate if this album tree has any hidden-without-allowance album.
  selectRoot = async (event) => { // Album root = collection
    this.z.imdbRoot = event.target.value;
    this.z.imdbDir = this.z.imdbRoot; // The root is assumed initially selected
    this.z.loli('IMDB_ROOT set to ' + this.z.imdbRoot, 'color:green');
    const allow = this.z.allow; // PERMISSIONS

    // Retreive album tree of this collection, arg.=true if hidden allowed
    let tmp = await this.z.getAlbumDirs(allow.textEdit);
    let arr = tmp.split(LF);

    // The two first lines (shifted off) have other information
    await this.z.execute('echo "' + arr.shift() + '" > nodestamp.txt');
    this.z.imdbPath = arr.shift();
    this.z.loli('imdPath: ' + this.z.imdbPath, 'color:orange');

    let n = arr.length/3;
    this.z.imdbDirs = arr.splice(0, n);
    this.z.imdbCoco = arr.splice(0, n);
    this.z.imdbLabels = arr.splice(0, n);
    this.z.loli('imdbCoco ' + n + LF + this.z.imdbCoco.join(LF), 'color:yellow');
    this.z.loli('imdbDirs ' + n + LF + this.z.imdbDirs.join(LF), 'color:yellow');
    // this.z.loli('imdbLabels ' + n + LF + this.z.imdbLabels.join(LF));
    // this.z.loli(this.z.imdbDirs, 'color:green');

    // let data = structuredClone(this.z.imdbDirs);
    let data = [...this.z.imdbDirs];
    let root = this.z.imdbRoot;
    for (let i=0;i<data.length;i++) {
      data[i] = root + data[i]; // amend the root catalog
    }

    // this.z.loli('imdbRoot/imdbDirs ' + n + LF + data.join(LF));
    // this.z.loli(data);
    // this.z.loli(this.z.imdbDirs, 'color:red');

    //begin https://stackoverflow.com/questions/72006110/convert-file-path-into-object
    // Convert the album directory list 'data' to a JS tree. Modifications are:
    // m1. For directories only, file code is commented out.
    // m2. Properties added: index, coco, path, and label (coco = content count)
    let i = 0;
    const tree = { root: {} }
    for (const path of data) {
      const parts = path.split('/');
      // const file = parts.pop(); // m1.
      let branch = tree, partPath = '';
      for (const part of parts) {
        partPath += `${part}/`;
        if (partPath === `${part}/`) {
          tree.root[partPath] = (tree[partPath] ??= { name: part, index: i++, coco: this.z.imdbCoco[i-1], path: partPath, label: this.z.imdbLabels[i-1], children: [] }); // m2
        } else if (tree[partPath] === undefined) {
            tree[partPath] = { name: part, index: i++, coco: this.z.imdbCoco[i-1], path: partPath, label: this.z.imdbLabels[i-1], children: [] }; // m2.
            branch.children.push(tree[partPath]);
        }
        branch = tree[partPath];
      }
      // branch.children.push({ name: file, id: path }); // m1.
    }
    const result = Object.values(tree.root);
    //end https://stackoverflow.com/questions/72006110/convert-file-path-into-object

    console.log(result);
    this.z.imdbTree = result;
    this.z.loli(this.z.imdbTree);
    // this.z.loli(this.z.imdbDirs);
    // this.z.loli('imdbTree ' + n + LF + JSON.stringify(result, null, 2)); //human readable
    await new Promise (z => setTimeout (z, 199)); // Wait for album tree to settle
    this.closeAll(); // fold all nodes except 0

    let anyHidden = () => { // flags any hidden-without-allowance album
      let coco = this.z.imdbCoco;
      for (let i=0;i<coco.length;i++) {
        if (coco[i].includes('*')) return true;
      }
      return false;
    }
    this.hasHidden = anyHidden(); // if there are any hidden-without-allowance albums
    this.z.openAlbum(0); // Select the root album
    this.z.closeMainMenu('after opening root album'); // Close the main menu

    // this.z.loli(this.z.imdbDirs);
  }

  // The @tree argument for Tree component
  get tree() {
    return this.args.tree ?? this.z.imdbTree;
  }

  // Search album texts to find images
  findText = () => {
    if (this.checkRoot()) return;
    this.z.loli('findText');
    // ...todo
  }

  // Manage favorite image lists
  seeFavorites = () => {
    if (this.checkRoot()) return;
    this.z.loli('seeFavorites');
    // ...todo
  }

  // Edit or create albums etc.
  albumEdit = () => {
    if (this.checkRoot()) return;
    this.z.loli('albumEdit');
    // ...todo
  }

  // Close/open albumTree
  toggleAlbumTree = () => {
    if (this.checkRoot()) return;
    let treeDiv = document.querySelector('div.albumTree');
    let what;
    if (treeDiv.style.display) {
      what = 'open';
      treeDiv.style.display = '';
    }else {
      what = 'close';
      treeDiv.style.display = 'none';
    }
    this.z.loli('toggleAlbumTree ' + what);
  }

  // Check if the alert dialog is open (then close it), or if no
  // album root/collection (imdbRoot) is chosen (then open it)
  checkRoot = () => {
    if (document.getElementById('dialogAlert').hasAttribute('open')) {
      this.z.alertRemove();
      return true;
    }
    if (!this.z.imdbRoot) {
      // alertMess opens the alert dialog
      this.z.alertMess(this.intl.t('needaroot'));
      document.querySelector('.mainMenu select').focus();
      return true;
    }
  }

  // Open enough nodes to make the selected album visible
  showSelected = async () => {
    let index = this.z.imdbDirIndex;
    let selected = document.querySelector('div.album.a' + index);
    selected.style.display = '';
    // Check that all parents are visible too
    while (selected.parentElement.classList.contains('album')) {
      selected = selected.parentElement;
      if (selected.nodeName !== 'DIV') break;
      selected.style.display = '';
    }
    selected = document.querySelector('span.album.a' + index);
    selected.classList.add('blink');
    await new Promise (z => setTimeout (z, 666)); // blink pause
    selected.classList.remove('blink');
  }

  // Open all nodes of albumTree
  openAll = () => {
    let all = document.querySelector('div.albumTree').querySelectorAll('a.album');
    for (let i=0;i<all.length;i++) {
      if (all[i].innerHTML.includes(OP)) all[i].click();
    }
  }

  // Close all nodes of albumTree except the root
  closeAll = () => {
    let all = document.querySelector('div.albumTree').querySelectorAll('a.album');
    for (let i=1;i<all.length;i++) {
      if (all[i].innerHTML.includes(CL)) all[i].click();
    }
  }

  // Count the number of images in this album
  totalImgNumber = () => {
    let a = this.z.totalOrigImg();
    return a;
  }

  <template>

    <div id="menuMain" class="mainMenu" onclick="return false" draggable="false" ondragstart="return false" style="display:none">

      <p onclick="return false" draggable="false" ondragstart="return false" title-2="Sökning">
        <a class="search" {{on "click" (fn this.findText)}}>Finn bilder <span style="font:normal 1em monospace!important">[F]</span></a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" title-2="Favoritskötsel">
        <a id ="favorites" {{on "click" (fn this.seeFavorites)}}>Favoritbilder</a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false">
        <a class="" style="color: white;cursor: default">

          <select id="rootSel" title-2={{t 'albumcollinfo'}} {{on 'change' this.selectRoot}} {{on 'mousedown' (fn this.z.alertRemove)}}>
            <option value="" selected disabled hidden>{{t 'selalbumcoll'}}</option>
            {{#each this.z.imdbRoots as |rootChoice|}}
              <option value={{rootChoice}} selected={{eq this.z.imdbRoot rootChoice}}>{{rootChoice}}</option>
            {{/each}}
          </select>

          <a class="rootQuest" title-2={{t 'albumSelectInfo'}}>&nbsp;?&nbsp;</a>
        </a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" style="z-index:0" title-2="{{t 'albumcareinfo'}} {{t 'for'}} {{this.z.imdbRoot}}{{this.z.imdbDir}}">
    {{!-- return this.intl.t('albumcare') + ' ”' + this.z.imdbDirName + '”'; --}}
        <a {{on "click" (fn this.albumEdit)}}>{{t 'albumcare'}} <span title="">”{{{this.z.imdbDirName}}}”</span></a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" style="z-index:0" title-2={{t 'albumcollshow'}}>
        <a {{on "click" (fn this.toggleAlbumTree)}}><pre style="margin:0">{{t 'albumcoll'}} ”{{this.z.imdbRoot}}”     ⌵  </pre></a>
      </p>


      <div class="albumTree" style="display:none">
        <span style="display:flex;justify-content:space-between">
          <span style="margin:0.2rem;padding:0.1rem 0.2rem;float:right" title=""><em>{{t 'totalImgNumber'}}</em>:&nbsp;{{this.totalImgNumber}}</span>

          <span>
            <a style="margin:0.4rem 0.2rem 0 0;padding:0.1rem 0.2rem;float:right;border:0.5px solid #d3d3d3;border-radius:4px" title-2={{t 'closeallalb'}} {{on "click" (fn this.closeAll)}}>{{t 'all'}} {{CL}}</a>

            <a style="margin:0.4rem 0.2rem 0 0;padding:0.1rem 0.2rem;float:right;border:0.5px solid #d3d3d3;border-radius:4px" title-2={{t 'openallalb'}} {{on "click" (fn this.openAll)}}>{{t 'all'}} {{OP}}</a>

            <a style="margin:0.4rem 0.2rem 0 0;padding:0.1rem 0.2rem;float:right;border:0.5px solid #d3d3d3;border-radius:4px" title-2={{t 'showselectedtext'}} {{on "click" (fn this.showSelected)}}>{{t 'showselected'}}</a>
          </span>
        </span>
        <Tree @tree={{this.tree}} />
        {{#if this.z.imdbRoot}}
          <p style="font-size:77%;vertical-align:top;line-height:1.1rem;margin:0 0.2rem 0 3rem">
            {{t 'tmpalbum1'}} § {{t 'tmpalbum2'}}<br>
            (⋅) {{t 'nimages'}}, (⋅+⋅) {{t 'nlinked'}}<br>
            {{SA}} {{t 'nsubalbums'}}
            {{#if this.hasHidden}}
              <br>* {{t 'anyhidden'}}
            {{/if}}
          </p>
        {{/if}}
      </div>

    </div>

  </template>
}



class Tree extends Component {
  @service('common-storage') z;
  @service intl;

  @tracked isOpen = true;
  @tracked display = '';

  toggle = () => {
    this.isOpen = !this.isOpen;
    if (this.isOpen) {
      this.display = '';
    } else {
      this.display = 'none';
    }
  }

  clickButton = (event) => {
    let tgt = event.target;
    if (tgt.tagName === 'IMG') { // if A IMG and not A is clicked
      tgt = tgt.parentElement;
    }
    // This button is unvisible:
    let button = tgt.parentElement.querySelector('button');
    button.click();
    if (tgt.innerText.includes(OP)) {
      tgt.innerHTML = CL + '<img src="img/folderopen.gif" />';
    } else {
      tgt.innerHTML = OP + '<img src="img/folder.gif" />';
    }
  }

  <template>

    <button style="display:none" {{on 'click' this.toggle}}>
      {{if this.isOpen 'Close' 'Open'}}
    </button>
    {{#each @tree as |node|}}
      <div class="album a{{node.index}}" style="display:{{this.display}}">
        {{#if node.children}}
          <a class="album a{{node.index}}" {{on "click" this.clickButton}}>
            {{CL}}<img src="img/folderopen.gif" />
          </a>
        {{else}}
          &nbsp;&nbsp;&nbsp; <img src="img/folderopen.gif" />
        {{/if}}
        <span style="font-size:77%;vertical-align:top;line-height:1.1rem">
          {{node.index}}&nbsp;&nbsp;
        </span>
        <span class="album a{{node.index}}" style="cursor:pointer" {{on "click" (fn this.z.openAlbum node.index)}}{{on "click" (fn this.z.closeMainMenu 'after selection in the album tree')}}>{{node.name}}</span>
        <span style="font-size:77%;vertical-align:top">
          &nbsp;&nbsp;{{node.coco}}
        </span>
        <br>
        {{#if node.children}}
          <Tree @tree={{node.children}} />
        {{/if}}
      </div>
    {{/each}}

  </template>
}

