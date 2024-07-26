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
// import EmberTooltip from './ember-tooltip';

const LF = '\n'; // LINE_FEED
const SA = '‡';  // SUBALBUM indicator, NOTE! set in server (routes.js)


export class ViewMain extends Component {
  @service('common-storage') z;
  @service intl;

  <template>
    <div style="margin:0 0 0 4rem;width:auto;height:auto">
      <SubAlbums />
      <MiniImages />
    </div>
  </template>

}

class MiniImages extends Component {
  @service('common-storage') z;
  @service intl;

//   requestNames () { // ===== Request the file information list
//     // NEPF = number of entries (lines) per file in the plain text-line-result list ('namedata')
//     // from the server. The main information (e.g. metadata) is retreived from each image file.
//     // It is reordered into 'newdata' in 'sortnames' order, as far as possible;
//     // 'sortnames' is cleaned from non-existent (removed) files and extended with new (added)
//     // files, in order as is. So far, the sort order is 'sortnames' with hideFlag (and albumIndex?)
//     var that = this;
//     return new Promise ( (resolve, reject) => {
//       var IMDB_DIR =  $ ('#imdbDir').text ();
//       if (!IMDB_DIR) {IMDB_DIR = "/";} // Avoids empty parameter
//       IMDB_DIR = IMDB_DIR.replace (/\//g, "@"); // For sub-directories
//       var xhr = new XMLHttpRequest ();
// //console.log("requestNames:IMBD_DIR",IMDB_DIR);
//       xhr.open ('GET', 'imagelist/' + IMDB_DIR, true, null, null); // URL matches server-side routes.js
//       setReqHdr (xhr, 2);
//       var allfiles = [];
//       xhr.onload = function () {
//         if (this.status >= 200 && this.status < 300) {
//           var Fobj = EmberObject.extend ({
//             orig: '',  // for orig-file path (...jpg|tif|png|...)
//             show: '',  // for show-file path (_show_...png)
//             mini: '',  // for mini-file path (_mini_...png)
//             name: '',  // Orig-file base name without extension
//             txt1: 'description', // for metadata
//             txt2: 'creator',     // for metadata
//             symlink: ' ',        // SPACE, else the value for linkto
//             linkto: '',          //   which is set in refreshAll
//             albname: ''          //   "
//           });
//           var NEPF = 7; // Number of properties in Fobj
//           var result = xhr.response;
//           result = result.trim ().split ('\n'); // result is vectorised
//           var i = 0, j = 0;
//           var n_files = result.length/NEPF;
//           if (n_files < 1) { // Covers all weird outcomes
//             result = [];
//             n_files = 0;
//             $ ('.showCount .numShown').text (' 0');
//             $ ('.showCount .numHidden').text (' 0');
//             $ ('.showCount .numMarked').text ('0');
//             $ ("span.ifZero").hide ();
//             $ ('#navKeys').text ('false'); // Protecs from unintended use of L/R arrows
//           }
//           for (i=0; i<n_files; i++) {
//             if (result [j + 4]) {result [j + 4] = result [j + 4].replace (/&lt;br&gt;/g,"<br>");}
//             var f = Fobj.create ({
//               orig: result [j],
//               show: result [j + 1],
//               mini: result [j + 2],
//               name: result [j + 3],
//               txt1: htmlSafe (result [j + 4]),
//               txt2: htmlSafe (result [j + 5]),
//               symlink: result [j + 6],
//             });
//             if (f.txt1.toString () === "-") {f.txt1 = "";}
//             if (f.txt2.toString () === "-") {f.txt2 = "";}
//             j = j + NEPF;
//             allfiles.pushObject (f);
//           }
//           later ( ( () => {
//             $ (".showCount:first").show ();
//             $ (".miniImgs").show ();
//             if (n_files < 1) {
//               $ ("#toggleName").hide ();
//               $ ("#toggleHide").hide ();
//             }
//             else {
//               $ ("#toggleName").show ();
//               if (allow.adminAll || allow.imgHidden) $ ("#toggleHide").show ();
//             }
//             later ( ( () => {
//               that.actions.setAllow (); // Fungerar hyfsat ...?
//             }), 2000);
//           }), 2000);
//           //userLog ('INFO received');
//           resolve (allfiles); // Return file-list object array
//         } else {
//           reject ({
//             status: this.status,
//             statusText: xhr.statusText
//           });
//         }
//       };
//       xhr.onerror = function () {
//         reject ({
//           status: this.status,
//           statusText: xhr.statusText
//         });
//       };
//       xhr.send ();
//     })
//     .then ()
//     .catch (error => {
//       console.error ("requestNames", error.message);
//     });
//   },



}

class SubAlbums extends Component {
  @service('common-storage') z;
  @service intl;

  get nsub() {
    let res =  this.z.subaIndex.length;
    if (res < 1) res = this.intl.t('no'); // 'inget'
    return res;
  }

  get sual() {
    if (this.z.subaIndex.length === 1) {
      return this.intl.t('subalbum');
    } else {
      return this.intl.t('subalbums');
    }
  }

  get nadd() {
    // this.z.loli(this.z.imdbDirIndex);
    let coco = '';
    if (this.z.imdbCoco) coco = this.z.imdbCoco[this.z.imdbDirIndex];
    let plus= '';
    if (coco && coco.includes(SA)) { // Avoids error if imdbDirIndex is out of range
      let re = new RegExp(String.raw`${SA}.*$`) // If SA is '*' etc. then use ´\\*'
      // Check if there are more subalbums than the primary subalbums
      let more = Number(coco.replace(re, '').replace(/\ *[(0-9+)]+\ +([0-9]+)$/, '$1')) - this.z.subaIndex.length;

      if (more > 0) plus =' (' + this.intl.t('plus') + ' ' + more + ')';
    }
    return plus;
  }

  imdbDirs = (i) => {
    return this.z.imdbDirs[i];
  }

  imdbLabels = (i) => {
    return this.z.imdbLabels[i];
  }

  dirName = (i) => {
    return this.z.imdbDirs[i].replace(/^(.*\/)*([^/]+)$/, '$2').replace(/_/g, ' ');
  }

  setLabel = (i) => {
    let label = this.z.imdbLabels[i];
    if (!label) label = 'images/empty.gif';
    return label;
  }

  <template>
    <p class='albumsHdr' draggable="false" ondragstart="return false">
      <div class="miniImgs">
        {{#if this.z.imdbRoot}}
          <span title={{this.z.imdbDir}}>
            <b>”{{{this.z.imdbDirName}}}”</b>
            {{t 'has'}} {{this.nsub}} {{this.sual}}
            {{!-- <a {{on 'click' (fn this.z.alertMess this.naddTxt this.naddHdr)}}>{{this.nadd}}</a> --}}
            <span title={{t 'plusExplain'}}>{{this.nadd}}</span>
          </span>
          <br>
          {{#each this.z.subaIndex as |i|}}
            <div class="subAlbum" title={{this.imdbDirs i}}
              {{on 'click' (fn this.z.openAlbum i)}}>
              <a class="imDir" style="background:transparent" title-2="Album ”{{this.dirName i}}”">
                {{!-- {{#if (eq '' (fn this.imdbLabels i))}} --}}
                  <img src={{this.setLabel i}} alt="Album ”{{this.dirName i}}”"><br>
                {{!-- {{/if}} --}}
                <span style="font-size:85%;color:{{this.z.subColor}}">{{this.dirName i}}</span>
              </a>
            </div>
          {{/each}}
        {{/if}}
      </div>
    </p>
  </template>

}
