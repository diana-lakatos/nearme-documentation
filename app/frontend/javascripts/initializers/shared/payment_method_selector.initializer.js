function run(){
  let els = document.querySelectorAll('[data-payment-methods]');
  if (els.length === 0) {
    return;
  }
  require.ensure('../../shared/payment_methods/payment_method_selector', (require)=>{
    let PaymentMethodSelector = require('../../shared/payment_methods/payment_method_selector');

    Array.prototype.forEach.call(els, function(el){
      return new PaymentMethodSelector(el);
    });
  });
}

$(document).on('init:paymentMethodSelector.nearme', run);

run();
