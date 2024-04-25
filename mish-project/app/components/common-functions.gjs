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
