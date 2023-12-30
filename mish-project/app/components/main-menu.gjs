//== Mish main menu, select image root directoriy, jstree

import { eq } from 'ember-truth-helpers';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

const someFuntion = (param) => console.log(param);

export const MainMenu = <template>
  <div class="mainMenu BACKG" onclick="return false" draggable="false" ondragstart="return false" style="display:none">

    <p onclick="return false" draggable="false" ondragstart="return false" title="Sökning">
      <a class="search" {{on "click" (fn someFuntion 'findText')}}>Finn bilder <span style="font:normal 1em monospace!important">[F]</span></a>
    </p><br>

    <p onclick="return false" draggable="false" ondragstart="return false" title="Favoritskötsel">
      <a id ="favorites" {{on "click" (fn someFuntion 'seeFavorites')}}>Favoritbilder</a>
    </p><br>

    <p onclick="return false" draggable="false" ondragstart="return false">
      <a class="" style="color: white;cursor: default">
        <select id="rootSel" title="Albumsamling (eller albumrot)" onchange={{someFuntion 'selectRoot' value='target.value'}}>
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
