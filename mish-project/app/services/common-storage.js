import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

let rnd = "." + Math.random().toString(36).substring(2,6);

export default class CommonStorageService extends Service {

  @tracked imageId = 'IMG_1234a_2023_november_19';
  @tracked imdbDir = "/album";
  @tracked imdbRoot = "MISH";
  @tracked picFound = "Funna_bilder" + rnd;
  @tracked credentials = '';

  @tracked   userName = '';

  setUserName(newId) {
    this.userName = newId;
    document.getElementById("userName").innerHTML = newId;
  }

  setImageId(newId) {
    this.imageId = newId;
  }



}

