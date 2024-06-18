//== Mish main menu, select image root directoriy, jstree to be displayed

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';


export const menuMainId = 'menuMain';
const LF = '\n'; // LINE_FEED
const OP = '⊕'; // OPENS
const CL = '⊖'; // CLOSES

// Detect closing Esc key for menuMain or open dialogs
const detectEsc = (event) => {
  if (event.keyCode === 27) { // Esc key
    var tmp0 = document.getElementById("menuButton");
    var tmp1 = document.getElementById("menuMain");
    if (tmp1.style.display !== 'none') {
      tmp1.style.display = 'none';
      tmp0.innerHTML = '<span class="menu">☰</span>';
      console.log('-"-: closed main menu');
      // this.z.toggleMainMenu() useless, since {{on 'keydown'... is useless (why?)
      // NOTE: Autologged if toggleMainMenu is used
    } else {
      // An open <dialog> has an 'open' attribue
      var tmp = document.querySelectorAll('dialog');
      for (let i=0; i<tmp.length; i++) {
        // Check if any open dialog
        if (tmp[i].hasAttribute("open")) {
          tmp[i].close();
          console.log('-"-: closed ' + tmp[i].id);
        }
      }
    }
  }
}
document.addEventListener ('keydown', detectEsc, false);



export class MenuMain extends Component {
  @service('common-storage') z;
  @service intl;
  @tracked hasHidden = false;

  // Choose collection = album root directory and its album (sub)directories
  // and convert them into an object tree with an amended property set.
  // Finally indicate if this album tree has any hidden album.
  selectRoot = async (event) => { // Album root = collection
    this.z.imdbRoot = event.target.value;
    this.z.imdbDir = this.z.imdbRoot; // The root is assumed initially selected
    this.z.loli('IMDB_ROOT set to ' + this.z.imdbRoot);
    // Retreive the album tree of this collection
    let tmp = await this.z.getAlbumDirs();
    let arr = tmp.split(LF);
    let aboutNode = arr.shift();
    this.z.imdbPath = arr.shift();
    let n = arr.length/3;
    this.z.imdbDirs = arr.splice(0, n);
    this.z.imdbCoco = arr.splice(0, n);
    this.z.imdbLabels = arr.splice(0, n);
    this.z.loli('imdbDirs ' + n + LF + this.z.imdbDirs.join(LF));
    this.z.loli('imdbCoco ' + n + LF + this.z.imdbCoco.join(LF));
    this.z.loli('imdbLabels ' + n + LF + this.z.imdbLabels.join(LF));
    const data = this.z.imdbDirs;
    for (let i=0;i<data.length;i++) {
      data[i] = this.z.imdbRoot + data[i]; // change the empty root reference
    }
    this.z.loli(data);

    // Convert the album directory list 'data' to a JS tree:
    //begin https://stackoverflow.com/questions/72006110/convert-file-path-into-object
    let i = 0;
    const tree = { root: {} }
    for (const path of data) {
      const parts = path.split('/');
      // const file = parts.pop();
      let branch = tree, partPath = '';
      for (const part of parts) {
        partPath += `${part}/`;
        if (partPath === `${part}/`) {
          tree.root[partPath] = (tree[partPath] ??= { name: part, index: i++, coco: this.z.imdbCoco[i-1], path: partPath, label: this.z.imdbLabels[i-1], children: [] });
        } else if (tree[partPath] === undefined) {
            tree[partPath] = { name: part, index: i++, coco: this.z.imdbCoco[i-1], path: partPath, label: this.z.imdbLabels[i-1], children: [] };
            branch.children.push(tree[partPath]);
        }
        branch = tree[partPath];
      }
      // branch.children.push({ name: file, id: path });
    }
    const result = Object.values(tree.root);
    //end https://stackoverflow ... For directories only, file code is commented out
    //ALSO the index etc.properties are amended; coco = content count

    this.z.imdbTree = result;
    document.querySelector('div.albumTree').style.display = 'none'; // May be open
    await new Promise (z => setTimeout (z, 199)); // Soon allow next
    this.toggleAll();
    console.log(result);
    console.log(JSON.stringify(result, null, 2)) //human readable

    let anyHidden = () => { // flags any hidden album
      let coco = this.z.imdbCoco;
      for (let i=0;i<coco.length;i++) {
        if (coco[i].includes('*')) return true;
      }
      return false;
    }
    this.hasHidden = anyHidden(); // if there are any hidden albums

  }

  someFunction = (param) => {this.z.loli(param);} // temporary dummy

  // Some texts for div.albumTree follow:
  albumCare = () => {
    return this.intl.t('albumcare') + ' ”' + this.z.imdbDir + '”';
  }
  albumColl = () => {
    return this.intl.t('albumcoll') + ' ”' + this.z.imdbRoot + '”';
  }

  // The @tree argument for Tree component
  get tree() {
    return this.args.tree ?? this.z.imdbTree;
  }

  // Close/open albumTree
  toggleAlbumTree = () => {
    // if (document.querySelector('div.albumTree a:first-of-type').innerText.includes(CL)) {
    //   this.toggleAll();
    // }
    let tree = document.querySelector('div.albumTree');
    if (tree.style.display) {
      tree.style.display = '';
    }else {
      tree.style.display = 'none';
    }
  }

  // Close/open all nodes of albumTree except the root
  toggleAll = () => {
    let all = document.querySelector("div.albumTree").getElementsByTagName("a");
    for (let i=1;i<all.length;i++) {
      all[i].click();
    }
  }

  <template>

    <div id="menuMain" class="mainMenu BACKG" onclick="return false" draggable="false" ondragstart="return false" style="display:none">

      <p onclick="return false" draggable="false" ondragstart="return false" title="Sökning">
        <a class="search" {{on "click" (fn this.someFunction 'findText')}}>Finn bilder <span style="font:normal 1em monospace!important">[F]</span></a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" title="Favoritskötsel">
        <a id ="favorites" {{on "click" (fn this.someFunction 'seeFavorites')}}>Favoritbilder</a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false">
        <a class="" style="color: white;cursor: default">

          <select id="rootSel" title={{t 'albumcollinfo'}} {{on "change" this.selectRoot}}>
            <option value="" selected disabled hidden>{{t 'selalbumcoll'}}</option>
            {{#each this.z.imdbRoots as |rootChoice|}}
              <option value={{rootChoice}} selected={{eq this.z.imdbRoot rootChoice}}>{{rootChoice}}</option>
            {{/each}}
          </select>

          <a class="rootQuest">&nbsp;?&nbsp;</a>
        </a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" style="z-index:0" title={{t 'albumcareinfo'}}>
        <a {{on "click" (fn this.someFunction 'albumEdit')}}> {{{this.albumCare}}} </a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" title={{t 'albumcollshow'}} style="z-index:0">
        <a class="" {{on "click" (fn this.toggleAlbumTree)}}> {{this.albumColl}} </a>
      </p>

      <div class="albumTree" style="display:none">
        <Tree @tree={{this.tree}} />
        {{#if this.z.imdbRoot}}
          <p style="font-size:77%;vertical-align:top;line-height:1.1rem;margin:0 0.2rem 0 3rem">
            {{t 'tmpalbum1'}} § {{t 'tmpalbum2'}}<br>
            (.) {{t 'nimages'}}, (.+.) {{t 'nlinked'}}<br>
            ‡ {{t 'nsubalbums'}}
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
    if (tgt.tagName === 'IMG') {
      tgt = tgt.parentElement;
    }
    let button = tgt.nextElementSibling.nextElementSibling.nextElementSibling .nextElementSibling;
    button.click();
    if (tgt.innerText.includes(OP)) {
      tgt.innerHTML = CL + '<img src="img/folderopen.gif" />';
    } else {
      tgt.innerHTML = OP + '<img src="img/folder.gif" />';
    }
  }

  <template>

    <button style="display:none" {{on "click" this.toggle}}>
      {{if this.isOpen "Close" "Open"}}
    </button>
    {{#each @tree as |node|}}
      <div style="display:{{this.display}}">
        {{#if node.children}}
          <a {{on "click" this.clickButton}}>
            {{CL}}<img src="img/folderopen.gif" />
          </a>
        {{else}}
          &nbsp;&nbsp;&nbsp; <img src="img/imgfolder.gif" />
        {{/if}}
        <span style="font-size:77%;vertical-align:top;line-height:1.1rem">
          {{node.index}}&nbsp;&nbsp;
        </span>
        {{node.name}}
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

