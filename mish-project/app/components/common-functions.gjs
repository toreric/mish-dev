//== Mish common export function storage

export function logIn(username, imdbdir, imdbroot, picfound, password) {
  return new Promise(resolve => {
    getCredentials(username, imdbdir, imdbroot, picfound).then(credentials => {
      console.log('credentials:\n' + credentials);
      var cred = credentials.split('\n');
      var pawd = cred [0];
      var status = cred [1];
      var allval = cred [2];
      if (pawd !== password) {
        username = '';
        zeroSet(); // Important!
        status = 'viewer';
      }
      resolve (username + '\n' + status);
    });
  });
}

export function getCredentials(username, imdbdir, imdbroot, picfound) {
  return new Promise((resolve, reject) => {
    // ===== XMLHttpRequest checking 'usr'
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'login', true, null, null);
    // setReqHdr(xhr, 999);
    xhr.setRequestHeader('username', encodeURIComponent(username));
    xhr.setRequestHeader('imdbdir', encodeURIComponent(imdbdir));
    xhr.setRequestHeader('imdbroot', encodeURIComponent(imdbroot));
    xhr.setRequestHeader('picfound', picfound); // All 'wihtin 255' characters
    xhr.onload = function() {
      resolve(xhr.response);
    }
    xhr.onerror = function() {
      reject({
        status: this.status,
        statusText: xhr.statusText
      });
    }
    xhr.send();
  }).catch(error => {
    console.error(error.message);
  });
}
