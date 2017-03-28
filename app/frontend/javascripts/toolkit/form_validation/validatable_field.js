//@flow
import Validator from './validator';
import { closest } from '../dom';
const validatorFactory = require('./validator_factory');

const defaults = {
  wrapperClass: '.form-group, .control-group'
};

class ValidatableField {
  validators: Array<Validator>;
  field: HTMLTextAreaElement | HTMLInputElement | HTMLSelectElement;
  wrapper: HTMLElement;
  controls: ?HTMLElement;

  constructor(field: HTMLTextAreaElement | HTMLInputElement | HTMLSelectElement, validations: Array<validatorFactoryOptions>, options: { wrapperClass?: string } = {}) {
    this.field = field;

    options = Object.assign({}, defaults, options);

    let wrapper = closest(field, options.wrapperClass);
    if (!(wrapper instanceof HTMLElement)) {
      throw new Error('Unable to locate field wrapper');
    }
    this.wrapper = wrapper;

    /* TODO: REMOVE AFTER SIMPLE_FORM CLEANUP */
    let controls = wrapper.querySelector('.controls');
    if (controls instanceof HTMLElement) {
      this.controls = controls;
    }

    this.setup(validations)
        .then((validators) => {
          this.validators = validators;
          this.bindEvents();
        });
  }

  setup(validations: Array<validatorFactoryOptions>): Promise<Array<Validator>> {

    let ps: Array<Promise<Validator>> = [];

    validations.forEach((validation: validatorFactoryOptions) => {
      ps.push(validatorFactory(validation));
    });

    return Promise.all(ps);
  }

  bindEvents() {
    this.field.addEventListener('change', () => {
      this.process();
    });
  }

  process(): Promise<mixed> {
    this.removeError();

    return new Promise((resolve) => {
      Promise.all(this.validators.map( (validator: Validator): Promise<mixed> => validator.process(this.field.value) ))
        .then(() => {
          resolve();
        })
        .catch((error: string) => {
          this.addError(error);
        });
    });
  }

  addError(message: string) {
    this.wrapper.classList.add('error', 'has-error'); // TODO: When deprecating, use one class only
    let err = document.createElement('span');
    err.classList.add('help-block', 'error-block'); // TODO: When deprecating, use single class only
    err.innerHTML = message;

    let container = this.controls || this.wrapper;

    container.appendChild(err);
  }

  removeError() {
    this.wrapper.classList.remove('error', 'has-error'); // TODO: When deprecating, use one class only

    let errorMessage = this.wrapper.querySelector('span.help-block'); // TODO: This should be refactored and configurable
    if (errorMessage && errorMessage.parentNode instanceof HTMLElement) {
      errorMessage.parentNode.removeChild(errorMessage);
    }
  }
}

module.exports = ValidatableField;
