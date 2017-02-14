$(document).on('init:paymentMethodSelector.nearme', () => {
  const els = $('[data-payment-methods]');
  if (els.size()) {
    require.ensure('../../shared/payment_methods/payment_method_selector', (require) => {
      let PaymentMethodSelector = require('../../shared/payment_methods/payment_method_selector');
      els.each((index, el) => new PaymentMethodSelector(el));
    });
  }
}).trigger('init:paymentMethodSelector.nearme');

