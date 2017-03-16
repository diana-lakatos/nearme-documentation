// @flow
const payform = require('payform');
const Validator = require('../validator');
const DEFAULT_MESSAGE = 'Invalid credit card date';

class ValidatorCreditCardNumber extends Validator {
  run(value: string): Promise<mixed> {
    if (payform.validateCardNumber(value)) {
      return Promise.resolve();
    }
    return Promise.reject(this.getMessage());
  }

  defaultMessage(): string {
    return DEFAULT_MESSAGE;
  }
}

module.exports = ValidatorCreditCardNumber;
