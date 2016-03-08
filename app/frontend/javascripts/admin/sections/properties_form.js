var HTMLOptionsInput = require('../modules/forms/custom_inputs/html_options_input');
var CSVInput = require('../modules/forms/custom_inputs/csv_input');

class PropertiesForm {
  constructor(form) {
    this.form = form;

    this.typeSwitcher = this.form.querySelector('select[data-type-select]');
    this.typeOptions = {};

    Array.prototype.forEach.call(this.form.querySelectorAll('.property-form-options fieldset'), (el) => {
      this.typeOptions[el.dataset.type] = el;
    });

    this.bindEvents();

    Array.prototype.forEach.call(this.form.querySelectorAll('[data-html-options]'), (el)=> new HTMLOptionsInput(el));
    Array.prototype.forEach.call(this.form.querySelectorAll('[data-csv-input]'), (el)=> new CSVInput(el));
        // initialize
    this.changeOptions();
  }
  bindEvents() {
    this.typeSwitcher.addEventListener('change', this.changeOptions.bind(this));
  }
  changeOptions() {
    let current = this.typeSwitcher.value;

    for (let type in this.typeOptions) {
      if (current === type) {
        this.typeOptions[type].classList.add('active');
      }
      else {
        this.typeOptions[type].classList.remove('active');
      }
    }
  }
}

module.exports = PropertiesForm;
