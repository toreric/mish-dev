//== Mish header component

import Component from '@glimmer/component';
//import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
//import { action } from '@ember/object';
import { inject as service } from '@ember/service';

import t from 'ember-intl/helpers/t';

import { Clock } from './clock';
import { toggleDialog, openDialog, openModalDialog }
  from './dialog-functions';
import { dialogTextId } from './dialog-text';
import { Excite } from './excite';

export default class Header extends Component {
  @service intl;
  selections = this.intl.get('locales');
  changeLocale = (newLoc) => {
    new Promise (z => setTimeout (z, 200));
    this.intl.set('locale', newLoc);
  }
  changeLanguage = (event) => {
    new Promise (z => setTimeout (z, 200));
    this.intl.set('locale', event.target.value);
  }
  isActive = (locale) => {
    new Promise (z => setTimeout (z, 200));
    return this.intl.locale[0] === locale;
    }
  langText = (locale) => {
    new Promise (z => setTimeout (z, 200));
    return this.intl.lookup("select.languagetext", locale);
    }

  <template><div style="margin:0 0 0 4rem;padding:0">

    <h1>{{t "header"}}</h1>

    {{! Choose language }}
    <p class="buttons">
      <span style="font-size:85%">{{t "select.language"}}</span><br>

      {{#each this.selections as |tongue|}}
        <span class={{if (this.isActive tongue) "active"}} {{on "click" (fn this.changeLocale tongue)}} style="padding:0;margin:0"><img src="/images/{{tongue}}.svg" alt={{tongue}}></span>
      {{/each}}

      <select id="selectLanguage" {{on "change" this.changeLanguage}}>
      {{#each this.selections as |tongue|}}
        <option {{on "click" (fn this.changeLocale tongue)}} value={{tongue}} selected={{if (this.isActive tongue) true}}>{{(this.langText tongue)}}</option>
      {{/each}}
      </select>
    </p>

    {{! Testing ember-intl }}
    <Excite />
    {{t "intlcode"}} {{t "price_banner" product='A (1)' price=76.5}}
    <p>{{t "time.text"}} <span><Clock @locale={{t "intlcode"}} /></span></p>

    {{! Dialog-testing buttons }}
    <p>
      <button type="button" {{on 'click' (fn toggleDialog dialogTextId 0)}}>{{t 'dialog.text.toggle'}}</button><button type="button" {{on 'click' (fn openDialog dialogTextId 1)}}>{{t 'dialog.text.open.origpos'}}</button>
      &nbsp;
      <button type="button" {{on 'click' (fn openModalDialog dialogTextId 0)}}>{{t 'dialog.text.open.modal'}}</button>
    </p>

  </div></template>
}
