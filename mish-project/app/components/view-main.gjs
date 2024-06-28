//== Mish main display view

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import { dialogAlertId } from './dialog-alert';

const LF = '\n'; // LINE_FEED


export class ViewMain extends Component {
  @service('common-storage') z;
  @service intl;

  <template>
    <div style="margin:0 0 0 3rem;width:auto;height:auto;border:0.5px solid lightgray">
      This is the area for picture show
    </div>
  </template>




}
