//== Mish experimental dialog

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import SortableObjects from 'ember-drag-drop/components/sortable-objects';
import DraggableObject from 'ember-drag-drop/components/draggable-object';
import { A } from '@ember/array';

export const dialogXperId = "dialogXper";


class SortExample extends Component {
  sortFinishText = null;
  sortableObjectList = A([
    {id: 1, title:'Number 1'},
    {id: 2, title:'Number 2'},
    {id: 3, title:'Number 3'},
    {id: 4, title:'Number 4'},
    {id: 5, title:'Number 5'},
    {id: 6, title:'Number 6'},
    {id: 7, title:'Number 7'},
    {id: 8, title:'Number 8'},
    {id: 9, title:'Number 9'},
    {id: 10, title:'Number 10'},
    {id: 11, title:'Number 11'},
    {id: 12, title:'Number 12'}
  ])

  @action
  sortEndAction() {
    console.log('Sort Ended', this.sortableObjectList);
  }

  <template>
    <div class="u-halfBlock u-pullLeft">
      <p>
        Drag any box to another position and drop to re-sort the list
      </p>
      <div class="u-pullLeft">
        <SortableObjects
          @sortableObjectList={{this.sortableObjectList}}
          @sortEndAction={{fn this.sortEndAction}}
          @sortingScope="a"
          @useSwap={{false}}
        >
          {{#each this.sortableObjectList as |item|}}
            <DraggableObject
              @content={{item}}
              @overrideClass="img_mini"
              @isSortable={{true}}
              @sortingScope="a"
            >
              {{item.title}}
            </DraggableObject>
          {{/each}}
        </SortableObjects>
      </div>
      <div class="u-pullLeft u-marginLeft">
        <h3>
          Order of objects is:
        </h3>
        <ul>
          {{#each this.sortableObjectList as |item|}}
            <li>
              id:
              {{item.id}}
              , title:
              {{item.title}}
            </li>
          {{/each}}
        </ul>
      </div>
    </div>
  </template>
}

export class DialogXper extends Component {
  @service('common-storage') z;
  @service intl;

// @tracked items = ['America', 'Asia', 'Europe'];

  // get tree() {
  //   // this.z.loli(JSON.stringify(this.z.imdbTree, null, 2));
  //   return this.args.tree ?? this.z.imdbTree;
  // }

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
        </div><div>
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
