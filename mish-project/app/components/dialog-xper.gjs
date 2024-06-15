//== Mish experimental dialog

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

export const dialogXperId = "dialogXper";

export class DialogXper extends Component {
  @service('common-storage') z;

  get tree() {
    // this.z.loli(JSON.stringify(this.z.imdbTree, null, 2));
    return this.args.tree ?? this.z.imdbTree;
  }

  // Detect closing Esc key
  detectEscClose = (e) => {
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogXperId).open) this.z.closeDialog(dialogXperId);
    }
  }

  // Close/open all nodes of albumTree except node zero
  toggleAll = () => {
    let all = document.querySelector(".albumTree").getElementsByTagName("a");
    // all[0].style.display = 'none';
    for (let i=1;i<all.length;i++) {
      all[i].click();
    }
  }

  <template><dialog id="dialogXper" {{on 'keydown' this.detectEscClose}}>
    <header data-dialog-draggable>
      <div style="width:99%">
        <p>Experimental dialog<span></span></p>
      </div><div>
        <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>×</button>
      </div>
    </header>
    <main>
      <p>Mish experimental dialog Mish experimental dialog Mish experimental dialog </p>
      <h2>Example</h2>
       <button type="button" {{on 'click' (fn this.toggleAll)}}>{{t 'button.close'}}</button>&nbsp;
      <div class="albumTree">
        <Tree @tree={{this.tree}} />
      </div>
    </main>
    <footer data-dialog-draggable>
      <button type="button" {{on 'click' (fn this.z.closeDialog dialogXperId)}}>{{t 'button.close'}}</button>&nbsp;
    </footer>
  </dialog></template>
}

class Tree extends Component {
  @service('common-storage') z;
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
    let button = tgt.nextElementSibling.nextElementSibling.children[0];
    button.click();
    if (tgt.innerText.includes('⊕')) {
      tgt.innerHTML = '⊖<img src="img/folderopen.gif" />';
    } else {
      tgt.innerHTML = '⊕<img src="img/folder.gif" />';
    }
  }

  <template>
    <div>
      <button style="display:none" {{on "click" this.toggle}}>
        {{if this.isOpen "Close" "Open"}}
      </button>
      {{#each @tree as |node|}}
        <div style="margin-left:1.5rem;line-height:1.5rem;display:{{this.display}}">
          {{#if node.children}}
            <a {{on "click" this.clickButton}}>
              ⊖<img src="img/folderopen.gif" />
            </a>
          {{else}}
            &nbsp;&nbsp;&nbsp; <img src="img/imgfolder.gif" />
          {{/if}}
          {{node.name}}<br>
          {{#if node.children}}
            <Tree @tree={{node.children}} />
          {{/if}}
        </div>
      {{/each}}
    </div>
  </template>
}
