//== Mish header component

//import changeLocale from '../controllers/intl-shift';
//import selections from '../controllers/intl-shift';
//import * as XXX from '../controllers/intl-shift';
// eslint-disable-next-line no-console
//console.log(XXX);
// eslint-disable-next-line no-console
//console.log(this.changeLocale);
//import '../controllers/intl-shift';

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { action } from '@ember/object';
import { inject as service } from '@ember/service';

import t from 'ember-intl/helpers/t';

import { Clock } from './clock';
import { dialogTextId, openDialog, openModalDialog, toggleDialog }
  from './dialog-text';
import { Excite } from './excite';

export default class Header extends Component {
  @service intl;
  @tracked selections = this.intl.get('locales');
  @tracked locale = this.intl.get('locale');
  @action
  changeLocale(locale) {
    this.intl.set('locale', locale);
  }

  <template>
    <h1>{{t "header"}}</h1>

    <p>

      {{this.intl.locale}} {{this.locale}} {{this.selections}} {{this.selections.length}} <br><br>

      {{#each this.selections as |model|}}
        {{model}} {{this.locale.active}}?&nbsp;
        <button class={{if model.active "active"}} {{on "click" (fn this.changeLocale model)}}>
          «{{model}}»
        </button>
      {{/each}}
    </p>

    <Excite /> {{t "intlcode"}} {{t "price_banner" product="A" price=76.5}}
    <p>{{t "time.text"}} <span><Clock @locale={{t "intlcode"}} /></span></p>
    <p>
      <button type="button" {{on 'click' (fn toggleDialog dialogTextId 0)}}>{{t 'dialog.text.toggle'}}</button><button type="button" {{on 'click' (fn openDialog dialogTextId 1)}}>{{t 'dialog.text.open.origpos'}}</button>
      &nbsp;
      <button type="button" {{on 'click' (fn openModalDialog dialogTextId 0)}}>{{t 'dialog.text.open.modal'}}</button>
    </p>
  </template>;
}
