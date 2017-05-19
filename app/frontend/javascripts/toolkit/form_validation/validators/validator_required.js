// @flow
const Validator = require('../validator');
const DEFAULT_MESSAGE = 'Required field';

class ValidatorRequired extends Validator {
  run(value: string): Promise<mixed> {
    if (value.trim() !== '') {
      return Promise.resolve();
    }
    return Promise.reject(this.getMessage());
  }

  defaultMessage(): string {
    return DEFAULT_MESSAGE;
  }
}

module.exports = ValidatorRequired;
