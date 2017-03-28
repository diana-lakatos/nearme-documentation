// @flow

// This is required by flowtype
import Validator from './validator';

function validatorFactory({ type, message, condition }: validatorFactoryOptions = {}): Promise<Validator> {
  return new Promise((resolve) => {

    switch (type) {
    case 'required':
      require.ensure('./validators/validator_required', (require) => {
        const ValidatorRequired = require('./validators/validator_required');
        resolve(new ValidatorRequired(message, condition));
      });
      return;

    case 'credit_card_number':
      require.ensure('./validators/validator_credit_card_number', (require) => {
        const ValidatorCreditCardNumber = require('./validators/validator_credit_card_number');
        resolve(new ValidatorCreditCardNumber(message, condition));
      });
      return;

    case 'credit_card_cvc':
      require.ensure('./validators/validator_credit_card_cvc', (require) => {
        const ValidatorCreditCardCVC = require('./validators/validator_credit_card_cvc');
        resolve(new ValidatorCreditCardCVC(message, condition));
      });
      return;

    case 'credit_card_expiration':
      require.ensure('./validators/validator_credit_card_expiration', (require) => {
        const ValidatorCreditCardExpiration = require('./validators/validator_credit_card_expiration');
        resolve(new ValidatorCreditCardExpiration(message, condition));
      });
      return;

    case 'bank_account_number':
      require.ensure('./validators/validator_bank_account_number', (require) => {
        const ValidatorBankAccountNumber = require('./validators/validator_bank_account_number');
        resolve(new ValidatorBankAccountNumber(message, condition));
      });
      return;

    case 'bank_routing_number':
      require.ensure('./validators/validator_bank_routing_number', (require) => {
        const ValidatorBankRoutingNumber = require('./validators/validator_bank_routing_number');
        resolve(new ValidatorBankRoutingNumber(message, condition));
      });
      return;

    case 'phone_number':
      require.ensure('./validators/validator_phone_number', (require) => {
        const ValidatorPhoneNumber = require('./validators/validator_phone_number');
        resolve(new ValidatorPhoneNumber(message, condition));
      });
      return;
    }

    throw new TypeError(`Unsupported validation type ${type}`);
  });
}

module.exports = validatorFactory;
