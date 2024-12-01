//== Mish dialog for image searches (in texts: captions etc.)

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import RefreshThis from './refresh-this';

// Note: Dialog-functions in Header needs dialogFindId:
export const dialogFindId = 'dialogFind';

document.addEventListener('mousedown', async (e) => {
  e.stopPropagation();
});

document.addEventListener('keydown', async (e) => {
  if (e.keyCode === 27) {
    e.stopPropagation();
    if (document.getElementById('dialogFindHelp').open) {
      document.getElementById('dialogFindHelp').close();
      console.log('-"-: closed dialogFindHelp');
    } else if (document.getElementById(dialogFindId).open) {
      document.getElementById(dialogFindId).close();
      console.log('-"-: closed ' + dialogFindId);
    }
  }
});

//== Component DialogFind with <dialog> tags
export class DialogFind extends Component {
  @service('common-storage') z;
  @service intl;

  // Detect closing Esc key
  detectEscClose = (e) => {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById('dialogFindHelp').open) {
        this.z.closeDialog('dialogFindHelp');
      } else if (document.getElementById(dialogFindId).open) {
        this.z.closeDialog(dialogFindId);
      }
    }
  }

  get searchNotes() {
    return this.z.allow.notesView ? '' : 'none';
  }

  findit = () => {
    this.z.loli('findit', 'color:red');
    document.getElementById('go_back').click(); // close slide, perhaps unneccessary
  }

  /** Find texts in the database (file _imdb_images.sqlite) and populate
   * the #picFound album with the corresponding images (cf. prepSearchDialog)
   * @param {string}  sTxt whitespace separated search text words/items
   * @param {boolean} and  true=>AND (find all) | false=>OR (find any)
   * @param {boolean} sWhr (searchWhere) array = checkboxes for selected texts
   * @param {integer} exact when <>0, the LIKE searched items will NOT be '%' surrounded
   * NOTE: Non-zero ´exact´ also means "Only search for image names (file basenames)!"
   * NOTE: Negative ´exact´, -1 = called from the find dialog, -2 = do nothing,
   *       else (non-negative) = called from and return to the favorites dialog
   * Example: Find pictures by exact matching of image names (file basenames), e.g.
   *   doFindText ("img_0012 img_0123", false, [false, false, false, false, true], -1)
   */
  doFindText = () => {
    let sTxt = document.querySelector('textarea[name="searchtext"]').value;
    let and = document.querySelectorAll('.orAnd input[type="radio"]')[0].checked;
    let sWhr = [];
    for (let val of document.querySelectorAll('.srchIn input[type="checkbox"]')) {
      sWhr.push(val);
    }
    this.searchText(sTxt, and, sWhr, 0);
  }

  /** Search the image texts in the current imdbRoot (cf. prepSearchDialog)
   * @param {string}  sTxt space separated search items
   * @param {boolean} and true=>AND | false=>OR
   * @param {boolean} searchWhere array, checkboxes for selected texts
   * @param {integer} exact <>0 removes SQL ´%´s  (>0 means origin notesDia, <0 searchDia)
   * @returns {string} \n-separated file paths
   */
  searchText = (sTxt, and, searchWhere, exact) => {
    document.getElementById('go_back').click(); // close show, perhaps unneccessary
    // close all dialogs? perhaps unneccessary
    let AO, andor = '';
    if (and) {AO = ' AND '} else {AO = ' OR '};
    let txt = sTxt.trim();
    if (txt === "") {txt = undefined;}
    let cmt = '';
    // The first line may be a comment, to ignore:
    if (txt.slice (0, 1) === '#') {
      let l = txt.indexOf('\n');
      cmt = txt.slice(1, l);
      txt = txt.slice(l + 1);
    }

    let str = '';
    let arr = [];
    if (txt) {
      txt = txt.replace(/\s+/g, ' ').trim();

      this.z.loli(cmt, 'color:yellow');
      this.z.loli(txt, 'color:red');

      arr = txt.split (' ');
      for (let i = 0; i<arr.length; i++) {
        // Replace any `'` with `''`: will be enclosed within `'`s in SQL
        arr[i] = arr[i].replace (/'/g, "''");
        // Replace underscore to be taken literally, needs `ESCAPE '\'`
        arr[i] = arr[i].replace (/_/g, '\\_');
        // First replace % (NBSP):
        arr[i] = arr[i].replace (/%/g, ' '); // % in Mish means 'sticking space'
        // Then use % the SQL way if applicable and add `ESCAPE '\'` to each:
        if (exact !== 0) { // Exact match for file (base) names, e.g. favorites search
          arr[i] = "'" + arr[i] + "' ESCAPE '\\'";
        } else {
          arr[i] = "'%" + arr[i] + "%' ESCAPE '\\'";
        }
        if (i > 0) {andor = AO}
        str += andor + "txtstr LIKE " + arr[i].trim ();
      }
      // We need a double printout to see the %-substitution in console.log!
      this.z.loli(str, 'color:orange  ')
      this.z.loli(str.replace(/%/g, '*'), 'color:yellow')
    }
  }


  <template>

    <div style="display:flex" {{on 'keydown' this.detectEscClose}}>

      <dialog id='dialogFind' style="width:min(calc(100vw - 1rem),650px)">
        <header data-dialog-draggable >
          <p>&nbsp;</p>
          <p><b>{{t 'dialog.find.header'}}</b> <span></span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogFindId)}}>×</button>
        </header>
        <main>

          <textarea name="searchtext" placeholder="{{t 'write.searchTerms'}}" autofocus="true" style="width:calc(100% - 8px)" rows="4"></textarea>

          <div class="diaMess">
            <div class="edWarn" style="font-weight:normal;text-align:right"></div>
            <div class="srchIn"> {{t 'write.find0'}}&nbsp;
              <span class="glue">
                <input id="t1" name="search1" value="description" checked="" type="checkbox">
                <label for="t1">&nbsp;{{t 'write.find1'}}</label>&nbsp;
              </span>
              <span class="glue">
                <input id="t2" name="search2" value="creator" checked="" type="checkbox">
                <label for="t2">&nbsp;{{t 'write.find2'}}</label>&nbsp;
              </span>
              <span class="glue" style="display:{{this.searchNotes}}">
                <input id="t3" name="search3" value="source" type="checkbox">
                <label for="t3">&nbsp;{{t 'write.find3'}}</label>&nbsp;
              </span>
              <span class="glue">
                <input id="t4" name="search4" value="album" checked="" type="checkbox">
                <label for="t4">&nbsp;{{t 'write.find4'}}</label>&nbsp;
              </span>
              <span class="glue">
                <input id="t5" name="search5" value="name" checked="" type="checkbox">
                <label for="t5">&nbsp;{{t 'write.find5'}}</label>
              </span>
            </div>
            <div class="orAnd">{{t 'write.find6'}} &nbsp; &nbsp;
                <a class="hoverDark" style="font-family:sans-serif;font-variant:all-small-caps" tabindex="-1" {{on 'click' (fn this.z.toggleDialog 'dialogFindHelp')}}>{{t 'searchHelp'}}</a>
              <br>{{t 'write.find7'}}<br>
              <span class="glue">
                <input id="r1" name="searchmode" value="AND" checked="" type="radio">
                <label for="r1">{{{t 'write.find8'}}}</label>
              </span>&nbsp;
              <span class="glue">
                <input id="r2" name="searchmode" value="OR" type="radio">
                <label for="r2">{{{t 'write.find9'}}}</label>
              </span>
            </div>
          </div>

        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.doFindText)}}>{{t 'button.findIn'}} <b>{{this.z.imdbRoot}}</b></button>&nbsp;
          <button type="button" {{on 'click' (fn this.z.closeDialog dialogFindId)}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

      <dialog id='dialogFindHelp' style="width:min(calc(100vw - 2rem),450px)">
        <header data-dialog-draggable>
          <p>&nbsp;</p>
          <p>{{t 'write.findHelpHeader'}} <span></span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog 'dialogFindHelp')}}>×</button>
        </header>
        <main style="padding:0 0.5rem 0 1rem;height:20rem" width="99%">

          <p style="padding-top:0.3em"><strong>{{{t 'write.findHelp0'}}}</strong> <br> </p>
          <p>
            {{{t 'write.findHelp1'}}}
          </p>
          <p>
            {{{t 'write.findHelp2'}}}
          </p>
          <p>
            {{{t 'write.findHelp3'}}}
          </p>
          <p>
            {{{t 'write.findHelp4'}}}
          </p>
          <p>
            {{{t 'write.findHelp5'}}}
          </p>
          <p>
           {{{t 'write.findHelp6'}}}
          </p>

        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.z.closeDialog 'dialogFindHelp')}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

    </div>

  </template>
}
