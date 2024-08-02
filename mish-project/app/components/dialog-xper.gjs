//== Mish experimental dialog

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { eq, notEq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import sortableGroup from 'ember-sortable/modifiers/sortable-group';
import sortableItem from 'ember-sortable/modifiers/sortable-item';

export const dialogXperId = "dialogXper";

class SortExample extends Component {
  @service('common-storage') z;
  @service intl;

  @tracked lastDragged;
  @tracked items = [];

  // imdbLabels = () => {
  //   if (!this.z.imdbRoot) return;
  //   // Populate the image-informatiom array 'items'
  //   this.items = [];
  //   let m = this.z.imdbLabels.length;
  //   let ix = 0;
  //   for (let i=1;i<m;i++) {
  //     let p = this.z.imdbLabels[i];
  //     if (p.length > 0) {
  //       let na = p.replace(/(\/.*)*\/([^/]*)\..*$/g, '$2');
  //       let pic = p;
  //       // let pic = '<img src="' + p + '" class="left-click" title="" draggable="false" ondragstart="return false">'
  //       // this.z.loli(i + ' ' + p);
  //       this.items.push({index: ix, name: na, path: p, img: pic});
  //       ix++;
  //     }
  //   }
  //   // this.z.loli(JSON.stringify(this.items, null, '  ')); // Checked!
  //   // await new Promise (z => setTimeout (z, 666));
  //   // let tmp = this.z.imdbLabels.join('<br>');
  //   // return tmp;
  //   //      return tmp.slice(0, 0); // hide
  // } // Doesn't need the fn helper within {{}} in the template, why?

  allFiles = () => {
    this.items = [];
    let m = this.z.allFiles.length;
    for (let i=0;i<m;i++) {
      // this.items.push({img: this.z.allFiles[i].mini, name: this.z.allFiles[i].name});
      this.items.push(this.z.allFiles[i]);
    }
  }

  reorderItems = (itemModels, draggedModel) => {
    this.items = itemModels;
    this.lastDragged = draggedModel;
  }

  handleVisualClass = {
    UP: 'sortable-handle-up',
    DOWN: 'sortable-handle-down',
    LEFT: 'sortable-handle-left',
    RIGHT: 'sortable-handle-right',
  };

  itemVisualClass = 'sortable-item--active';

  <template>

    <p>
      {{#if this.z.imdbRoot}}
        Press to (re)load images for
        <!--button type="button" {{on 'click' this.imdbLabels}}>{{this.z.imdbRoot}}</button-->
        <button type="button" {{on 'click' this.allFiles}}>{{this.z.imdbDirName}}</button>
      {{else}}
        Please select an album collection!
      {{/if }}
    </p>

    <div class="alb_mini" style="display:flex;flex-wrap:wrap;padding:0;
      align-items:normal;justify-content:center;position:relative"
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
          <br>
          <div class="img_name">
            {{item.name}}
          </div>
          {{!-- <span class='handle' {{sortableHandle}}>&varr;</span> --}}
        </div>
      {{/each}}
    </div>

    <p>The last dragged item: {{this.lastDragged.name}}</p>

  </template>
}

export class DialogXper extends Component {
  @service('common-storage') z;
  @service intl;

  // Detect closing Esc key
  detectEscClose = (e) => {
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogXperId).open) this.z.closeDialog(dialogXperId);
    }
  }

  <template>
    <dialog id="dialogXper" {{on 'keydown' this.detectEscClose}}>
      <header data-dialog-draggable>
        <div style="width:99%">
          <p>Experimental dialog<span></span></p>
        </div>
        <div>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>×</button>
        </div>
      </header>
      <main>
        <SortExample />
      </main>
      <footer data-dialog-draggable>
        <button type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>{{t 'button.close'}}</button>&nbsp;
      </footer>
    </dialog>
  </template>
}
