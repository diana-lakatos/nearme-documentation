// @flow

const ValidatableField = require('./validatable_field');

class ValidatableFieldCollection {
  fields: Array<ValidatableField>;
  constructor() {
    this.fields = [];
  }

  addField(
    el: HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement,
    validations: Array<validatorFactoryOptions>
  ) {
    this.fields.push(new ValidatableField(el, validations));
  }

  process(): Promise<*> {
    return Promise.all(this.fields.map((field: ValidatableField): Promise<*> => field.process()));
  }
}

module.exports = ValidatableFieldCollection;
