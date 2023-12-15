//import action from '../controllers/application';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

import t from 'ember-intl/helpers/t';

import changeLocale from '../controllers/intl-shift';
import selections from '../controllers/intl-shift';
import * as XXX from '../controllers/intl-shift';
import { Clock } from './clock';
import { dialogTextId, openDialog, openModalDialog, toggleDialog }
  from './dialog-text';
import { Excite } from './excite';

//== Mish header Component

// eslint-disable-next-line no-console
console.log(XXX);
// eslint-disable-next-line no-console
//console.log(this.changeLocale);

export const Header = <template>
  <h1>{{t "header"}}</h1>

  <div>
    {{#each selections as |model|}}
    <button class={{if model.active "active"}} {{on "click" (fn changeLocale model.locale)}}>
        {{model.locale}}
      </button>
    {{/each}}
  </div>

  <Excite /> {{t "intlcode"}} {{t "price_banner" product="A" price=76.5}}
  <p>{{t "time.text"}} <span><Clock @locale={{t "intlcode"}} /></span></p>
  <p>
    <button type="button" {{on 'click' (fn toggleDialog dialogTextId 0)}}>{{t 'dialog.text.toggle'}}</button><button type="button" {{on 'click' (fn openDialog dialogTextId 1)}}>{{t 'dialog.text.open.origpos'}}</button>
    &nbsp;
    <button type="button" {{on 'click' (fn openModalDialog dialogTextId 0)}}>{{t 'dialog.text.open.modal'}}</button>
  </p>
</template>;
