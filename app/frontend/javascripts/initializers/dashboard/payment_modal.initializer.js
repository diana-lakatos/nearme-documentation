$(document).on('init:paymentmodal.nearme', function(){
  require.ensure('../../sections/dashboard/payment_modal_controller', function(require){
    var PaymentModalController = require('../../sections/dashboard/payment_modal_controller');
    new PaymentModalController($('.dialog'));

    $(document).trigger('init:creditcardform.nearme');
  });
});
