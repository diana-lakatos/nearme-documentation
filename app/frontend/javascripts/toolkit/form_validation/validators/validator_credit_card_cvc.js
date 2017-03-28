// @flow

const payform = require('payform');
const Validator = require('../validator');
const DEFAULT_MESSAGE = 'Invalid CVC code';

class ValidatorCreditCardCVC extends Validator {
  run(value: string): Promise<mixed> {
    if (payform.validateCardCVC(value)) {
      return Promise.resolve();
    }
    return Promise.reject(this.getMessage());
  }

  defaultMessage(): string {
    return DEFAULT_MESSAGE;
  }
}

module.exports = ValidatorCreditCardCVC;
