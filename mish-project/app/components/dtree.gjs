
// const d = new dTree('this.dd');
// d.add(0,-1,'My example tree');
// d.add(1,0,'Node 1','example01.html');
// d.add(2,0,'Node 2','example01.html');
// d.add(3,1,'Node 1.1','example01.html');
// d.add(4,0,'Node 3','example01.html');
// d.add(5,3,'Node 1.1.1','example01.html');
// d.add(6,5,'Node 1.1.1.1','example01.html');
// d.add(7,0,'Node 4','example01.html');
// d.add(8,1,'Node 1.2','example01.html');
// d.add(9,0,'My Pictures','example01.html','Pictures I\'ve taken over the years','','','img/imgfolder.gif');
// d.add(10,9,'The trip to Iceland','example01.html','Pictures of Gullfoss and Geysir');
// d.add(11,9,'Mom\'s birthday','example01.html');
// d.add(12,0,'Recycle Bin','example01.html','','','img/trash.gif');
// console.log(d.toString());

import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { inject as service } from '@ember/service';
import { htmlSafe } from '@ember/template';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import t from 'ember-intl/helpers/t';

export class DTree extends Component {
  @service('common-storage') z;
  @service intl;
  @tracked d = new this.z.dTree('this.d');

  get tree() {
    this.d.add(0,-1,'My example tree');
    this.d.add(1,0,'Node 1','example01.html');
    this.d.add(2,0,'Node 2','example01.html');
    this.d.add(3,1,'Node 1.1','example01.html');
    this.d.add(4,0,'Node 3','example01.html');
    this.d.add(5,3,'Node 1.1.1','example01.html');
    this.d.add(6,5,'Node 1.1.1.1','example01.html');
    this.d.add(7,0,'Node 4','example01.html');
    this.d.add(8,1,'Node 1.2','example01.html');
    this.d.add(9,0,'My Pictures','example01.html','Pictures I\'ve taken over the years','','','img/imgfolder.gif');
    this.d.add(10,9,'The trip to Iceland','example01.html','Pictures of Gullfoss and Geysir');
    this.d.add(11,9,'Mom\'s birthday','example01.html');
    this.d.add(12,0,'Recycle Bin','example01.html','','','img/trash.gif');

    var a = this.d.toString();
    console.log(a);
    return a;
  }

  <template>

    <div>{{htmlSafe this.tree}}</div>
    {{!-- <button type="button" {{on 'click' (fn this.tree)}}>OK-BUTTON</button> --}}

  </template>
}
