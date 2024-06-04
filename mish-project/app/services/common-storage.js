//== Mish common storage service with global properties/methods

import Service from '@ember/service';
import { inject as service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

export default class CommonStorageService extends Service {
  @service intl;

  //#region Variables
  //== Significant Mish system global variables

  @tracked  bkgrColor = '#cbcbcb';          //common background color
  @tracked  credentials = '';               //user credentials: \n-string from db
  @tracked  freeUsers = 'guest...';         //user names which do not require passwords
  @tracked  imdbCoco = '';                  //content counters etc. for imdbDirs (*)
  @tracked  imdbDir = '';                   //actual/current (sub)album directory
  @tracked  imdbDirs = '';                  //available album directories at imdbRoot
  @tracked  imdbLabels = '';                //thumbnail labels for imdbDirs
  @tracked  imdbPath = '';                  //userDir+imdbRoot = absolut path to album root
  @tracked  imdbRoot = '';                  //chosen album root directory (collection)
  @tracked  imdbRoots = ['fake', 'falsch']; //avalable album root directories (collections)
        get intlCode() { return `${this.intl.t('intlcode')}`; }
        get picFoundBaseName() { return `${this.intl.t('picfound')}`; }
            // The found pics temporary catalog name is amended with a random 4-code:
  @tracked  picFound = this.picFoundBaseName +"."+ Math.random().toString(36).substring(2,6);
  @tracked  picName = 'IMG_1234a2023_nov_19'; //actual/current image name
  @tracked  userDir = '/path/to/albums'; //maybe your home dir. or any; server argument!
        get defaultUserName() { return `${this.intl.t('guest')}`; }
  @tracked  userName = this.defaultUserName; // May be changed in other ways at e.g. logins
  @tracked  userStatus = '';
  // More variables may be defined further down
  // (*) imdbCoco format is "(<npics>) <nsubdirs> <flag>" where <flag> is empty or "*"
  // The imdbCoco <flag> indicates a hidden album, which needs permission for access

  //#region Utilities
  //== Other service functions

  toggleBackg = () => {
    if (this.bkgrColor === '#cbcbcb') {
      this.bkgrColor = '#111';
      this.textColor = '#fff';
      this.loli('set dark background');
    } else {
      this.bkgrColor = '#cbcbcb';
      this.textColor = '#111';
      this.loli('set light background');
    }
    document.querySelector('body').style.background = this.bkgrColor;
    document.querySelector('body').style.color = this.textColor;
  }

  loli = (text) => { // loli = log list with user name
    console.log(this.userName + ':', text);
  }

  //#region Server
  //== Server tasks

  getCredentials = async (username) => {
    // await new Promise (z => setTimeout (z, 555));
    username = username.trim();
    // this.loli(this.userName);
    if (username === 'Get user name') { // Welcome, initiation
      username = this.userName; // Default log in
      // this.imdbDir = '';  // Empty it
      this.imdbRoot = ''; // Empty it
    }
    // this.loli(username + ' (parameter)');
    if (username === 'Get allowances') username = '';
    return new Promise((resolve, reject) => {
      // ===== XMLHttpRequest returning user credentials
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'login/', true, null, null);
      xhr.setRequestHeader('username', encodeURIComponent(username));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.imdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'widhtin 255' characters
      xhr.onload = function() {
        let res = xhr.response;
        resolve(res);
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

  getAlbumRoots = async () => {
    // Propose root directory (requestDirs)
    return new Promise ( (resolve, reject) => {
      var xhr = new XMLHttpRequest ();
      xhr.open ('GET', 'rootdir/', true, null, null);
      xhr.setRequestHeader('username', encodeURIComponent(this.username));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.imdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'wihtin 255' characters
      xhr.onload = function () {
        if (this.status >= 200 && this.status < 300) {
          var dirList = xhr.response;
          resolve (dirList);
        } else {
          reject ({
            status: this.status,
            statusText: xhr.statusText
          });
        }
      };
      xhr.onerror = function () {
        reject ({
          status: this.status,
          statusText: xhr.statusText
        });
      };
      xhr.send ();
    }).catch (error => {
      if (error.status !== 404) {
        console.error (error.message);
      } else {
        console.warn ("reqRoot: No NodeJS server");
      }
    });
  }

  getAlbumDirs = async () => {
    // Get album collections or albums if thisDir is an album root
    return new Promise((resolve, reject) => {
      // ===== XMLHttpRequest returning user credentials
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'imdbdirs/', true, null, null);
      xhr.setRequestHeader('username', encodeURIComponent(this.username));
      xhr.setRequestHeader('imdbdir', encodeURIComponent(this.imdbDir));
      xhr.setRequestHeader('imdbroot', encodeURIComponent(this.imdbRoot));
      xhr.setRequestHeader('picfound', this.picFound); // All 'wihtin 255' characters
      xhr.onload = function() {
        let res = xhr.response;
        resolve(res);
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

  //#region Allowance
  //== Allowances properties/methods

  // allowvalue is the source of the 'allow' property values, reset at login
  @tracked allowvalue = "0".repeat (this.allowance.length);

  // Infotext retreived from _imdb_settings.sqlite datbase in dialog-login
  @tracked allowances = '';

  zeroSet = () => { // Will this be needed any more?
    this.allowvalue = ('0'.repeat (this.allowance.length));
  }

  @tracked allow = {};

  @tracked allowance = [     //  'allow' order
                    //
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
                    //
                    // o = not yet used
  ];

  // allowText = [ // Ordered as 'allow', IMPORTANT!
  get allowText() { return [
    `adminAll: ${this.intl.t('adminAll')}`,
    `albumEdit: ${this.intl.t('albumEdit')}`,
    `appendixEdit: ${this.intl.t('appendixEdit')}`,
    `appendixView: ${this.intl.t('appendixView')}`,
    `delcreLink: ${this.intl.t('delcreLink')}`,
    `deleteImg: ${this.intl.t('deleteImg')}`,
    `imgEdit: ${this.intl.t('imgEdit')}`,
    `imgHidden: ${this.intl.t('imgHidden')}`,
    `imgOriginal: ${this.intl.t('imgOriginal')}`,
    `imgReorder: ${this.intl.t('imgReorder')}`,
    `imgUpload: ${this.intl.t('imgUpload')}`,
    `notesEdit: ${this.intl.t('notesEdit')}`,
    `notesView: ${this.intl.t('notesView')}`,
    `saveChanges: ${this.intl.t('saveChanges')}`,
    `setSetting: ${this.intl.t('setSetting')}`,
    `textEdit: ${this.intl.t('textEdit')}`
  ];}

  allowFunc = () => { // Called from Welcome after login
    var allow = this.allow;
    var allowance = this.allowance;
    var allowvalue = this.allowvalue;
    for (var i=0; i<allowance.length; i++) {
      allow [allowance [i]] = Number (allowvalue [i]);
    }
    if (allow.adminAll) {
      allowvalue = "1".repeat (this.allowance.length);
      for (var i=0; i<allowance.length; i++) {
        allow [allowance [i]] = 1;
      }
    }
    if (allow.deleteImg) {  // NOTE *  If ...
      allow.delcreLink = 1; // NOTE *  then set this too
      i = allowance.indexOf ("delcreLink");
      // Also set the source value (in this way since allowvalue [i] = "1" in't allowed: compiler error: "4 is read-only" if 4 = the index value)
      allowvalue = allowvalue.slice (0, i - allowvalue.length) + "1" + allowvalue.slice (i + 1 - allowvalue.length);
    }
    if (allow.notesEdit) { // NOTE *  If ...
      allow.notesView = 1; // NOTE *  then set this too
      i = allowance.indexOf ("notesView");
      allowvalue = allowvalue.slice (0, i - allowvalue.length) + "1" + allowvalue.slice (i + 1 - allowvalue.length);
    }
    // Hide smallbuttons we don't need:
    if (allow.saveChanges) {
      document.getElementById('saveOrder').style.display = '';
    } else { // Any user may reorder but not save
      document.getElementById('saveOrder').style.display = 'none';
    }
    this.allow = allow;
    this.allowance = allowance;
    this.allowvalue = allowvalue;
  }

  //#region Menus
  //== Menu utilities

  toggleMainMenu = async () => {
    var menuMain = document.getElementById("menuMain");
    var menuButton = document.getElementById("menuButton");
    if (menuMain.style.display === "none") {
      menuMain.style.display = "";
      await new Promise (z => setTimeout (z, 9));
      menuButton.innerHTML = '<span class="menu">×</span>';
      await new Promise (z => setTimeout (z, 9));
      this.loli('opened main menu');
    } else {
      menuMain.style.display = "none";
      await new Promise (z => setTimeout (z, 9));
      menuButton.innerHTML = '<span class="menu">☰</span>';
      await new Promise (z => setTimeout (z, 9));
      this.loli('closed main menu');
    }
  }

  //#region Dialogs
  //== Dialog utilities for open/close/modal ...

  // Functions openDialog(id, op), toggleDialog(id, op), openModalDialog(id, op),
  // saveDialog(id), closeDialog(id), and saveCloseDialog(id) (= save then close),
  // where id = `dialogId` and op = 'original position'. If op is `true` then the dialog
  // is opened in the original position -- else opened where it was left at last close.
  // The close function may be modified to return to original position before closing.

  openDialog = (dialogId, origPos) => {
    let diaObj = document.getElementById(dialogId);
    if (!diaObj.open) {
      diaObj.show();
      if (origPos) diaObj.style = '';
      this.loli('opened ' + dialogId);
    }
  }

  toggleDialog = (dialogId, origPos) => {
    let diaObj = document.getElementById(dialogId);
    let what = 'closed ';
    if (diaObj.hasAttribute("open")) {
      diaObj.close();
    } else {
      what = 'opened ';
      if (origPos) diaObj.style = '';
      diaObj.show();
    }
    this.loli(what + dialogId);
  }

  openModalDialog = (dialogId, origPos) => {
    let diaObj = document.getElementById(dialogId);

    if (!diaObj.open) {
      if (origPos) diaObj.style = '';
      diaObj.showModal();
      this.loli('opened ' + dialogId + ' (modal)');
    }
  }

  saveDialog = (dialogId) => {
    // save code here, to do!
    // needs alternatives for any dialogId
    this.loli('saved ' + dialogId);
  }

  closeDialog = (dialogId) => {
    let diaObj = document.getElementById(dialogId);
    if (diaObj.open) {
      diaObj.close();
      this.loli('closed ' + dialogId);
    }
  }

  saveCloseDialog = (dialogId) => {
    this.saveDialog(dialogId);
    this.closeDialog(dialogId);
  }

  //#region dTree
  /*--------------------------------------------------|
  | dTree 2.05 | www.destroydrop.com/javascript/tree/ |
  |---------------------------------------------------|
  | Copyright (c) 2002-2003 Geir Landrö               |
  |                                                   |
  | This script can be used freely as long as all     |
  | copyright messages are intact.                    |
  |                                                   |
  | Updated: 17.04.2003                               |
  |--------------------------------------------------*/

  // Tree object
  dTree = class {
    constructor(objName) {
      this.config = {
        target: null,
        folderLinks: true,
        useSelection: true,
        useCookies: true,
        useLines: true,
        useIcons: true,
        useStatusText: false,
        closeSameLevel: false,
        inOrder: false
      };
      this.icon = {
        root: 'img/base.gif',
        folder: 'img/folder.gif',
        folderOpen: 'img/folderopen.gif',
        node: 'img/page.gif',
        empty: 'img/empty.gif',
        line: 'img/line.gif',
        join: 'img/join.gif',
        joinBottom: 'img/joinbottom.gif',
        plus: 'img/plus.gif',
        plusBottom: 'img/plusbottom.gif',
        minus: 'img/minus.gif',
        minusBottom: 'img/minusbottom.gif',
        nlPlus: 'img/nolines_plus.gif',
        nlMinus: 'img/nolines_minus.gif'
      };
      this.obj = objName;
      this.aNodes = [];
      this.aIndent = [];
      this.root = new this.Node(-1);
      this.selectedNode = null;
      this.selectedFound = false;
      this.completed = false;
    }

    // Node object within tree object
    Node = class {
      constructor(id, pid, name, url, title, target, icon, iconOpen, open) {
        this.id = id;
        this.pid = pid;
        this.name = name;
        this.url = url;
        this.title = title;
        this.target = target;
        this.icon = icon;
        this.iconOpen = iconOpen;
        this._io = open || false;
        this._is = false;
        this._ls = false;
        this._hc = false;
        this._ai = 0;
        this._p;
      }
    }

    // Adds a new node to the node array
    add(id, pid, name, url, title, target, icon, iconOpen, open) {
      this.aNodes[this.aNodes.length] = new this.Node(id, pid, name, url, title, target, icon, iconOpen, open);
    }
    // Open/close all nodes
    openAll() {
      this.oAll(true);
    }
    closeAll() {
      this.oAll(false);
    }
    // Outputs the tree to the page
    toString() {
      var str = '<div class="dtree">\n';
      if (document.getElementById) {
        if (this.config.useCookies) this.selectedNode = this.getSelected();
        str += this.addNode(this.root);
      } else str += 'Browser not supported.';
      str += '</div>';
      if (!this.selectedFound) this.selectedNode = null;
      this.completed = true;
      return str;
    }
    // Creates the tree structure
    addNode(pNode) {
      var str = '';
      var n = 0;
      if (this.config.inOrder) n = pNode._ai;
      for (n; n < this.aNodes.length; n++) {
        if (this.aNodes[n].pid == pNode.id) {
          var cn = this.aNodes[n];
          cn._p = pNode;
          cn._ai = n;
          this.setCS(cn);
          if (!cn.target && this.config.target) cn.target = this.config.target;
          if (cn._hc && !cn._io && this.config.useCookies) cn._io = this.isOpen(cn.id);
          if (!this.config.folderLinks && cn._hc) cn.url = null;
          if (this.config.useSelection && cn.id == this.selectedNode && !this.selectedFound) {
            cn._is = true;
            this.selectedNode = n;
            this.selectedFound = true;
          }
          str += this.node(cn, n);
          if (cn._ls) break;
        }
      }
      return str;
    }
    // Creates the node icon, url and text
    node(node, nodeId) {
      var str = '<div class="dTreeNode">' + this.indent(node, nodeId);
      if (this.config.useIcons) {
        if (!node.icon) node.icon = (this.root.id == node.pid) ? this.icon.root : ((node._hc) ? this.icon.folder : this.icon.node);
        if (!node.iconOpen) node.iconOpen = (node._hc) ? this.icon.folderOpen : this.icon.node;
        if (this.root.id == node.pid) {
          node.icon = this.icon.root;
          node.iconOpen = this.icon.root;
        }
        str += '<img id="i' + this.obj + nodeId + '" src="' + ((node._io) ? node.iconOpen : node.icon) + '" alt="" />';
      }
      if (node.url) {
        str += '<a id="s' + this.obj + nodeId + '" class="' + ((this.config.useSelection) ? ((node._is ? 'nodeSel' : 'node')) : 'node') + '" href="' + node.url + '"';
        if (node.title) str += ' title="' + node.title + '"';
        if (node.target) str += ' target="' + node.target + '"';
        if (this.config.useStatusText) str += ' onmouseover="window.status=\'' + node.name + '\';return true;" onmouseout="window.status=\'\';return true;" ';
        if (this.config.useSelection && ((node._hc && this.config.folderLinks) || !node._hc))
          // str += ' {{on "click" (fn this.' + this.obj + '.s ' + nodeId + ')}}';//**
          str += ' onclick="javascript: ' + this.obj + '.s(' + nodeId + ');"';
        str += '>';
      }
      else if ((!this.config.folderLinks || !node.url) && node._hc && node.pid != this.root.id)
        // str += ' {{on "click" (fn this.' + this.obj + '.s ' + nodeId + ')}}';//**
        str += '<a href="javascript: ' + this.obj + '.o(' + nodeId + ');" class="node">';
      str += node.name;
      if (node.url || ((!this.config.folderLinks || !node.url) && node._hc)) str += '</a>';
      str += '</div>';
      if (node._hc) {
        str += '<div id="d' + this.obj + nodeId + '" class="clip" style="display:' + ((this.root.id == node.pid || node._io) ? 'block' : 'none') + ';">';
        str += this.addNode(node);
        str += '</div>';
      }
      this.aIndent.pop();
      return str;
    }
    // Adds the empty and line icons
    indent(node, nodeId) {
      var str = '';
      if (this.root.id != node.pid) {
        for (var n = 0; n < this.aIndent.length; n++)
          str += '<img src="' + ((this.aIndent[n] == 1 && this.config.useLines) ? this.icon.line : this.icon.empty) + '" alt="" />';
        (node._ls) ? this.aIndent.push(0) : this.aIndent.push(1);
        if (node._hc) {
          // str += '<a {{on "click" (fn this.' + this.obj + '.o ' + nodeId + ')}}><img id="j' + this.obj + nodeId + '" src="';//**
          str += '<a href="javascript: ' + this.obj + '.o(' + nodeId + ');"><img id="j' + this.obj + nodeId + '" src="';
          if (!this.config.useLines) str += (node._io) ? this.icon.nlMinus : this.icon.nlPlus;
          else str += ((node._io) ? ((node._ls && this.config.useLines) ? this.icon.minusBottom : this.icon.minus) : ((node._ls && this.config.useLines) ? this.icon.plusBottom : this.icon.plus));
          str += '" alt="" /></a>';
        } else str += '<img src="' + ((this.config.useLines) ? ((node._ls) ? this.icon.joinBottom : this.icon.join) : this.icon.empty) + '" alt="" />';
      }
      return str;
    }
    // Checks if a node has any children and if it is the last sibling
    setCS(node) {
      var lastId;
      for (var n = 0; n < this.aNodes.length; n++) {
        if (this.aNodes[n].pid == node.id) node._hc = true;
        if (this.aNodes[n].pid == node.pid) lastId = this.aNodes[n].id;
      }
      if (lastId == node.id) node._ls = true;
    }
    // Returns the selected node
    getSelected() {
      var sn = this.getCookie('cs' + this.obj);
      return (sn) ? sn : null;
    }
    // Highlights the selected node
    s(id) {
      if (!this.config.useSelection) return;
      var cn = this.aNodes[id];
      if (cn._hc && !this.config.folderLinks) return;
      if (this.selectedNode != id) {
        if (this.selectedNode || this.selectedNode == 0) {
          eOld = document.getElementById("s" + this.obj + this.selectedNode);
          eOld.className = "node";
        }
        eNew = document.getElementById("s" + this.obj + id);
        eNew.className = "nodeSel";
        this.selectedNode = id;
        if (this.config.useCookies) this.setCookie('cs' + this.obj, cn.id);
      }
    }
    // Toggle Open or close
    o(id) {
      var cn = this.aNodes[id];
      this.nodeStatus(!cn._io, id, cn._ls);
      cn._io = !cn._io;
      if (this.config.closeSameLevel) this.closeLevel(cn);
      if (this.config.useCookies) this.updateCookie();
    }
    // Open or close all nodes
    oAll(status) {
      for (var n = 0; n < this.aNodes.length; n++) {
        if (this.aNodes[n]._hc && this.aNodes[n].pid != this.root.id) {
          this.nodeStatus(status, n, this.aNodes[n]._ls);
          this.aNodes[n]._io = status;
        }
      }
      if (this.config.useCookies) this.updateCookie();
    }
    // Opens the tree to a specific node
    openTo(nId, bSelect, bFirst) {
      if (!bFirst) {
        for (var n = 0; n < this.aNodes.length; n++) {
          if (this.aNodes[n].id == nId) {
            nId = n;
            break;
          }
        }
      }
      var cn = this.aNodes[nId];
      if (cn.pid == this.root.id || !cn._p) return;
      cn._io = true;
      cn._is = bSelect;
      if (this.completed && cn._hc) this.nodeStatus(true, cn._ai, cn._ls);
      if (this.completed && bSelect) this.s(cn._ai);
      else if (bSelect) this._sn = cn._ai;
      this.openTo(cn._p._ai, false, true);
    }
    // Closes all nodes on the same level as certain node
    closeLevel(node) {
      for (var n = 0; n < this.aNodes.length; n++) {
        if (this.aNodes[n].pid == node.pid && this.aNodes[n].id != node.id && this.aNodes[n]._hc) {
          this.nodeStatus(false, n, this.aNodes[n]._ls);
          this.aNodes[n]._io = false;
          this.closeAllChildren(this.aNodes[n]);
        }
      }
    }
    // Closes all children of a node
    closeAllChildren(node) {
      for (var n = 0; n < this.aNodes.length; n++) {
        if (this.aNodes[n].pid == node.id && this.aNodes[n]._hc) {
          if (this.aNodes[n]._io) this.nodeStatus(false, n, this.aNodes[n]._ls);
          this.aNodes[n]._io = false;
          this.closeAllChildren(this.aNodes[n]);
        }
      }
    }
    // Change the status of a node(open or closed)
    nodeStatus(status, id, bottom) {
      eDiv = document.getElementById('d' + this.obj + id);
      eJoin = document.getElementById('j' + this.obj + id);
      if (this.config.useIcons) {
        eIcon = document.getElementById('i' + this.obj + id);
        eIcon.src = (status) ? this.aNodes[id].iconOpen : this.aNodes[id].icon;
      }
      eJoin.src = (this.config.useLines) ?
        ((status) ? ((bottom) ? this.icon.minusBottom : this.icon.minus) : ((bottom) ? this.icon.plusBottom : this.icon.plus)) :
        ((status) ? this.icon.nlMinus : this.icon.nlPlus);
      eDiv.style.display = (status) ? 'block' : 'none';
    }
    // [Cookie] Clears a cookie
    clearCookie() {
      var now = new Date();
      var yesterday = new Date(now.getTime() - 1000 * 60 * 60 * 24);
      this.setCookie('co' + this.obj, 'cookieValue', yesterday);
      this.setCookie('cs' + this.obj, 'cookieValue', yesterday);
    }
    // [Cookie] Sets value in a cookie
    setCookie(cookieName, cookieValue, expires, path, domain, secure) {
      document.cookie =
        escape(cookieName) + '=' + escape(cookieValue)
        + (expires ? '; expires=' + expires.toGMTString() : '')
        + (path ? '; path=' + path : '')
        + (domain ? '; domain=' + domain : '')
        + (secure ? '; secure' : '');
    }
    // [Cookie] Gets a value from a cookie
    getCookie(cookieName) {
      var cookieValue = '';
      var posName = document.cookie.indexOf(escape(cookieName) + '=');
      if (posName != -1) {
        var posValue = posName + (escape(cookieName) + '=').length;
        var endPos = document.cookie.indexOf(';', posValue);
        if (endPos != -1) cookieValue = unescape(document.cookie.substring(posValue, endPos));
        else cookieValue = unescape(document.cookie.substring(posValue));
      }
      return (cookieValue);
    }
    // [Cookie] Returns ids of open nodes as a string
    updateCookie() {
      var str = '';
      for (var n = 0; n < this.aNodes.length; n++) {
        if (this.aNodes[n]._io && this.aNodes[n].pid != this.root.id) {
          if (str) str += '.';
          str += this.aNodes[n].id;
        }
      }
      this.setCookie('co' + this.obj, str);
    }
    // [Cookie] Checks if a node id is in a cookie
    isOpen(id) {
      var aOpen = this.getCookie('co' + this.obj).split('.');
      for (var n = 0; n < aOpen.length; n++)
        if (aOpen[n] == id) return true;
      return false;
    }
  };

}

//#endregion
