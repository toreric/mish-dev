import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

let rnd = "." + Math.random().toString(36).substring(2,6);

export default class CommonStorageService extends Service {

  @tracked bkgrColor = '#cbcbcb';
  @tracked credentials = '';
  @tracked imageId = 'IMG_1234a_2023_november_19';
  @tracked imdbDir = "/album";
  @tracked imdbRoot = "MISH";
  @tracked picFound = "Funna_bilder" + rnd;
  @tracked credentials = '';
  @tracked userName = 'viewer';

  loli(text) { // loli = log list
    console.log(this.userName + ':', text);
  }

}

