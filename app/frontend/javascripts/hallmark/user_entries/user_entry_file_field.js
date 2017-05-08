// @flow

import Eventable from '../../toolkit/eventable';
import { closest } from '../../toolkit/dom';
import {
  getImageTypeFromArrayBuffer,
  base64ArrayBuffer,
  getImageOrientationFromArrayBuffer
} from '../../toolkit/array_buffer';

type ImageDataType = {
  dataUrl: string,
  orientation: number
};

class UserEntryFileField extends Eventable {
  input: HTMLInputElement;
  form: HTMLFormElement;
  reader: FileReader;
  imageData: ImageDataType;

  constructor(input: HTMLInputElement) {
    super();

    this.input = input;
    let form = closest(this.input, 'form');
    if (!(form instanceof HTMLFormElement)) {
      throw new Error('Unable to find form element for user entry file field');
    }
    this.form = form;

    this.reader = new FileReader();
    this.imageData = {
      dataUrl: '',
      orientation: 0
    };
    this.bindEvents();
  }

  bindEvents() {
    this.input.addEventListener('change', this.update.bind(this));
    this.reader.onload = this.parse.bind(this);
  }

  parse() {
    let buffer: ArrayBuffer = this.reader.result;

    let fileType: string =
      getImageTypeFromArrayBuffer(buffer) || this.input.files[0].type;

    let url = `data:${fileType};base64,${base64ArrayBuffer(buffer)}`;
    this.imageData = {
      dataUrl: url,
      orientation: getImageOrientationFromArrayBuffer(buffer)
    };
    this.emit('change', this.imageData);
  }

  update() {
    if (this.input.files.length > 0) {
      this.reader.readAsArrayBuffer(this.input.files[0]);
      return;
    }
    this.imageData = {
      dataUrl: '',
      orientation: 0
    };
    this.emit('empty');
  }

  getImageData(): ImageDataType {
    return this.imageData;
  }

  empty() {
    this.input.value = '';
  }
}

module.exports = UserEntryFileField;
