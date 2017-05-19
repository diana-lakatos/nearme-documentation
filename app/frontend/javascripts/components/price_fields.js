/*
 * Wrapper for the price fields - daily_price, weekly_price and monthly_price.
 *
 */
var PriceFields;

PriceFields = function() {
  function PriceFields(container) {
    this.container = container;
    this.enablingPriceCheckboxes = this.container.find('input[data-behavior*=enable-price]');
    this.freeCheckbox = this.container.find('input[data-behavior*=toggle-free]');
    this.inputWrapper = this.container.find('.price-input-options');
    this.priceFields = this.container.find('input[data-type=price-input]');
    this.bindEvents();
    this.enablingPriceCheckboxes.trigger('change');
  }

  PriceFields.prototype.show = function() {
    this.inputWrapper.show();
    return this.inputWrapper
      .find('input.hide-disabled:disabled')
      .removeClass('hide-disabled')
      .prop('disabled', false);
  };

  PriceFields.prototype.hide = function() {
    this.inputWrapper.hide();
    return this.inputWrapper
      .find('input:not(:disabled)')
      .addClass('hide-disabled')
      .prop('disabled', true);
  };

  PriceFields.prototype.bindEvents = function() {
    this.container.closest('form').on(
      'submit',
      function(_this) {
        return function() {
          return _this.inputWrapper.find('input[readonly]').prop('disabled', true);
        };
      }(this)
    );
    this.enablingPriceCheckboxes.change(
      function(_this) {
        return function(event) {
          var checkbox;
          checkbox = $(event.target);
          checkbox
            .parents('.price-containter')
            .find('input[data-type*=price-input]')
            .attr('readonly', !checkbox.is(':checked'));

          /*
         * Free enabled if all prices are disabled
         */
          return _this.freeCheckbox.prop('checked', !_this.enablingPriceCheckboxes.is(':checked'));
        };
      }(this)
    );
    this.freeCheckbox.click(
      function(_this) {
        return function() {
          _this.enablingPriceCheckboxes.prop('checked', !_this.freeCheckbox.is(':checked'));
          return _this.enablingPriceCheckboxes.trigger('change');
        };
      }(this)
    );
    this.priceFields.on('click', function(event) {
      var checkbox;
      checkbox = $(event.target)
        .parents('.price-containter')
        .find('label')
        .find('input[data-behavior*=enable-price]');
      checkbox.prop('checked', true);
      checkbox.trigger('change');

      /*
       * yeah well.. otherwise IE will think that input is readable, even though we have just changed this...
       */
      return $(event.target).select();
    });
    this.priceFields.on('blur', function(event) {
      var checkbox;
      if ($(event.target).val() === '') {
        checkbox = $(event.target).siblings('label').find('input[data-behavior*=enable-price]');
        checkbox.prop('checked', false);
        return checkbox.trigger('change');
      }
    });
    return this.priceFields.on('change', function(event) {
      var price;
      price = $(event.target);
      return price.val(price.val().replace(/[^0-9\.]/, ''));
    });
  };

  return PriceFields;
}();

module.exports = PriceFields;
