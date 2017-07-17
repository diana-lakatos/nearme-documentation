var OrderItemsController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

OrderItemsController = function() {
  function OrderItemsController(el) {
    this.calculateTotal = bind(this.calculateTotal, this);
    this.calculateSubTotal = bind(this.calculateSubTotal, this);
    this.container = $(el);

    /*
     * @hour_inputs = @container.find('[data-quantity-input]')
     * @unit_price_input = @container.find('[data-price-input]')
     */
    this.allSubtotals = function(_this) {
      return function() {
        return _this.container.find('[data-subtotal]');
      };
    }(this);
    this.total = this.container.find('.total .amount');
    this.bindEvents();
  }

  OrderItemsController.prototype.bindEvents = function() {
    this.calculateTotal();
    this.container.on(
      'change',
      '[data-quantity-input]',
      function(_this) {
        return function(event) {
          _this.convertToPositive(event.target);
          return _this.calculateSubTotal($(event.target));
        };
      }(this)
    );
    this.container.on(
      'change',
      '[data-price-input]',
      function(_this) {
        return function(event) {
          _this.convertToPositive(event.target);
          return _this.calculateSubTotal($(event.target));
        };
      }(this)
    );
    this.container.on(
      'cocoon:before-remove',
      '.nested-fields-set',
      function(_this) {
        return function(e, fields) {
          $(fields).find('[data-subtotal]').data('amount', '0');
          return _this.calculateTotal();
        };
      }(this)
    );
    return this.container.on(
      'cocoon:after-insert',
      '.nested-fields-set',
      function(_this) {
        return function() {
          return _this.calculateTotal();
        };
      }(this)
    );
  };

  OrderItemsController.prototype.convertToPositive = function(target) {
    target.value = (Math.abs(parseFloat(target.value)) || 0);
  };

  OrderItemsController.prototype.calculateSubTotal = function(target) {
    var fieldset, newPrice, price, quantity, subtotalField;
    fieldset = target.parents('.nested-fields');
    if (fieldset.find('[data-price-input]').length > 0) {
      price = parseFloat(fieldset.find('[data-price-input]').val());
    } else {
      price = 0;
    }
    if (fieldset.find('[data-quantity-input]').length > 0) {
      quantity = parseFloat(fieldset.find('[data-quantity-input]').val());
    } else {
      quantity = 0;
    }
    newPrice = quantity * price;
    subtotalField = fieldset.find('[data-subtotal]');
    subtotalField.text('' + subtotalField.data('currency') + newPrice.toFixed(2));
    subtotalField.data('amount', newPrice.toFixed(2));
    return this.calculateTotal();
  };

  OrderItemsController.prototype.calculateTotal = function() {
    var i, len, ref, subtotal, totalPrice;
    totalPrice = 0;
    ref = this.allSubtotals();
    for (i = 0, len = ref.length; i < len; i++) {
      subtotal = ref[i];
      totalPrice += parseFloat($(subtotal).data('amount'));
    }
    return this.total.text('' + this.total.data('currency') + totalPrice.toFixed(2));
  };

  return OrderItemsController;
}();

module.exports = OrderItemsController;
