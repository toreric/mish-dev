//== Mish main menu, select image root directoriy, jstree to be displayed

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

export const menuMainId = 'menuMain';

// Detect closing Esc key for menuMain or open dialogs
const detectEsc = (event) => {
  if (event.keyCode === 27) { // Esc key
    var tmp0 = document.getElementById("menuButton");
    var tmp1 = document.getElementById("menuMain");
    if (tmp1.style.display !== 'none') {
      tmp1.style.display = 'none';
      tmp0.innerHTML = '<span class="menu">☰</span>';
      console.log('-"-: closed main menu');
      // this.z.toggleMainMenu() useless, since {{on 'keydown'... is useless (why?)
      // NOTE: Autologged if toggleMainMenu is used
    } else {
      // An open <dialog> has an 'open' attribue
      var tmp = document.querySelectorAll('dialog');
      for (let i=0; i<tmp.length; i++) {
        // Check if any open dialog
        if (tmp[i].hasAttribute("open")) {
          tmp[i].close();
          console.log('-"-: closed ' + tmp[i].id);
        }
      }
    }
  }
}

document.addEventListener ('keydown', detectEsc, false);


export class MenuMain extends Component {
  @service('common-storage') z;
  @service intl;

  selectRoot = (event) => {
    this.z.imdbRoot = event.target.value;
    this.z.loli('IMDB_ROOT set to ' + this.z.imdbRoot);
    // HÄR ska servern skicka subalbumlisan
  }

  someFunction = (param) => {this.z.loli(param);}

  jstreeHdr = () => {
    return this.intl.t('albumcoll') + ' ”' + this.z.imdbRoot + '”';
  }

  <template>

    <div id="menuMain" class="mainMenu BACKG" onclick="return false" draggable="false" ondragstart="return false" style="display:none">

      <p onclick="return false" draggable="false" ondragstart="return false" title="Sökning">
        <a class="search" {{on "click" (fn this.someFunction 'findText')}}>Finn bilder <span style="font:normal 1em monospace!important">[F]</span></a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" title="Favoritskötsel">
        <a id ="favorites" {{on "click" (fn this.someFunction 'seeFavorites')}}>Favoritbilder</a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false">
        <a class="" style="color: white;cursor: default">

          <select id="rootSel" title={{t 'albumcol'}} {{on "change" this.selectRoot}}>
            <option value="" selected disabled hidden>{{t 'selalbumcol'}}</option>
            {{#each this.z.imdbRoots as |rootChoice|}}
              <option value={{rootChoice}} selected={{eq this.z.imdbRoot rootChoice}}>{{rootChoice}}</option>
            {{/each}}
          </select>

          <a class="rootQuest">&nbsp;?&nbsp;</a>
        </a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" style="z-index:0" title="Ta bort, gör nytt, bildsortera, dublettsökning, med mera">
        <a {{on "click" (fn this.someFunction 'albumEdit')}} > {{{this.albumText}}} {{{this.albumName}}} </a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" title="Visa alla album = hela albumträdet" style="z-index:0">
        <a id ="jstreeHdr" {{on "click" (fn this.someFunction 'toggleJstreeAlbumSelect')}} > {{this.jstreeHdr}} </a>
      </p>

      {{!-- <div class="jstreeAlbumSelect" style="display:none">
        {{ember-jstree
          data=albumData
          eventDidSelectNode='{{this.someFunction("selAlb")}}'
        }}
      </div> --}}
    </div>

  </template>
}
