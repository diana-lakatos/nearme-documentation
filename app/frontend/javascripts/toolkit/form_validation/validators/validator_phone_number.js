// @flow
const Validator = require('../validator');
const DEFAULT_MESSAGE = 'Invalid phone number';

class ValidatorRequired extends Validator {
  run(value: string): Promise<mixed> {
    if (/^[+]?[\d \-()]+$/.test(value)) {
      return Promise.resolve();
    }
    return Promise.reject(this.getMessage());
  }

  defaultMessage(): string {
    return DEFAULT_MESSAGE;
  }
}

module.exports = ValidatorRequired;
