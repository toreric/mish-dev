//== Mish experimental dialog

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import SortableObjects from 'ember-drag-drop/components/sortable-objects';
import DraggableObject from 'ember-drag-drop/components/draggable-object';
import { A } from '@ember/array';
import sortableGroup from 'ember-sortable/modifiers/sortable-group';
import sortableItem from 'ember-sortable/modifiers/sortable-item';

export const dialogXperId = "dialogXper";


class SortExample extends Component {
  @service('common-storage') z;
  @service intl;

  @tracked lastDragged;
  @tracked items = [];

  imdbLabels = () => {
    // Populate the image-informatiom array 'items'
    this.items = [];
    let m = this.z.imdbLabels.length;
    for (let i=1;i<m;i++) {
      let p = this.z.imdbLabels[i];
      if (p.length > 0) {
        // this.z.loli(i + ' ' + p);
        this.items.push({id: i, path: p});
      }
    }
    this.z.loli(JSON.stringify(this.items, null, '  ')); // Checked!
    // await new Promise (z => setTimeout (z, 666));
    let tmp = this.z.imdbLabels.join('<br>');
    return tmp.slice(0, 0); // hide
  } // Doesn't need the fn helper within {{{}}} in the template, why?

 reorderItems = (itemModels, draggedModel) => {
    this.items = itemModels;
    this.lastDragged = draggedModel;
  }

  <template>

    <p>
      {{#if this.z.imdbRoot}}
      Drag to another position and drop to reorder
      {{else}}
      Please select an album collection!
      {{/if }}
    </p>
    <span style="display:">
        {{{this.imdbLabels}}} {{!-- MAKES items! --}}
    </span>

    <div class="alb_mini" {{sortableGroup onChange=this.reorderItems}}>
      {{#each this.items as |item|}}
        <div class="img_mini" {{sortableItem model=item}}>
          {{!-- {{item}} --}}
          <img src="{{item.path}}" class="left-click" title="" draggable="false" ondragstart="return false">
          {{!-- <span class='handle' {{sortable-handle}}>&varr;</span> --}}
        </div>
      {{/each}}
    </div>

    <p>The last dragged item: {{this.lastDragged.path}}</p>

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
