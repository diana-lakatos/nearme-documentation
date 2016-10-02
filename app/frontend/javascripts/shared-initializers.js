let initializers = [];

/* Credit cards form */
initializers.push(()=>{
  function run(event, stripe, pubKey){
    let els = document.querySelectorAll('.nm-credit-card-fields');
    if (els.length === 0) {
      return;
    }
    require.ensure('shared/payment_methods/credit_card', (require)=>{
      let PaymentMethodCreditCard = require('shared/payment_methods/credit_card');

      Array.prototype.forEach.call(els, function(el){
        return new PaymentMethodCreditCard(el);
      });
    });
  }

  $(document).on('init:paymentMethodCreditCard.nearme', run);

  run();
});

module.exports = initializers;
