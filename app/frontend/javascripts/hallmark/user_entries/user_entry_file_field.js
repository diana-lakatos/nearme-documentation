const Events = require('minivents/dist/minivents.commonjs');
const closest = require('../toolbox/closest');

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
    this.reader.onload = () => {
      this.imageData = {
        dataUrl: this.reader.result
      };
      this.emit('change', this.imageData);
    };
  }

  update() {

    if (this.ui.input.files.length > 0) {
      return this.reader.readAsDataURL(this.ui.input.files[0]);
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
