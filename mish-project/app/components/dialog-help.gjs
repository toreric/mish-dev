//== Mish dialog with help text

import Component from '@glimmer/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

// Note: Dialog functions in ButtonsLeft needs dialogHelpId:
export const dialogHelpId = "dialogHelp";

export class DialogHelp extends Component {
  @service('common-storage') z;

  // Detect closing Esc key
  @action
  detectEscClose(e) {
    e.stopPropagation();
    if (e.keyCode === 27) { // Esc key
      if (document.getElementById(dialogHelpId).open) this.z.closeDialog(dialogHelpId);
    }
  }

<template>

<dialog id="dialogHelp" {{on 'keydown' this.detectEscClose}}>
  <header data-dialog-draggable>
    <div style="width:99%">
      <p>{{t 'dialog.help.header'}}<br>{{t 'dialog.help.header1'}}<span></span></p>
    </div><div>
      <button class="close" type="button" {{on 'click' (fn this.z.closeDialog dialogHelpId)}}>×</button>
    </div>
  </header>
  <main>
      <p style="text-align:left;margin:-0.9rem 0 0 1.5rem;line-height:1.7em" draggable="false" ondragstart="return false"><br>

        <span style="font-size:0.95em"><b>{{t 'dialog.help.ihrcm0'}}</b> {{t 'dialog.help.ihrcm1'}}<b>{{t 'dialog.help.ctrlclick'}}</b> {{t 'dialog.help.ihrcm2'}}<br>

        <b>{{t 'dialog.help.shift0'}}</b> {{t 'dialog.help.shift1'}}<br>

        <b>{{t 'dialog.help.login0'}}</b> {{t 'dialog.help.login1'}}<br>

        <b style="color:#0b0">{{t 'dialog.help.green0'}}</b> {{t 'dialog.help.green1'}} <span style="color:white;background:#0b0">&nbsp;{{t 'goto'}}&nbsp;</span>{{t 'dialog.help.green2'}}</span>
      </p>
      <p style="text-align:left;margin-left:1.5rem;line-height:1.7rem" draggable="false" ondragstart="return false">
        <b>{{t 'dialog.help.flebu'}}</b> ({{t 'dialog.help.wviva'}}):<br>

        <a id="albSel" class="helpIcon">☰</a> {{t 'dialog.help.mmenu'}}<br>

        <a id="questionMark0" class="helpIcon">?</a> Visa/dölj den här användarhandledningen<br>

        <a id="reFr0" class="helpIcon"><img draggable="false" ondragstart="return false" src="/images/reload.png"></a> Ladda om albumet, återställ eventuella osparade ändringar (’ångerknapp’ men <span>avser ej textändringar</span>)¹ ²<br>

        <a id="toggleName0" class="helpIcon">N</a> Visa/dölj namn på bilden (filnamn utan .filtyp)<br>

        <a id="toggleHide0" class="helpIcon"></a> Visa/dölj ’gömda bilder’ (gömda med bildens högerklick-meny)<br>

        <a id="saveOrder0" class="helpIcon">S</a> Spara bildändringar¹ som annars är tillfälliga och kan återställas²<br>

        <a id="do_mail0" class="helpIcon" src="/images/mail.svg"></a> Skicka fråga eller annat meddelande till albumadministratören<br>

        <a class="helpIcon">↑</a> Gå upp till överst på sidan
      </p>
      <p style="text-align:left;margin:-0.4em 0 0 3em;line-height:1.5em" draggable="false" ondragstart="return false">
        ¹ Ändringar är: Dra-och-släpp-flyttning av miniatyrbilder, göm eller visa med högerklick<br>

        ² Återställning kan också ibland förbättra ofullständig bildvisning
      </p>
      <p style="text-align:left;margin-left:1.5em;line-height:1.5em" draggable="false" ondragstart="return false">
        <b>Övriga knappar</b>: Utforska på egen hand! Och använd <b>Esc-tangenten</b> (se nedan)!
      </p>
      <p style="text-align:left;margin-left:1.5em;line-height:1.5em" draggable="false" ondragstart="return false">
        <b>Tangentbordet</b>:<br>

        <b>F1</b> visar/döljer den här användarhandledningen<br>

        <b>Ctrl</b>+<b class="large">+</b> och <b>Ctrl</b>+<b class="large">&minus;</b> ökar respektive minskar bildstorleken och <b>Ctrl</b>+<b class="large">0</b> (noll) återställer<br>

        <b>F11</b> används för att börja eller avbryta helskärmsvisning<br>

        <b>Högerpil</b>- eller <b>vänsterpiltangenten</b> växlar bild framåt eller bakåt<br>

        <b>A</b>-tangenten startar automatisk bildväxling &ndash; Esc-tangenten avbryter<br>

        <b>F</b>-tangenten öppnar ’Finn bilder’ (sökfönstret) &ndash; Esc-tangenten stänger det<br>

        <b>Esc</b> är avslutnings- och avbrottstangent för bildväxling, informationsfönster m.m.<br>

        <b>F5</b> eller <b>Ctrl</b>+<b>R</b> används för att börja om från början, till exempel om bildväxlingen kommit i oordning</p>
  </main>
  <footer data-dialog-draggable>
    <button type="button" {{on 'click' (fn this.z.closeDialog dialogHelpId)}}>{{t 'button.close'}}</button>&nbsp;
  </footer>
</dialog>

</template>
}
