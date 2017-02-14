const Events = require('minivents/dist/minivents.commonjs');
const closest = require('../toolbox/closest');
const getImageOrientationFromArrayBuffer = require('../toolbox/get_image_orientation_from_array_buffer');
const base64ArrayBuffer = require('../toolbox/base64_array_buffer');
const getImageTypeFromArrayBuffer = require('../toolbox/get_image_type_from_array_buffer');

class UserEntryFileField {
  constructor(input) {
    Events(this);

    this.ui = {};
    this.ui.input = input;
    this.ui.form = closest(input, 'form');

    this.reader = new FileReader();
    this.imageData = {};
    this.bindEvents();
  }

  bindEvents() {
    this.ui.input.addEventListener('change', this.update.bind(this));
    this.reader.onload = this.parse.bind(this);
  }

  parse() {
    let buffer = this.reader.result;

    let fileType = getImageTypeFromArrayBuffer(buffer) || this.ui.input.files[0].type;

    let url = `data:${fileType};base64,${base64ArrayBuffer(buffer)}`;
    this.imageData = {
      dataUrl: url,
      orientation: getImageOrientationFromArrayBuffer(buffer),
    };
    this.emit('change', this.imageData);
  }

  update() {
    if (this.ui.input.files.length > 0) {
      return this.reader.readAsArrayBuffer(this.ui.input.files[0]);
    }
    this.imageData = {};
    this.emit('empty');
  }

  getImageData() {
    return this.imageData;
  }

  empty() {
    this.ui.input.value = '';
  }
}

module.exports = UserEntryFileField;
