//== Mish common export function storage

// import { imdbDir } from './common-storage';
// import { imdbRoot } from './common-storage';
// import { picFound } from './common-storage';
// import { userName } from './common-storage';

let imdbDir = '';
let imdbRoot = '';
let picFound = '';
let userName = '';

export function loli(text) { // loli = log list
  console.log(userName, text);
}

export function logIn() {
  return new Promise(resolve => {
    getCredentials(userName).then(credentials => {
      console.log('credentials:\n' + credentials);
      var cred = credentials.split('\n');
      var password = cred [0];
      status = cred [1];
      var allval = cred [2];
      let pawd = 'TORE_tore';
      if (pawd !== password) {
        userName = '';
        zeroSet(); // Important!
        status = 'viewer';
      }
    });
  });
}

export function getCredentials(user) {
  return new Promise((resolve, reject) => {
    // ===== XMLHttpRequest checking 'usr'
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'login', true, null, null);
    setReqHdr(xhr, 999);
    xhr.setRequestHeader('user', encodeURIComponent(user));
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
}

export function setReqHdr(xhr, id) { !id; // id was used only as a debug identity
  xhr.setRequestHeader('imdbdir', encodeURIComponent(imdbDir));
  xhr.setRequestHeader('imdbroot', encodeURIComponent(imdbRoot));
  xhr.setRequestHeader('picfound', picFound); // All 'wihtin 255' characters
}

