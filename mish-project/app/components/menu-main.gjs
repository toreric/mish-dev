//== Mish main menu, select image root directoriy, jstree to be displayed

// Is so far only roughly outlined, waiting for server service ...

import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import { loli } from './welcome';

const someFuntion = (param) => loli(param);

export const menuMainId = "menuMain"
// NOTE: As regards the erronous "{{on "cnange" (fn someFuntion 'selectRoot')}}"
// value='target.value' part below: SEE @Glime ai-bot explanations!

export function toggleMainMenu() {
  var menuMain = document.getElementById("menuMain");
  if (menuMain.style.display === "none") {
    menuMain.style.display = "";
    loli('opened main menu');
  } else {
    menuMain.style.display = "none";
    loli('closed main menu');
  }
}

//== Detect closing Esc key

document.addEventListener ('keydown', detectEsc, false);

function detectEsc(e) {
  if (e.keyCode === 27) { // Esc key
    if (document.getElementById("menuMain").style.display !== "none") toggleMainMenu();
  }
}

export class MenuMain extends Component {
  @tracked imdbRoot;
  imdbRoots = ['Välj albumsamling', 'root1', 'root2', 'root3'];

  @action
  selectRoot(event) {
    this.imdbRoot = event.target.value;
    loli('selected IMDB_ROOT: ' + this.imdbRoot);
  }

  <template>
    <div id="menuMain" class="mainMenu BACKG" onclick="return false" draggable="false" ondragstart="return false" style="display:none">

      <p onclick="return false" draggable="false" ondragstart="return false" title="Sökning">
        <a class="search" {{on "click" (fn someFuntion 'findText')}}>Finn bilder <span style="font:normal 1em monospace!important">[F]</span></a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" title="Favoritskötsel">
        <a id ="favorites" {{on "click" (fn someFuntion 'seeFavorites')}}>Favoritbilder</a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false">
        <a class="" style="color: white;cursor: default">

          <select id="rootSel" title="Albumsamling (eller albumrot)" {{on "change" this.selectRoot}}>
            {{#each this.imdbRoots as |rootChoice|}}
              <option value={{rootChoice}} selected={{eq this.imdbRoot rootChoice}}>{{rootChoice}}</option>
            {{/each}}
          </select>

          <a class="rootQuest">&nbsp;?&nbsp;</a>
        </a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" style="z-index:0" title="Ta bort, gör nytt, bildsortera, dublettsökning, med mera">
        <a {{on "click" (fn someFuntion 'albumEdit')}} > {{{this.albumText}}} {{{this.albumName}}} </a>
      </p><br>

      <p onclick="return false" draggable="false" ondragstart="return false" title="Visa alla album = hela albumträdet" style="z-index:0">
        <a id ="jstreeHdr" {{on "click" (fn someFuntion 'toggleJstreeAlbumSelect')}} > {{{this.jstreeHdr}}} </a>
      </p>

      <!--div class="jstreeAlbumSelect" style="display:none">
        {{ember-jstree
          data=albumData
          eventDidSelectNode='{{someFuntion("selAlb")}}'
        }}
      </div-->
    </div>
  </template>
}
