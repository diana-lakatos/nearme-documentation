var els = $('.order_shipments_shipping_rule_id');
if (els.length > 0) {
  require.ensure('../../sections/checkout/delivery_controller', function(require){
    var DeliveryController = require('../../sections/checkout/delivery_controller');
    els.closest('section[data-form-component-name]').each(function(){
      return new DeliveryController(this);
    });
  });
}
