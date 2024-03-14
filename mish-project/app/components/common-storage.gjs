
import { loli } from './welcome';
import { userName } from './welcome';

let rnd = "." + Math.random().toString(36).substr(2,4);
//rnd = ".000";
export var picFound = "Funna_bilder" + rnd;
var imdbRoot = "MISH";
var imdbDir = "/album";

export function logIn() {
  return new Promise(resolve => {
    getCredentials(userName).then(credentials => {
      console.log('credentials', credentials);
      var cred = credentials.split("\n");
      var password = cred [0];
      status = cred [1];
      var allval = cred [2];
      let pwd = "TORE_tore";
      if (pwd !== password) {
        zeroSet(); // Important!
        status = "viewer";
      }
    });
  });
}

function getCredentials(user) {
  return new Promise((resolve, reject) => {
    // ===== XMLHttpRequest checking 'usr'
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'login/' + user, true, null, null);
    setReqHdr(xhr, 7);
    xhr.onload = function() {
      resolve(xhr.response);
    }
    xhr.onerror = function() {
      reject({
        status: that.status,
        statusText: xhr.statusText
      });
    }
    xhr.send();
  }).catch(error => {
    console.error(error.message);
  });

function setReqHdr(xhr, id) { !id; // id was used only as a debug identity
  xhr.setRequestHeader("imdbroot", encodeURIComponent(imdbRoot));
  xhr.setRequestHeader("imdbdir", encodeURIComponent(imdbDir));
  xhr.setRequestHeader("picfound", picFound); // All 'wihtin 255' characters
}

//loli(await getCredentials("tore"));

/* export const CommonStorage = <template>
  <div id="backImg" style="display:none"></div>
  <div id="bkgrColor" style="display:none">rgb(59, 59, 59)</div>
  <div id="chkPaths" style="display:none" title="for update SQlite DB"></div>
  <div id="hideColor" style="display:none">rgb(92, 98, 102)</div>
  <div id="hideFlag" style="display:none" title="do'nt show 'hidden'pictures">1</div>
  <div id="hideNames" style="display:none" title="hide picture names">1</div>
  <div id="imdbCoco" title="albums content counts" style="display:none"></div>
  <div id="imdbDir" title="path to album" style="display:none"></div>
  <div id="imdbDirs" title="paths to albums" style="display:none"></div>
  <div id="imdbIntro" title="introduction info" style="display:none"></div>
  <div id="imdbLabels" title="paths to album labels" style="display:none"></div>
  <div id="imdbLink" title="link name to this album collection" style="display:none"></div>

  <div id="imdbPath" title="absolute path to this album collection" style="display:none"></div>

  <div id="imdbRoot" title="relative path to this album collection" style="display:none"></div>
  <div id="imdbRoots" title="relative paths to album collections" style="display:none"></div>
  <div id="navAuto" title="on/off autoshow" style="display:none">false</div>
  <div id="navKeys" title="turn off at other use" style="display:none">true</div>
  <div id="picFound" title="album name for found pictures" style="display:none">Found_pictures</div>
  <div id="picName" style="display:none"></div>
  <div id="picNames" style="display:none"></div>
  <div id="picOrder" title="picNames without random extension for?move" style="display:none"></div>
  <div id="picOrig" style="display:none"></div>
  <div id="picThres" title="initial image similarity threshold" style="display:none">98</div>
  <div id="showFactor" title="initial seconds/picture" style="display:none">2</div>
  <div id="sortOrder" title="for imdDir's file order information table" style="display:none"></div>
  <div id="temporary" style="display:none"></div>
  <div id="temporary_1" style="display:none"></div>
  <div id="topMargin" title="pixels above slide shown" style="display:none">18</div>
  <div id="uploadNames" title="last uploaded" style="display:none"></div>
  <div id="userDir" title="user's home or choice where album roots should be found" style="display:none"></div>
</template>
*/

var allowance = [ // 'allow' order
  "adminAll",     // + allow EVERYTHING
  "albumEdit",    // +  " create/delete album directories
  "appendixEdit", // o  " edit appendices (attached documents)
  "appendixView", // o  " view     "
  "delcreLink",   // +  " delete and create linked images NOTE *
  "deleteImg",    // +  " delete (= remove, erase) images NOTE *
  "imgEdit",      // o  " edit images
  "imgHidden",    // +  " view and manage hidden images
  "imgOriginal",  // +  " view and download full size images
  "imgReorder",   // +  " reorder images
  "imgUpload",    // +  " upload    "
  "notesEdit",    // +  " edit notes (metadata) NOTE *
  "notesView",    // +  " view   "              NOTE *
  "saveChanges",  // +  " save order/changes (= saveOrder)
  "setSetting",   // +  " change settings
  "textEdit"      // +  " edit image texts (metadata)
];                // + is used
                  // o is not yet used
var allowtxt = [  // Ordered as 'allow', IMPORTANT!
  "Får göra vadsomhelst (+ gömda album)", // {{t 'adminAll'}}
  "göra/radera album",                    // {{t 'albumEdit'}}
  "(arbeta med bilagor +4)",                     // etc.?
  "(se bilagor)",
  "flytta till annat album, göra/radera länkar",
  "radera bilder +5",
  "(redigera bilder)",
  "gömma/visa bilder",
  "se högupplösta bilder *",
  "flytta om bilder inom album",
  "ladda upp originalbilder till album",
  "redigera/spara anteckningar +13",
  "se anteckningar",
  "spara ändringar utöver text",
  "ändra inställningar",
  "redigera/spara bildtexter, gömda album"
];
var allowvalue = "0".repeat(allowance.length);
var allow = {};

function zeroSet() { // Called at logout
  allowvalue = "0".repeat(allowance.length);  // 0 or 1
}

function allowFunc() { // Called from setAllow (called from logIn, toggleSettings,..)
  for (var i=0; i<allowance.length; i++) {
    allow [allowance [i]] = Number(allowvalue [i]);
    //console.log(allowance[i], allow [allowance [i]]);
  }
  if (allow.deleteImg) {  // NOTE *  If ...
    allow.delcreLink = 1; // NOTE *  then set this too
    i = allowance.indexOf("delcreLink");
    allowvalue = allowvalue.slice(0, i - allowvalue.length) + "1" + allowvalue.slice(i + 1 - allowvalue.length); // Also set the source value since:
    // allowvalue [i] = "1"; Gives a weird compiler error: "4 is read-only" if i=4
  }
  if (allow.notesEdit) { // NOTE *  If ...
    allow.notesView = 1; // NOTE *  then set this too
    i = allowance.indexOf("notesView");
    allowvalue = allowvalue.slice(0, i - allowvalue.length) + "1" + allowvalue.slice(i + 1 - allowvalue.length);
  }
  // Hide smallbuttons we don't need:
  if (allow.adminAll || allow.saveChanges) {
    document.getElementById("saveOrder").style.display = ""; // CSS sets
  } else {
    document.getElementById("saveOrder").style.display = "none"; // CSS overridden
  }
  //console.log(allow);
}
