$(document).on('init:creditcardform.nearme', () => {
  const els = $('input[data-card-number], input[data-card-code]');

  if (els.size()) {
    require.ensure('../../shared/payment_methods/modules/credit_card_formatter', require => {
      const CCFormatter = require('../../shared/payment_methods/modules/credit_card_formatter');
      new CCFormatter();
    });

    require.ensure('../../shared/payment_methods/modules/new_credit_card_form_toggle', require => {
      const NewCreditCardFormToggle = require(
        '../../shared/payment_methods/modules/new_credit_card_form_toggle'
      );
      new NewCreditCardFormToggle();
    });
  }
}).trigger('init:creditcardform.nearme');
