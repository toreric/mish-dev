//== Mish dialog for image searches (in texts: captions etc.)

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

import RefreshThis from './refresh-this';

// Note: Dialog-functions in Header needs dialogFindId:
export const dialogFindId = 'dialogFind';

document.addEventListener('mousedown', (e) => {
  e.stopPropagation();
});

document.addEventListener('keydown', (e) => {
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

function acceptedFileName (name) {
  // This function must equal the acceptedFileName function in routes.js
  var acceptedName = 0 === name.replace (/[-_.a-zA-Z0-9]+/g, "").length
  // Allowed file types are also set at drop-zone in the template menu-buttons.hbs
  var ftype = name.match (/\.(jpe?g|tif{1,2}|png|gif)$/i)
  var imtype = name.slice (0, 6) // System file prefix
  // Here more files may be filtered out depending on o/s needs etc.:
  return acceptedName && ftype && imtype !== '_mini_' && imtype !== '_show_' && imtype !== '_imdb_' && name.slice (0,1) !== "."
}

//== Component DialogFind with <dialog> tags
export class DialogFind extends Component {
  @service('common-storage') z;
  @service intl;

  @tracked countAlbs = [];

  @tracked nchk = 0; // tot n found
  @tracked seast = ''; // search str
  @tracked keepIndex = [];
  @tracked inames = [];
  @tracked counts = [];

  iname = (i) => {
    return this.inames[i];
  }
  count = (i) => {
    return ("     " + this.counts[i]).slice(-5).replace(/ /g, '&nbsp');
  }
  album = (i) => {
    return this.z.imdbDirs[i];
  }

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

  /**
  doFindText: Finds texts in the database (file _imdb_images.sqlite)
  and populates the 'picFound' album with the corresponding images

  @param {string}  sTxt whitespace separated search text words/items
  @param {boolean} and  true=>AND (find all) | false=>OR (find any)
  @param {boolean} sWhr (searchWhere) array = checkboxes for selected texts
  @param {integer} exact when <>0, the LIKE searched items will NOT be '%' surrounded
  NOTE: Non-zero ´exact´ also means "Only search for image names (file basenames)!"
  NOTE: Negative ´exact´, -1 = called from the find? dialog, -2 = do nothing,
        else (non-negative) = called from and return to the favorites? dialog
  Example: Find pictures by exact matching of image names (file basenames), e.g.
    doFindText ("img_0012 img_0123", false, [false, false, false, false, true], -1)
   */
  doFindText = async () => {
    let sTxt = document.querySelector('textarea[name="searchtext"]').value + '\n';
    let and = document.querySelectorAll('.orAnd input[type="radio"]')[0].checked;
    let sWhr = [];
    let n = 0;
    for (let srch of document.querySelectorAll('.srchIn input[type="checkbox"]')) {
      sWhr.push(srch.checked);
      if (srch.checked) n++;
    }
    // Do not 'search nowhere', choose at least the image caption!
    if (n === 0)  {
      document.querySelectorAll('.srchIn input[type="checkbox"]')[0].checked = true;
      sWhr[0] = true;
    }
    let nameOrder = [];

    // Do find images using 'searchText':
    let data = await this.searchText(sTxt, and, sWhr, 0);

    let cmd = [];
    let paths = []; // The found paths
    let albs = [];  // The list of found albums
    let lpath = this.z.imdbPath + '/' + this.z.picFound; // The path to picFound
    // Maximum number of pictures from the search results to show:
    let nLimit = 100;
    let filesFound = 0;
    if (data) {
      // Don't sort, order may be important if this is a search for duplicates. Then
      // this is the final re-search by image names in sequence. The result is presented
      // in the same given order where similar images are grouped together.
      let paths = data.trim ().split ('\n');//.sort ();
      // Remove possibly empty values:
      paths = paths.filter (a => {if (a.trim ()) return true; else return false});
      // NOTE: Eventually, 'paths' is the basis of the innerHTML content in <result>
        // this.z.loli('paths:\n' + paths.join('\n'), 'color:pink');
        // console.log(paths);
      // Prepare to display the result in the album 'Found_images...' etc. (picFound)
      let chalbs = this.z.imdbDirs;
      // -- Prepare counters and imgnames (inames) for all albums
      this.counts = '0'.repeat(chalbs.length + 1).split('').map(Number); // +1 for skipped
      this.inames = ' '.repeat(chalbs.length).split('');

      for (let i=0; i<paths.length; i++) {
        let chalb = paths[i].replace(/^[^/]+(.*)\/[^/]+$/, '$1'); // in imdbDirs format
        // -- Allow only files/pictures in the albums of #imdbDirs (chalbs):
        let okay0 = true;
        let idx = chalbs.indexOf(chalb);
        if (idx > -1) {okay0 = true;} else {
          okay0 = false;
          idx = chalbs.length; // Count the dismissed/skipped
        }
        this.counts[idx]++; // -- A hit in this album
        let fname = paths[i].replace(/^.*\/([^/]+$)/, '$1');
        if (idx < chalbs.length) {
          this.inames[idx] = (this.inames[idx] + ' ' + fname.replace(/\.[^./].*$/, '')).trim();
        }
        let linkfrom = paths[i];
        linkfrom = '../' + linkfrom.replace(/^[^/]*\//, '');
        let okay1 = acceptedFileName(fname);

        // n0=dirpath, n1=picname, n2=extension from 'paths'
        // -- 'paths' may accidentally contain illegal image file names, normally
        // silently ignored. If so, such names will be noticed by red #d00 color
        // (just an extra service). They may have been collected into the database
        // at regeneration and may occationally appear in this list.
        let n0 = paths[i].replace(/^(.*\/)[^/]+$/, '$1');
        if (!okay0) n0 = '<span style="color:#d00">' + n0 + '</span>';
        let n1 = fname.replace (/\.[^./]*$/, '');
        if (!okay1) n1 = '<span style="color:#d00">' + n1 + '</span>';
        let n2 = fname.replace(/(.+)(\.[^.]*$)/, '$2');
        if (okay0 && okay1) { // ▻🢒
            // console.log('i paths[i]',i,paths[i],okay0,okay1);
          //The 🢒 construct makes long broken entries easier to read:
          paths [i] = '🢒&nbsp;' + n0 + n1 + n2;
        } else {
            // console.log('i paths[i]',i,paths[i],okay0,okay1);
          paths[i] = '<span style="color:#d00">🢒&nbsp;</span>' + n0 + n1 + n2;
        }

        // -- In order to make possible show duplicates: Make the link names unique
        // by adding four random characters (r4) to the picname (n1)
        let r4 = Math.random().toString(36).substr(2,4);
        fname = n1 + '.' + r4 + n2;
        if (filesFound < nLimit) {
          if (okay0 && okay1) { // Only approved files are counted as 'filesFound'
            filesFound++;
            nameOrder.push(n1 + '.' + r4 + ',0,0');
            let linkto = lpath + '/' + fname;
            // Arrange links of found pictures into the picFound album:
            cmd.push ('ln -sf ' + linkfrom + ' ' + linkto);
          } else if (n1.length > 0) {
            paths [i] += '<span style="color:#000"> —&nbsp;visningsrättighet&nbsp;saknas</span>';
          }
          albs.push (paths [i]); // ..while all are shown
        } else filesFound++;
      }
      // 'nameOrder' will be the 'sortOrder' for 'picFound':
      nameOrder = nameOrder.join('\n').trim ();
        // this.z.loli('nameOrder:\n' + nameOrder, 'color:pink');
        // this.z.loli('cmd:\n' + cmd.join('\n'), 'color:pink');
        // this.z.loli('albs:\n' + albs.join('\n'), 'color:pink');
        // console.log('counts:\n', this.counts);
        // console.log('inames:\n', this.inames);

      // Prepare the alternative album list 'countAlbs' for the 'filesFound > nLimit' case:
      this.countAlbs = [];
      let keepOld = false;

      this.nchk = 0;
      this.keepIndex = [];
      for (let i=0; i<chalbs.length-1; i++) {
        if (this.counts [i]) {
          this.nchk += this.counts[i];
          this.keepIndex.push(i);

          if(keepOld) {
            let tmp = "<a class=\"hoverDark\" onclick=\"console.log('" + inames[i] + "',false,[false,false,false,false,true], 1);return false\" style=\"text-decoration:none\">" + (("     " + counts[i]).slice(-6) + "  " + this.intl.t('in') + "  ").replace (/ /g, "&nbsp;");
            console.log("EXACT?",exact);
            if (exact === 0 || exact === 1) { // text search result (-1 from elsewhere)
              // NOTE. 'exact' IS '1' since here we always search for exact image name match:
              tmp += this.z.imdbRoot + chalbs[i] + "</a>";
              tmp += " &nbsp;&nbsp;&nbsp;&nbsp;<a class=\"hoverDark\" onclick='parent.selectJstreeNode(" + i + ");return false' style='font-family:Arial,Helvetica,sans-serif;font-size:70%;font-variant:small-caps;text-decoration:none'>" + this.intl.t('allInAlbum') + "</a>";
            } else { // find duplicates result
              tmp += this.z.imdbRoot + chalbs [i] + "</a>";
            }
            this.countAlbs.push (tmp);
          }
        }
      }
        // this.z.loli(this.keepIndex, 'color:red');
        // this.z.loli(this.counts, 'color:red');
        // this.z.loli(this.inames, 'color:red');
      if(keepOld) {this.countAlbs = this.countAlbs.join('<br>');}
    }
    this.z.openDialog('dialogFindResult');
  }

  /**
  searchText: contains the server search/ call

  Search the image texts in the current imdbRoot (cf. prepSearchDialog)
  @param {string}  sTxt space separated search items
  @param {boolean} and true=>AND | false=>OR
  @param {boolean} searchWhere array, checkboxes for selected texts
  @param {integer} exact <>0 removes SQL ´%´s (>0 means origin dialogTextNotes, <0 dialogFind)
  @returns {string} \n-separated file paths
  NOTE: Non-zero ´exact´ also means "Only search for image names (file 'basenames')!"
  NOTE: Negative ´exact´, -1 = called from the find? dialog, -2 = do nothing,
        else (non-negative) = called from and return to the favorites? dialog
  */
  searchText = (sTxt, and, searchWhere, exact) => {
    this.seast = '';
    document.getElementById('go_back').click(); // close show, perhaps unneccessary
    // close all dialogs? perhaps unneccessary
    let AO, andor = '';
    if (and) {AO = ' AND '} else {AO = ' OR '};
    if (sTxt === "") {sTxt = undefined;}
    let cmt = '';
    // The first line may be a comment, to ignore:
    if (sTxt.slice (0, 1) === '#') {
      let l = sTxt.indexOf('\n');
      cmt = sTxt.slice(1, l);
      sTxt = sTxt.slice(l + 1);

        // this.z.loli(cmt, 'color:yellow');

    }
    let txt = sTxt.trim();
    let str = '';
    let arr = [];
    if (txt) {
      txt = txt.replace(/\s+/g, ' ').trim();
      this.seast = txt;

        // this.z.loli(txt, 'color:red');

      arr = txt.split (' ');
      for (let i = 0; i<arr.length; i++) {
        // Replace any `'` with `''`: will be enclosed within `'`s in SQL
        arr[i] = arr[i].replace (/'/g, "''");
        // Replace underscore to be taken literally, needs `ESCAPE '\'`
        arr[i] = arr[i].replace (/_/g, '\\_');
        // First replace % (NBSP):
        arr[i] = arr[i].replace (/%/g, ' '); // % in Mish means 'sticking space'
        // Then use % the SQL way if applicable and add `ESCAPE '\'` for '_':
        let esc = arr[i].indexOf('_') < 0 ? "'" : "' ESCAPE '\\'";
        // Exact match for file (base) names, e.g. favorites search
        if (exact !== 0) {
          arr[i] = "'" + arr[i] + esc;
        } else {
          arr[i] = "'%" + arr[i] + '%' + esc;
        }
        if (i > 0) {andor = AO}
        str += andor + "txtstr LIKE " + arr[i].trim ();
      }
        // // A double printout clarifies the %-autosubstitution of console.log
        // this.z.loli(str, 'color:orange  ');
        // this.z.loli(str.replace(/%/g, '*'), 'color:yellow');
        // console.log(searchWhere);
      let srchData = new FormData ();
      srchData.append ("like", str);
      srchData.append ("cols", searchWhere);
      if (exact !== 0) srchData.append ("info", "exact");
      else srchData.append ("info", "");
        console.log(srchData);
      return new Promise((resolve, reject) => {
        let xhr = new XMLHttpRequest();
        xhr.open('POST', 'search/');
        this.z.xhrSetRequestHeader(xhr);
        xhr.onload = function () {
          if (this.status >= 200 && this.status < 300) {
            var data = xhr.response.trim ();
            if (exact !== 0) { // reorder like searchString
              var datArr = data.split("\n");
                console.log("searchText datArr.length",datArr.length);
              var namArr = [];
              var seaArr = [];
              var tmpArr = [];
              var albArr = [];
              for (let i=0; i<datArr.length; i++) {
                namArr [i] = datArr [i].replace(/^(.*\/)*(.*)(\.[^.]*)$/,"$2");
                tmpArr [i] = namArr [i]; // Just in case
                albArr [i] = datArr [i].replace (/^(.*\/)*(.*)(\.[^.]*)$/,"$1").slice (1, -1);
              }
              searchString = searchString.replace (/ +/g, " ");
              if (arr) seaArr = searchString.split (" ");
              // The 'reordering template' (seaArr) depends on this special switch set in altFind:
              if (seaArr [0] === "dupName/") seaArr = tmpArr.sort ();
              else if (seaArr [0] === "dupImage/") seaArr.splice (0, 1);
              else if (seaArr [0] === "actualDups/") seaArr.splice (0, 1);
              else if (seaArr [0] === "subAlbDups/") seaArr.splice (0, 1);

              data = [];
              for (let i=0; i<seaArr.length; i++) {
                for (let j=0; j<namArr.length; j++) {
                  if (seaArr [i] === namArr [j]) {
                    data [i] = datArr [j];
                    namArr [j] = "###";
                    break;
                  }
                }
              }
              data = data.join("\n");
            }
            resolve (data);
          } else {
            reject ({
              status: this.status,
              statusText: xhr.statusText
            });
          }
        };
        xhr.send (srchData);
      });
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
              <span class="glue" style="padding-bottom:0.5rem">
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

      <dialog id='dialogFindResult' style="max-width:calc(100vw - 2rem);z-index:16">
        <header data-dialog-draggable>
          <p>&nbsp;</p>
          <p>{{{t 'write.findResultHeader' n=this.nchk c=this.z.imdbRoot}}}<br><span style="text-overflow:ellipsis">{{t 'searchedFor'}}: {{this.seast}}</span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog 'dialogFindResult')}}>×</button>
        </header>
        <main style="padding:0 0.5rem 0 1rem;height:auto;line-height:150%;overflow:auto" width="99%">

          <br>{{t 'found'}},  {{t 'chooseShow'}}:<br>

          {{#each this.keepIndex as |i|}}

            <a class="hoverDark" onclick="console.log({{i}},false,[false,false,false,false,true], 1);return false" style="text-decoration:none">
              {{{this.count i}}} &nbsp;&nbsp;{{t 'in'}}&nbsp;&nbsp; {{this.z.imdbRoot}}{{this.album i}}
            </a> &nbsp;&nbsp;&nbsp;&nbsp;

            <a class="hoverDark" style="font-family:Arial,Helvetica,sans-serif;font-size:70%;font-variant:small-caps;text-decoration:none"
             {{on 'click' (fn this.z.openAlbum i)}}>
              {{t 'allInAlbum'}}
            </a><br>

          {{/each}}
          {{!-- <br>{{{this.countAlbs}}}<br><br> --}}
          <br>

        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.z.closeDialog 'dialogFindResult')}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

    </div>

  </template>
}
