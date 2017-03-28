// @flow
const payform = require('payform');
const Validator = require('../validator');
const DEFAULT_MESSAGE = 'Invalid expiration date';

class ValidatorCreditCardExpiration extends Validator {
  run(value: string): Promise<mixed> {
    let { month, year } = payform.parseCardExpiry(value);

    if (payform.validateCardExpiry(month, year)) {
      return Promise.resolve();
    }
    return Promise.reject(this.getMessage());
  }

  defaultMessage(): string {
    return DEFAULT_MESSAGE;
  }
}

module.exports = ValidatorCreditCardExpiration;
