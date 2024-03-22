import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';

let rnd = "." + Math.random().toString(36).substr(2,4);

export default class CommonStorageService extends Service {
  @tracked imageId = 'IMG_1234a_2023_november_19';
  @tracked imdbDir = "/album";
  @tracked imdbRoot = "MISH";
  @tracked picFound = "Funna_bilder" + rnd;
  @tracked userName = 'tore';
  @tracked credentials = '';
}

