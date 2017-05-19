var CompleteReservationController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

CompleteReservationController = function() {
  function CompleteReservationController(el) {
    this.calculateTotal = bind(this.calculateTotal, this);
    this.calculateSubTotal = bind(this.calculateSubTotal, this);
    this.container = $(el);
    this.hour_inputs = this.container.find('[data-hours-input]');
    this.allSubtotals = function(_this) {
      return function() {
        return _this.container.find('[data-subtotal]');
      };
    }(this);
    this.total = this.container.find('.total .amount');
    this.bindEvents();
  }

  CompleteReservationController.prototype.bindEvents = function() {
    this.calculateTotal();
    this.container.on(
      'change',
      '[data-hours-input]',
      function(_this) {
        return function(event) {
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

  CompleteReservationController.prototype.calculateSubTotal = function(target) {
    var fieldset, newPrice, rate, subtotalField;
    fieldset = target.parents('.nested-fields');
    if (fieldset.find('.rate').length > 0) {
      rate = parseInt(fieldset.find('.rate').data('amount')) / 100;
    } else {
      rate = 1;
    }
    newPrice = parseFloat(target.val()) * rate;
    subtotalField = fieldset.find('[data-subtotal]');
    subtotalField.text('' + subtotalField.data('currency') + newPrice.toFixed(2));
    subtotalField.data('amount', newPrice.toFixed(2));
    return this.calculateTotal();
  };

  CompleteReservationController.prototype.calculateTotal = function() {
    var i, len, ref, subtotal, totalPrice;
    totalPrice = 0;
    ref = this.allSubtotals();
    for (i = 0, len = ref.length; i < len; i++) {
      subtotal = ref[i];
      totalPrice += parseFloat($(subtotal).data('amount'));
    }
    return this.total.text('' + this.total.data('currency') + totalPrice.toFixed(2));
  };

  return CompleteReservationController;
}();

module.exports = CompleteReservationController;
