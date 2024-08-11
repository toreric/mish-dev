//== Mish right vertical buttons

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

// Right buttons, most without href attribute
export class ButtonsRight extends Component {
  @service('common-storage') z;
  @service intl;

  someFunction = (param) => {this.z.loli(param);}


  <template>

    {{!-- RIGHT BUTTONS without href attribute --}}
    <div class="nav_links" draggable="false" ondragstart="return false">
      {{!-- NEXT-ARROW-BUTTONS --}}
      <a class="nav_" draggable="false" ondragstart="return false" {{on 'click' (fn this.someFunction 'showNext true')}} title="{{t 'gonext'}}">&gt;</a> &nbsp;<br>
      <a class="nav_" draggable="false" ondragstart="return false" {{on 'click' (fn this.someFunction 'showNext false')}} title="{{t 'goprev'}}">&lt;</a> &nbsp;<br>
      {{!-- CLOSE AND GO BACK TO MINIPICS --}}
      <a class="nav_" id="go_back" title="{{t 'gomini'}}"{{on 'click' (fn this.someFunction 'hideShow')}} src="/images/grid.svg"> </a> &nbsp;<br>

      {{!-- AUTO-SLIDE-SHOW SELECT
      <a class="nav_ toggleAuto" draggable="false" ondragstart="return false" {{action 'toggleAuto'}} style="font-size:1.2em;font-family:monospace" title="Automatiskt
    bildbyte [A]">AUTO</a><br>
      <!-- AUTO-SLIDE-SHOW SPEED SELECT -->
      <span class="nav_" id="showSpeed" draggable="false" ondragstart="return false">
        <input class="showTime" type="number" min="1" max="99" value="2" title="Välj tid > 0 s">s&nbsp;&nbsp;<br>
        <!-- CHOOSE AUTO-SHOW s/texline OR s/slide -->
        <a class="speedBase nav_" {{action 'speedBase'}} title="Välj per bild
    eller bildtextrad">&nbsp;per<br>&nbsp;text-&nbsp;<br>&nbsp;rad</a>
      </span><br>
      <!-- HELP -->
      <a class="nav_ qnav_" draggable="false" {{action 'toggleNav'}}>?</a> &nbsp;<br>
      <!-- FULL SIZE -->
      <a class="nav_" id="full_size" draggable="false" {{action 'fullSize'}} title="Full storlek
    i nytt fönster" style="font-size:200%;line-height:80%;padding:0.3em 0.33em 0.25em 0.3em">&#9974;</a> &nbsp; <br>
    <a class="nav_ pnav_" id="do_print" title="Skriv ut" {{action 'doPrint'}} src="/images/printer.svg"></a> &nbsp; --}}
    </div>

  </template>


}
