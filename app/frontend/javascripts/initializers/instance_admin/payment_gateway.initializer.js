$('.payment-gateway-select').on('change', function(){
  $('.instance-payment-gateway-form').html('Loading...');
  $(this).submit();
});


var el = $('#payment-gateways .country-select');
if (el.length > 0) {
  require.ensure('../../instance_admin/sections/payment_gateway_select', function(require){
    var InstanceAdminPaymentGatewaySelect = require('../../instance_admin/sections/payment_gateway_select');
    return new InstanceAdminPaymentGatewaySelect(el);
  });
}

$(document).on('init:paymentgateway.nearme', function(event, container, options){
  options = options || {};
  require.ensure('../../instance_admin/sections/payment_gateway_form', function(require){
    var InstanceAdminPaymentGatewayForm = require('../../instance_admin/sections/payment_gateway_form');
    return new InstanceAdminPaymentGatewayForm($(container), options);
  });
});
