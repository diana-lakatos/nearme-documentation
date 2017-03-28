// @flow
const loadExternalLibrary = require('../../load_external_library');
const Validator = require('../validator');
const DEFAULT_MESSAGE = 'Invalid bank account number';

class ValidatorBankAccountNumber extends Validator {

  run(value: string): Promise<mixed> {
    return new Promise((resolve, reject) => {
      this.loadStripe()
          .then((Stripe: Stripe) => {
            if (Stripe.bankAccount.validateAccountNumber(value, 'US')) {
              resolve();
              return;
            }
            reject(this.getMessage());
          });
    });
  }

  loadStripe(): Promise<mixed> {
    return loadExternalLibrary({ name: 'Stripe', url: 'https://js.stripe.com/v2/' });
  }

  defaultMessage(): string {
    return DEFAULT_MESSAGE;
  }
}

module.exports = ValidatorBankAccountNumber;
