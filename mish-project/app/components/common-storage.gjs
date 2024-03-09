

export function getCredentials(user) {
  return new Promise ( (resolve, reject) => {
    // ===== XMLHttpRequest checking 'usr'
    var xhr = new XMLHttpRequest ();
    xhr.open ('GET', 'login/' + user, true, null, null);
    setReqHdr (xhr, 7);
    xhr.onload = function() {
      resolve (xhr.response);
    }
    xhr.onerror = function() {
      reject ({
        status: that.status,
        statusText: xhr.statusText
      });
    }
    xhr.send ();
  }).catch (error => {
    console.error(error.message);
  });
}

loli(await getCredentials("tore"));

<template>
  <div id="allowValue" title="permissions" style="display:none"></div>
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
];
var allowSV = [ // Ordered as 'allow', IMPORTANT!
  "Får göra vadsomhelst (+ gömda album)", // {{t 'adminAll'}}
  "göra/radera album",                    // {{t 'albumEdit'}}
  "(arbeta med bilagor +4)",                     // etc.?
  "(se bilagor)",
  "flytta till annat album, göra/radera länkar",
  "radera bilder +5",
  "(redigera bilder)",
  "gömma/visa bilder",
  "se högupplösta bilder",
  "flytta om bilder inom album",
  "ladda upp originalbilder till album",
  "redigera/spara anteckningar +13",
  "se anteckningar",
  "spara ändringar utöver text",
  "ändra inställningar",
  "redigera/spara bildtexter, gömda album"
];
var allowvalue = "0".repeat (allowance.length);
