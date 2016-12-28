const ValidatorRequired = require('validators/validator_required');

const ALLOWED_TYPES = [
    /* simple_form built-in types */
  'boolean',
  'string',
  'email',
  'url',
  'tel',
  'password',
  'search',
  'uuid',
  'text',
  'file',
  'hidden',
  'integer',
  'float',
  'decimal',
  'range',
  'datetime',
  'date',
  'time',
  'select',
  'radio_buttons',
  'check_boxes',
  'country',
  'time_zone',

    /* custom inputs */
  'switch',
  'price',
  'combobox',
  'code_editor'
];

const INVALID_GROUP_CLASS = 'has-error';
const FORM_ERROR_CLASS = 'form-error';

class FormComponent {
  constructor(wrapper, nmForm){
    this._ui = {};
    this._ui.wrapper = wrapper;
    this._nmForm = nmForm;
    this._state = true;
    this._errors = [];
    this._validators = [];

    this._parseName();
    this._parseType();

    this._determineValidators();
  }

  _parseName() {
    let klasses = this._ui.wrapper.className.split(' ');

    const objectNameStr = `${this._nmForm.getObjectName()}_`;

    klasses = klasses.filter((klass)=>{
      return klass.indexOf(objectNameStr) > -1;
    });
    if (klasses.length === 0) {
      throw new TypeError('Unable to determine form component name');
    }

    this._name = klasses[0].replace(objectNameStr,'');
  }

  _parseType() {
    this._ui.wrapper.className.split(' ').forEach((klass)=>{
      if (ALLOWED_TYPES.indexOf(klass) > -1) {
        this._type = klass;
      }
    });

    if (!this._type) {
      throw new TypeError(`Unable to form component type from "${this._ui.wrapper.className}"`);
    }
  }

  _determineValidators() {
        /* type validators */
    require.ensure([], (require)=>{
      let TypeValidator = require(`./validators/validator_${this._type}.js`);
      this._validators.push(new TypeValidator());
    });

        // maxlength

        // minlength

        // max

        // min

        // pattern

        // equalto
  }

  isRequired() {
    return this._ui.wrapper.classList.contains('required');
  }

  _runValidation() {
    this._errors.length = 0;
    this._state = true;

        /* Required validator is run separately from other validators,
           as we want to make sure some value exists */

    let val = this.getValue();

    if (this.isRequired()) {
      const reqVal = new ValidatorRequired();
      if (reqVal.run(val) === false) {
        this._errors.push(reqVal.getError());
        this._state = false;
        return false;
      }
    }

    if (val) {
      this._validators.forEach((validator)=>{
        if (validator.run(val) === false) {
          this._errors.push(validator.getError());
        }
      });
    }

    this._state = (this._errors.length === 0);
  }

  getValue() {
    return this._nmForm.getValue(this._name);
  }

  getName() {
    return this._name;
  }

  validate(){
    this._runValidation();
    this._refreshUI();
    return this._state;
  }

  isValid(){
    this._runValidation();
    return this._state;
  }

  focus() {
    if (!this._ui.wrapper.hasAttribute('tabindex')) {
      this._ui.wrapper.setAttribute('tabindex',0);
    }
    this._ui.wrapper.focus();
  }

  _refreshUI(){
    this._ui.wrapper.classList.remove(INVALID_GROUP_CLASS);

    Array.prototype.forEach.call(this._ui.wrapper.querySelectorAll(`.${FORM_ERROR_CLASS}`), (el)=>{
      el.parentNode.removeChild(el);
    });

    if (this._errors.length > 0) {
      this._ui.wrapper.classList.add(INVALID_GROUP_CLASS);
    }

    this._errors.forEach((message)=>{
      let error = document.createElement('strong');
      error.className = FORM_ERROR_CLASS;
      error.innerHTML = message;
      this._ui.wrapper.appendChild(error);
    });
  }

  setError(error) {
    this._errors.push(error);
    this._refreshUI();
  }
}

module.exports = FormComponent;
