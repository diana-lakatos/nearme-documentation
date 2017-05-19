/*
 * Wrapper for the price fields - daily_price, weekly_price and monthly_price.
 *
 */
var PriceFields;

PriceFields = function() {
  function PriceFields(container) {
    this.container = $(container);
    this.enablingPriceCheckboxes = this.container.find('.price-options input[data-price-enabler]');
    this.freeCheckboxes = this.container.find('input[data-free-booking]');
    this.inputWrapper = this.container.find('.price-options');
    this.priceFields = this.container.find('input[data-price-field]');
    this.currencySelect = this.container.closest('form').find('select[data-currency-symbols]');
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
    this.container.closest('form').on('submit', function(event) {
      /*
       * this is related to image uploading prevening form submission when upload is in progress
       * having this here is less than optimal but I don't have better idea on how to decouple these modules better
       * it should probably by tied in into client validation if we ever get to implement it
       */
      if ($(event.target).data('processing')) {
        return false;
      }
    });
    this.enablingPriceCheckboxes.change(
      function(_this) {
        return function(event) {
          var checkbox, free_booking_switch;
          checkbox = $(event.target);
          free_booking_switch = $(event.target).parents('.row').find('input[data-free-booking]');
          $(event.target).parents('.row').find('input[id$=_destroy]').val(!checkbox.is(':checked'));
          if (free_booking_switch.is(':checked')) {
            _this.changePriceState(checkbox, true);
          } else {
            _this.changePriceState(checkbox, !checkbox.is(':checked'));
          }
          if (!checkbox.is(':checked')) {
            return free_booking_switch.prop('checked', false);
          }
        };
      }(this)
    );
    this.freeCheckboxes.click(
      function(_this) {
        return function(event) {
          var checkbox;
          checkbox = $(event.target);
          _this.changePriceState(checkbox, checkbox.is(':checked'));
          if (checkbox.is(':checked')) {
            return $(event.target)
              .parents('.row')
              .find('input[data-price-enabler]')
              .prop('checked', true)
              .trigger('change');
          }
        };
      }(this)
    );
    this.priceFields.on(
      'click',
      function(_this) {
        return function(event) {
          $(event.target).parents('.row').find('input[data-free-booking]').prop('checked', false);
          if ($(event.target).parents('.row').find('input[data-price-enabler]').length > 0) {
            return $(event.target)
              .parents('.row')
              .find('input[data-price-enabler]')
              .prop('checked', true)
              .trigger('change');
          } else {
            return _this.changePriceState($(event.target), false);
          }
        };
      }(this)
    );
    this.priceFields.on('blur', function(event) {
      var price_enabler;
      if ($(event.target).val() === '' || $(event.target).val() === '0.00') {
        price_enabler = $(event.target).parents('.row').find('input[data-price-enabler]');
        if (price_enabler.length > 0) {
          return price_enabler.prop('checked', false).trigger('change');
        }
      }
    });
    this.priceFields.on('change', function(event) {
      var price;
      price = $(event.target);
      return price.val(price.val().replace(/[^0-9\.]/, ''));
    });
    return this.currencySelect.on(
      'change',
      function(_this) {
        return function(event) {
          var symbols, value;
          value = $(event.target).val();
          symbols = $(event.target).data('currency-symbols');
          if (value && symbols[value]) {
            return _this.priceFields
              .closest('.input-group')
              .find('.input-group-addon')
              .html(symbols[value]);
          }
        };
      }(this)
    );
  };

  PriceFields.prototype.changePriceState = function(target, state) {
    return target.parents('.row').find('input[data-price-field]').attr('readonly', state);
  };

  return PriceFields;
}();

module.exports = PriceFields;
