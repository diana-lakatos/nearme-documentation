var InstanceAdminPaymentGatewaySelect;

InstanceAdminPaymentGatewaySelect = function() {
  function InstanceAdminPaymentGatewaySelect(select) {
    $(select).on('change', function() {
      $('.payment-gateways-form').html('Loading...');
      return $(this).submit();
    });
  }

  return InstanceAdminPaymentGatewaySelect;
}();

module.exports = InstanceAdminPaymentGatewaySelect;
