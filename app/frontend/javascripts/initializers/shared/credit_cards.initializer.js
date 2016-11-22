function run(){
  let els = document.querySelectorAll('.nm-credit-card-fields');
  if (els.length === 0) {
    return;
  }
  require.ensure('../../shared/payment_methods/credit_card', (require)=>{
    let PaymentMethodCreditCard = require('../../shared/payment_methods/credit_card');

    Array.prototype.forEach.call(els, function(el){
      return new PaymentMethodCreditCard(el);
    });
  });
}

$(document).on('init:paymentMethodCreditCard.nearme', run);

run();


function applyFormatting(){

  let ccNumber = $('input[data-card-number]');
  let ccCVC = $('input[data-card-code]');

  if (ccNumber.length === 0 && ccCVC.length === 0) {
    return;
  }

  require.ensure('jquery.payment', function(require){
    require('jquery.payment');
    ccNumber.payment('formatCardNumber');
    ccCVC.payment('formatCardCVC');
  });
}

$(document).on('init:creditcardform.nearme', applyFormatting);

applyFormatting();
