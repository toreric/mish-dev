//== Mish dialog for image searches (in texts: captions etc.)

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import { TrackedAsyncData } from 'ember-async-data';

import RefreshThis from './refresh-this';

// Note: Dialog-functions in Header needs dialogFindId:
export const dialogFindId = 'dialogFind';

document.addEventListener('mousedown', async (e) => {
  e.stopPropagation();
});

document.addEventListener('keydown', async (e) => {
  if (e.keyCode === 27) {
    e.stopPropagation();
    if (document.getElementById(dialogFindId).open) {
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
      if (document.getElementById(dialogFindId).open) this.z.closeDialog(dialogFindId);
    }
  }

  findit = () => {
    this.z.loli('findit', 'color:red');
  }
  <template>

    <div style="display:flex" {{on 'keydown' this.detectEscClose}}>

      <dialog id='dialogFind'>
        <header data-dialog-draggable >
          <p>&nbsp;</p>
          <p><b>{{t 'dialog.find.header'}}</b> <span></span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogFindId)}}>×</button>
        </header>
        <main>
          <textarea name="searchtext" placeholder="Skriv här sökbegrepp, åtskilda av blanktecken, små/stora bokstäver oviktigt (välj nedan vilka texter du vill söka i)" rows="4" style="width: min(calc(100vw - 1rem),700px)"></textarea>

          <div class="diaMess">
            <div class="edWarn" style="font-weight:normal;text-align:right"></div>
            <div class="srchIn"> Sök i:&nbsp;
              <span class="glue">
                <input id="t1" name="search1" value="description" checked="" type="checkbox">
                <label for="t1">&nbsp;bildtext (övre texten)</label>&nbsp;
              </span>
              <span class="glue">
                <input id="t2" name="search2" value="creator" checked="" type="checkbox">
                <label for="t2">&nbsp;ursprung (nedre texten)</label>&nbsp;
              </span>
              <span class="glue" style="display: none;">
                <input id="t3" name="search3" value="source" type="checkbox">
                <label for="t3">&nbsp;anteckningar</label>&nbsp;
              </span>
              <span class="glue">
                <input id="t4" name="search4" value="album" checked="" type="checkbox">
                <label for="t4">&nbsp;albumnamn</label>&nbsp;
              </span>
              <span class="glue">
                <input id="t5" name="search5" value="name" checked="" type="checkbox">
                <label for="t5">&nbsp;bildnamn</label>
              </span>
            </div>
            <div class="orAnd">Om blank ska sökas: skriv % (åtskiljer ej) &nbsp; &nbsp;
                <a class="hoverDark" style="font-family:sans-serif;font-variant:all-small-caps" tabindex="-1" {{on 'click' (fn this.z.toggleDialog 'dialogFindHelp')}}>{{t 'searchHelp'}}</a>
              <br>Välj regel för åtskilda ord/textbitar/sökbegrepp:<br>
              <span class="glue">
                <input id="r1" name="searchmode" value="AND" checked="" type="radio">
                <label for="r1">&nbsp;alla&nbsp;ska&nbsp;hittas&nbsp;i&nbsp;en&nbsp;bild</label>
              </span>&nbsp;
              <span class="glue">
                <input id="r2" name="searchmode" value="OR" type="radio">
                <label for="r2">&nbsp;minst&nbsp;ett&nbsp;av&nbsp;dem&nbsp;ska&nbsp;hittas&nbsp;i&nbsp;en&nbsp;bild</label>
              </span>
            </div>
          </div>
        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.findit)}}>{{t 'button.findIn'}} <b>{{this.z.imdbRoot}}</b></button>&nbsp;
          <button type="button" {{on 'click' (fn this.z.closeDialog dialogFindId)}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

      <dialog id='dialogFindHelp'>
        <header data-dialog-draggable >
          <p>&nbsp;</p>
          <p>{{t 'write.findHelpHeader'}} <span></span></p>
          <button class="close" type="button" {{on 'click' (fn this.z.closeDialog 'dialogFindHelp')}}>×</button>
        </header>
        <main style="padding:0 0.5rem 0 1rem;width: min(calc(100vw - 2rem),450px)">
          <p style="padding-top:0.3em"><strong>Sök i bildtexter &ndash; så här fungerar det</strong> <br> </p>
          <p>
            <span>Sök i</span>-raden används för att markera vilka textfält som tillsammans ska ingå i sökningen. Tips: Ta reda på hur många bilder det finns i en albumsamling genom att söka efter ett ’/’!
          </p>
          <p>
            <span>I nedersta raden</span> kan du bara välja ett av två alternativ:
          </p>
          <p>
            <span>1</span>. Du markerar att <span>alla ska hittas...</span> och skriver sedan i textrutan ovanför till exempel (blåmarkerat):
            <br>
            <span>nils jacobss</span> (två sökbegrepp) som hittar alla bilder med text ’Nils Jacobsson’ men även andra bilder med både ’Nils’ och ’Jacobss’ i texten, till exempel ’Nils Jonasson och Bertil Jacobsson’<br>
            <span>nils%jacobs</span> (ett sökbegrepp) som hittar bilder med till exempel ’Nils Jacobsson’ eller ’Nils Jacobsen’
          </p>
          <p>
            <span>2</span>. Du markerar att <span>minst ett av dem ska hittas...</span> och skriver till exempel:
            <br>
            <span>nils jacobss</span> (två sökbegrepp) hittar alla bilder med text ’Nils Jacobsson’ och även alla bilder med någon av ’Nils’ och ’Jacobss’ i texten, till exempel ’Fredrik Nilson’ och/eller ’Filip Jacobsson’ (men inte ’Nisse Jacobson’)<br>
            <span>nils%jacobs</span> (ett sökbegrepp) hittar bilder med till exempel ’Nils Jacobsson’ eller ’Nils Jacobsen’ i texten (på samma sätt som i <span>1</span>.)
          </p>
          <p>
            Skriv det du vill söka i rutan överst och starta sökningen. Resultatet presenteras i ett album för tillfälligt bruk som heter <b>Funna bilder</b> med länk till originalet i varje bilds meny. <span style="color:#0b0;text-decoration:underline">Grön kant under bildtexten</span> betyder länkad bild.
          </p>
        </main>
        <footer data-dialog-draggable>
          <button type="button" {{on 'click' (fn this.z.closeDialog 'dialogFindHelp')}}>{{t 'button.close'}}</button>&nbsp;
        </footer>
      </dialog>

    </div>

  </template>
}
