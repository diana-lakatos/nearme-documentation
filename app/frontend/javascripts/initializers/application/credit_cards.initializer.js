function run(){

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

$(document).on('init:creditcardform.nearme', run);
