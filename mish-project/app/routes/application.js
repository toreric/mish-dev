//== Mish choose language

import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service('common-storage') z;
  @service intl;

  async beforeModel() {
    // this.intl.setLocale(['sv-se']);
    // this.intl.setLocale(['de-de']);
    // await this.intl.loadAndSetLocale();  // not a function
    await this.intl.setLocale(['en-us']);
    this.z.initialize();
  }
}
