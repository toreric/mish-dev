//== Mish choose language

import Route from '@ember/routing/route';
import { service } from '@ember/service';

export default class ApplicationRoute extends Route {
  @service intl;

  async beforeModel() {

    /*let defaultLocale = this.intl.t('intlcode');
    // This approach with defaultLocale dosn't work since there is a default
    // preferrence for en-us (first in the intl.locales array) to be chosen.
    // Can perhaps be resolvet via cockies or some similar measure. Until then,
    // this.intl.setLocale(['...']) may be changed for testing, like down below.
    this.intl.setLocale([defaultLocale]);*/

    this.intl.setLocale([this.intl.t('intlcode')]);
    // this.intl.setLocale(['sv-se']);
    // this.intl.setLocale(['de-de']);
    // this.intl.setLocale(['en-us']);
  }
}
