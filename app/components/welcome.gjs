import { on } from '@ember/modifier';

import focusTrap from 'ember-focus-trap/modifiers/focus-trap';
import { Modal } from 'ember-primitives';
import { cell } from 'ember-resources';

import { Clock } from './clock';
import { Excite } from './excite';

const Welcome = <template>
    <Header />
    <DialogText />
</template>;

export default Welcome;

const Header = <template>
    <h1>Welcome to Mish, Polaris revision</h1>
    <Excite />

    <p>Package <b>ember-primitives</b> added 2023-10-25 with pnpm
    </p>

    <p>The time is <span>{{Clock}}</span></p>

</template>;

const returnValue = cell('');




const DialogText = <template>
  <Modal @onClose={{returnValue.set}} as |m|>
    <button {{on 'click' m.open}}>Open Modal</button>

    <br><br>
    isOpen: {{m.isOpen}}<br>
    return: {{returnValue.current}}

    <m.Dialog {{focusTrap isActive=m.isOpen}}>
      <div>
        <header>
          <h2>Example Modal</h2>

          <button {{on 'click' m.close}}>×</button>
        </header>

        <form method="dialog">
          <main>
            Modal content here
            <br>

           This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text This is a text
          </main>

          <footer>
            <button type="submit" value="confirm">Confirm</button>
            <button type="submit" value="create">Create</button>
            <button type="reset" value="close" {{on 'click' m.close}}>Reset</button>
          </footer>
        </form>
      </div>
    </m.Dialog>
  </Modal>


  <style>
    dialog {
      border-width: 2px;
      border-color: #999;
      border-radius: 4px;
    }
    dialog > div {
      display: grid;
      gap: 2rem;
    }
    dialog::backdrop {
      backdrop-filter: blur(1px);
    }
    dialog header {
      display: flex;
      justify-content: space-between;
    }
    dialog h2 {
      margin: 0;
    }

    dialog main {
      max-width: 333px;
    }
    form {
      display: grid;
      gap: 1rem;
    }
    footer {
      text-align: center;
    }
  </style>
</template>


/* Experimens with xdialog.3.4.0.js
const Opener = <template>
    <p class="dialog-texts" {{on "click" openTexts}}>Open texts dialog</p>
</template>;

var charText = "<span style='float:left;margin:0.2em'>" +
  "&nbsp;<b class='insertChar' style='cursor:pointer'>’</b>" +
  "&nbsp;<b class='insertChar' style='cursor:pointer'>–</b>" +
  "&nbsp;<b class='insertChar' style='cursor:pointer'>×</b>" +
  "&nbsp;<b class='insertChar' style='cursor:pointer'>°</b>" +
  "&nbsp;<b class='insertChar' style='cursor:pointer'>—</b>" +
  "&nbsp;<b class='insertChar' style='cursor:pointer'>”</b>" +
  "<i> &larr; klicka för att kopiera</i></span>";

var xd_body = '<div id="textareas" style="margin:0;padding:0;width:100%">\n\
<div class="diaMess"><span class="edWarn">' + charText + '</span></div><br>\n\
<textarea name="description" rows="6" style="width:98%"></textarea><br>\n\
<textarea name="creator" rows="1" style="width:98%"></textarea>\n\
</div>'

var picName = 'IMG_1234a';

var param = {
  title: '<span>Bildtexter till</span> ' + picName,
  body: xd_body,
  modal: false,
  style: 'background:#ddd;width:98%;max-width:820px',
  effect: null,
  listenEnterKey: false,
  buttons: [
    '<button class="xd-button texts save" style="background:#555" {{on "click" saveTexts}}>Spara</button>',
    '<button class="xd-button texts saveclose" style="background:#090">Spara och stäng</button>',
    '<button class="xd-button texts close" style="background:#555">Stäng</button>',
    '<button class="xd-button texts notes">Anteckningar</button>',
    '<button class="xd-button texts keywords">Nyckelord</button>',
  ]
};

// eslint-disable-next-line no-undef
//xdialog.init(param);

// eslint-disable-next-line no-undef
let dialogTexts = xdialog.create(param);

var charList = document.querySelectorAll('b.insertChar');
// eslint-disable-next-line no-console
console.log(charList);

// Trigger special character insert elements
for (let i=0; i<charList.length; i++) {
  // eslint-disable-next-line no-console
  //console.log('"' + charList[i].innerHTML + '"');
  charList[i].addEventListener('mouseup', copyToClipboard(charList[i].innerHTML));
}

// Trigger dialog buttons
document.querySelector('.xd-button.texts.save').addEventListener('click', saveTexts);
document.querySelector('.xd-button.texts.saveclose').addEventListener('click', saveTextsClose);
document.querySelector('.xd-button.texts.close').addEventListener('click', closeTexts);
document.querySelector('.xd-button.texts.notes').addEventListener('click', openNotes);
document.querySelector('.xd-button.texts.keywords').addEventListener('click', openKeywords);

// NOTE: Arrow functions cannot be used as callbacks!
// Functions for this dialog:

function saveTexts() {
  // eslint-disable-next-line no-console
  console.log('This is dialog dialogTexts: ', dialogTexts.id);
  // eslint-disable-next-line no-console
  console.log('saveTexts');
}

function saveTextsClose() {
  saveTexts();
  closeTexts();
}

function closeTexts() {
  // eslint-disable-next-line no-console
  console.log(' closeTexts');
  dialogTexts.hide();
}

function openNotes() {
  // eslint-disable-next-line no-console
  console.log('openNotes');
}

function openKeywords() {
  // eslint-disable-next-line no-console
  console.log('openKeywords');
}

function openTexts() {
  // eslint-disable-next-line no-console
  console.log('openTexts');
  dialogTexts.show();
}

// eslint-disable-next-line no-unused-vars
function copyToClipboard (str) {   // Copies a filename (below mini-pic) to the clipboard
  // eslint-disable-next-line no-console
  var ae = document.activeElement; // Don't move focus from the active element but save and restore it
  setTimeout (function () {
    ae.focus ();
    document.execCommand('paste');
  }, 44);

  const el = document.createElement('textarea');  // Create a <textarea> element

  document.body.appendChild(el);                  // Append the <textarea> element to the HTML document
  el.value = str.trim ();                         // Set its value to the string that you want copied
  el.setAttribute('readonly', '');                // Make it readonly to be tamper-proof
  el.style.position = 'absolute';
  el.style.left = '-9999px';                      // Move outside the screen to make it invisible

  const selected =
    document.getSelection().rangeCount > 0        // Check if there is any content selected previously
      ? document.getSelection().getRangeAt(0)     // Store selection if found
      : false;                                    // Mark as false to know no selection existed before

  // A found symlink (presented in picFound) has a 'useless' random name extension ...
  // if ($ ("#imdbDir").text ().replace (/^[^/]*\//, "") === $ ("#picFound").text ()) {
  //   el.value = el.value.replace (/\.[^.]{4}$/, ""); // ... thus remove the extension!
  // }

  el.select();                                    // Select the <textarea> content
  document.execCommand('copy');                   // Copy - only works as a result of a user action (e.g. click events)
  document.body.removeChild(el);                  // Remove the <textarea> element

  if (selected) {                                 // If a selection existed before copying
    document.getSelection().removeAllRanges();    // Unselect everything on the HTML document
    document.getSelection().addRange(selected);   // Restore the original selection
  }
} */
