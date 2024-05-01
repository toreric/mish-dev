//== Mish language selections

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

export class Language extends Component {
  @service intl;
  selections = this.intl.get('locales').sort();

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

  <template>
    <div style="display:inline-block">
      <select id="selectLanguage" {{on "change" this.changeLanguage}} title={{t "select.language"}}>
        {{#each this.selections as |tongue|}}
          <option {{on "click" (fn this.changeLocale tongue)}} value={{tongue}} selected={{if (this.isActive tongue) true}}>{{(this.langText tongue)}}</option>
        {{/each}}
      </select>
      {{!-- Flags --}}
      {{#each this.selections as |tongue|}}
        <span class="langflags {{if (this.isActive tongue) 'active'}}" {{on "click" (fn this.changeLocale tongue)}} style="padding:0;margin:0" title={{t "select.language"}}><img src="/images/{{tongue}}.svg" alt={{tongue}}></span>
      {{/each}}
    </div>
  </template>
}
