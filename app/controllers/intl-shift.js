import { action } from '@ember/object';
import { inject as service } from '@ember/service';

export default class ApplicationController {
  @service intl;
  selections = this.intl.locales;

  @action
  changeLocale(locale) {
    this.intl.set('locale', locale);
  }
}
