//== Mish choose language

import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service intl;

  async beforeModel() {
    // this.intl.setLocale(['sv-se']);
    // this.intl.setLocale(['de-de']);
    this.intl.setLocale(['en-us']);
  }
}
