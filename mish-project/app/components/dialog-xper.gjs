//== Mish experimental dialog

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
// import SortableObjects from 'ember-drag-drop/components/sortable-objects';
// import DraggableObject from 'ember-drag-drop/components/draggable-object';
// import { A } from '@ember/array';
import sortableGroup from 'ember-sortable/modifiers/sortable-group';
import sortableItem from 'ember-sortable/modifiers/sortable-item';
// import sortableHandle from 'ember-sortable/modifiers/sortable-handle';

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

  handleVisualClass = {
    UP: 'sortable-handle-up',
    DOWN: 'sortable-handle-down',
    LEFT: 'sortable-handle-left',
    RIGHT: 'sortable-handle-right',
  };

  itemVisualClass = 'sortable-item--active';

  // @action
  // update(newOrder, draggedModel) {
  //   set(this, 'model.items', newOrder);
  //   set(this, 'model.dragged', draggedModel);
  // }

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

    <ol class="alb_mini" style="display:flex;flex-wrap:wrap;padding:0;
      align-items:baseline;justify-content:center;"
      {{sortableGroup
        direction='x'
        onChange=this.reorderItems
        itemVisualClass=this.itemVisualClass
        handleVisualClass=this.handleVisualClass
      }}
    >
      {{#each this.items as |item|}}
        <li class="img_mini"
          {{sortableItem
            model=item
            spacing=15
            distance=5
          }}
        >
          <img src="{{item.path}}" class="left-click" title="" draggable="false" ondragstart="return false">
          {{!-- <span class='handle' {{sortableHandle}}>&varr;</span> --}}
        </li>
      {{/each}}
    </ol>

    <p>The last dragged item: {{this.lastDragged.path}}</p>

    {{!-- <section class='horizontal-demo'>
      <h3>Horizontal</h3>
      <ol
        data-test-horizontal-demo-group
        {{sortable-group
          direction='x'
          onChange=this.update
          itemVisualClass=this.itemVisualClass
          handleVisualClass=this.handleVisualClass
          groupName='horizontal'
        }}
      >
        {{#each @model.items as |item|}}
          <li data-test-horizontal-demo-handle tabindex={{'0'}} {{sortable-item model=item groupName='horizontal'}}>
            <ItemPresenter @item={{item}} />
          </li>
        {{/each}}
      </ol>
    </section> --}}

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
