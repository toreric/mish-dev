import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

import { Clock } from './clock';
import { dialogTextId, openDialog, openModalDialog, toggleDialog }
  from './dialog-text';
import { Excite } from './excite';


//== Mish header Component

export const Header = <template>
  <h1>Welcome to Mish, Polaris revision</h1>
  <Excite />
  <p>The time is <span>{{Clock}}</span></p>
  <p><button type="button" {{on 'click' (fn openDialog dialogTextId 0)}}>Open text dialog</button><button type="button" {{on 'click' (fn openDialog dialogTextId 1)}}>... in original position</button>
  &nbsp;
  <button type="button" {{on 'click' (fn toggleDialog dialogTextId 0)}}>Toggle text dialog</button>
  &nbsp;
  <button type="button" {{on 'click' (fn openModalDialog dialogTextId 1)}}>Open modal text dialog</button>
  </p>
</template>;
