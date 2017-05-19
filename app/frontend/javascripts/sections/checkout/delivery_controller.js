var DeliveryController;

DeliveryController = function() {
  function DeliveryController(el) {
    this.container = $(el);
    this.shipping_rule = this.container.find('.order_shipments_shipping_rule_id input');
    this.shipping_address = this.container.find('[data-shipping-address]');
    this.toggleFields(this.shipping_rule.filter(':checked'));
    this.bindEvents();
  }

  DeliveryController.prototype.bindEvents = function() {
    return this.shipping_rule.on(
      'change',
      function(_this) {
        return function(e) {
          return _this.toggleFields($(e.target));
        };
      }(this)
    );
  };

  DeliveryController.prototype.toggleFields = function(element) {
    if (element.data('is-pickup') === true) {
      this.shipping_address.hide();
      return this.shipping_address.find('select, input, checkbox').prop('disabled', true);
    } else {
      this.shipping_address.show();
      return this.shipping_address.find('select, input, checkbox').prop('disabled', false);
    }
  };

  return DeliveryController;
}();

module.exports = DeliveryController;
