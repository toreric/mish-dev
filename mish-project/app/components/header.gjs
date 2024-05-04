//== Mish Header component

import Component from '@glimmer/component';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { inject as service } from '@ember/service';
import t from 'ember-intl/helpers/t';

import { Clock } from './clock';
import { dialogTextId } from './dialog-text';
import { Excite } from './excite';

export default class Header extends Component {
  @service('common-storage') z;
  @service intl;
  // selections = this.intl.get('locales');
  // changeLocale = (newLoc) => {
  //   new Promise (z => setTimeout (z, 200));
  //   this.intl.set('locale', newLoc);
  // }
  // changeLanguage = (event) => {
  //   new Promise (z => setTimeout (z, 200));
  //   this.intl.set('locale', event.target.value);
  // }
  // isActive = (locale) => {
  //   new Promise (z => setTimeout (z, 200));
  //   return this.intl.locale[0] === locale;
  // }
  // langText = (locale) => {
  //   new Promise (z => setTimeout (z, 200));
  //   return this.intl.lookup("select.languagetext", locale);
  // }

  <template><div style="margin:0 0 0 4rem;padding:0">

    {{!-- <p class="buttons">
      {{! Selection, just an example }}
      <span>&nbsp; &nbsp; &nbsp; Testing: </span>
      <select>
        <option value="" selected disabled hidden>Select</option>
        <option value="0" style="color:red">Red</option>
        <option value="1" style="color:green">Green</option>
        <option value="2" style="color:blue">Blue</option>
      </select>

    </p> --}}

    {{! Testing ember-intl and some other things }}
    <Excite />
    {{t "intlcode"}} {{t "price_banner" product='A (1)' price=76.5}}
    <span style="font-size:85%">&nbsp; &nbsp; &nbsp; Default laguage is set in <strong style="font-size:85%">routes/application.js</strong></span>

    {{! Dialog-testing buttons }}
    <p>
      <button type="button" {{on 'click' (fn this.z.toggleDialog dialogTextId 0)}}>{{t 'dialog.text.toggle'}}</button>
      <button type="button" {{on 'click' (fn this.z.openDialog dialogTextId 1)}}>{{t 'dialog.text.open.origpos'}}</button>
      &nbsp;
      <button type="button" {{on 'click' (fn this.z.openModalDialog dialogTextId 0)}}>{{t 'dialog.text.open.modal'}}</button>
    </p>

  </div></template>
}
