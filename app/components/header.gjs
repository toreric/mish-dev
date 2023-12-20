//== Mish header component

import Component from '@glimmer/component';
//import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
//import { action } from '@ember/object';
import { inject as service } from '@ember/service';

import t from 'ember-intl/helpers/t';

import { Clock } from './clock';
import { dialogTextId, openDialog, openModalDialog, toggleDialog }
  from './dialog-text';
import { Excite } from './excite';

export default class Header extends Component {
  @service intl;
  selections = this.intl.get('locales');
  changeLocale = (newLoc) => {
    this.intl.set('locale', newLoc);
  }
  isActive = (model) => {
    // eslint-disable-next-line no-console
    //console.log(this.intl.locale, model);

    return this.intl.locale[0] === model;
  }
  <template>
    <h1>{{t "header"}}</h1>

    {{! Choose-language buttons }}
    <p>
      {{#each this.selections as |model|}}
        <button class={{if (this.isActive model) "active" ""}} {{on "click" (fn this.changeLocale model)}}>
          {{model}}
        </button>
      {{/each}}
    </p>

    {{! Testing ember-intl }}
    <Excite />
    {{t "intlcode"}} {{t "price_banner" product="A" price=76.5}}
    <p>{{t "time.text"}} <span><Clock @locale={{t "intlcode"}} /></span></p>

    {{! Dialog-testing buttons }}
    <p>
      <button type="button" {{on 'click' (fn toggleDialog dialogTextId 0)}}>{{t 'dialog.text.toggle'}}</button><button type="button" {{on 'click' (fn openDialog dialogTextId 1)}}>{{t 'dialog.text.open.origpos'}}</button>
      &nbsp;
      <button type="button" {{on 'click' (fn openModalDialog dialogTextId 0)}}>{{t 'dialog.text.open.modal'}}</button>
    </p>
  </template>;
}
