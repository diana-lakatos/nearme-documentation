var run = function() {
  require.ensure('jquery.payment', function(require){
    require('jquery.payment');
    $('input[data-card-number]').eq(0).payment('formatCardNumber');
    $('input[data-card-code]').eq(0).payment('formatCardCVC');
  });
};

$(document).on('init:creditcardform.nearme', run);

if ($('input[data-card-number], input[data-card-code]').length > 0) {
  run();
}
