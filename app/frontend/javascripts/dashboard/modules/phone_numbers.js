var PhoneNumbers,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('selectize/dist/js/selectize');

/*
 * Handles the behaviour of entering country+mobile+phone fields
 * Used on the user account form, booking modal and the space setup wizard form.
 */
PhoneNumbers = function() {
  function PhoneNumbers(container, arg) {
    var interval, ref;
    this.container = container;
    ref = arg != null
      ? arg
      : {}, this.countrySelector = ref.countrySelector, this.codeSelector = ref.codeSelector, this.mobileSelector = ref.mobileSelector, this.phoneSelector = ref.phoneSelector, this.sameAsSelector = ref.sameAsSelector;
    this.updateCtcTriggerState = bind(this.updateCtcTriggerState, this);
    _.defaults(this, {
      container: $('div[data-phone-fields-container]'),
      countrySelector: 'select[data-country-selector]',
      codeSelector: '.input-group-addon',
      mobileSelector: 'input[data-mobile-number]',
      phoneSelector: 'input[data-phone]',
      sameAsSelector: 'input[data-same-as-phone-checkbox]',
      ctcTriggerSelector: 'a[data-ctc-trigger]'
    });
    if (!(this.container.length > 0)) {
      return;
    }
    this.findFields();
    this.bindEvents();
    interval = window.setInterval(
      function(_this) {
        return function() {
          if (_this.countryNameField[0].selectize) {
            window.clearInterval(interval);
            _this.updateCountryCallingCode();
            _this.updatePhoneNumber();
            return _this.updateCtcTrigger();
          }
        };
      }(this),
      50
    );
  }

  PhoneNumbers.prototype.findFields = function() {
    this.countryNameField = this.container.find(this.countrySelector);
    this.callingCodeText = this.container.find(this.codeSelector);
    this.mobileNumberField = this.container.find(this.mobileSelector);
    this.phoneNumberField = this.container.find(this.phoneSelector);
    this.sameAsPhoneField = this.container.find(this.sameAsSelector);
    return this.ctcTrigger = this.container.find(this.ctcTriggerSelector);
  };

  PhoneNumbers.prototype.bindEvents = function() {
    this.container.on(
      'change',
      this.countrySelector,
      function(_this) {
        return function() {
          return _this.updateCountryCallingCode();
        };
      }(this)
    );
    this.container.on(
      'change keyup',
      "[type='tel']",
      function(_this) {
        return function() {
          return _this.updatePhoneNumber();
        };
      }(this)
    );
    this.container.on(
      'change',
      this.sameAsSelector,
      function(_this) {
        return function() {
          return _this.updatePhoneNumber();
        };
      }(this)
    );
    this.ctcTrigger.on(
      'click',
      function(_this) {
        return function(e) {
          e.preventDefault();
          return $(document).trigger('load:dialog.nearme', [
            { url: _this.ctcTrigger.attr('href'), data: _this.ctcTrigger.data('ajax-options') },
            null,
            { onHide: _this.updateCtcTriggerState }
          ]);
        };
      }(this)
    );
    this.phoneNumberField.closest('.disabled-catch-container').find('.click-catcher').on(
      'click',
      function(_this) {
        return function() {
          var value;
          if (_this.phoneNumberField.prop('disabled')) {
            value = _this.phoneNumberField.data('disabled-field-notice');
            if (value) {
              return alert(value);
            }
          }
        };
      }(this)
    );
    return this.mobileNumberField.closest('.disabled-catch-container').find('.click-catcher').on(
      'click',
      function(_this) {
        return function() {
          var value;
          if (_this.mobileNumberField.prop('disabled')) {
            value = _this.mobileNumberField.data('disabled-field-notice');
            if (value) {
              return alert(value);
            }
          }
        };
      }(this)
    );
  };

  PhoneNumbers.prototype.updatePhoneNumber = function() {
    this.mobileNumberField.prop('readonly', !!this.isMobileSameAsPhone());
    if (this.isMobileSameAsPhone()) {
      this.mobileNumberField.val(this.phoneNumberField.val());
    }
    return this.updateCtcTrigger();
  };

  PhoneNumbers.prototype.isMobileSameAsPhone = function() {
    return this.sameAsPhoneField.is(':checked');
  };

  PhoneNumbers.prototype.getCountryCode = function() {
    var current;
    current = this.countryNameField[0].selectize.items[0];
    if (current) {
      return this.countryNameField[0].selectize.options[current].callingCode;
    }
  };

  PhoneNumbers.prototype.updateCountryCallingCode = function() {
    var code, isDisabled;
    code = this.getCountryCode();
    code = code ? '+' + code : '';
    this.callingCodeText.text(code);
    isDisabled = code === '';
    this.mobileNumberField
      .prop('disabled', isDisabled)
      .closest('.form-group')
      .toggleClass('disabled', isDisabled);
    this.phoneNumberField
      .prop('disabled', isDisabled)
      .closest('.form-group')
      .toggleClass('disabled', isDisabled);
    if (isDisabled) {
      this.mobileNumberField.attr(
        'placeholder',
        this.mobileNumberField.data('disabled-field-notice')
      );
      this.phoneNumberField.attr(
        'placeholder',
        this.mobileNumberField.data('disabled-field-notice')
      );
    } else {
      this.mobileNumberField.attr('placeholder', '');
      this.phoneNumberField.attr('placeholder', '');
    }
    return this.updateCtcTrigger();
  };

  PhoneNumbers.prototype.updateCtcTrigger = function() {
    return this.ctcTrigger.data('ajax-options', {
      phone: this.mobileNumberField.val(),
      country_name: this.countryNameField[0].selectize.items[0]
    });
  };

  PhoneNumbers.prototype.updateCtcTriggerState = function() {
    return $.get(
      this.ctcTrigger.data('verify-url'),
      function(_this) {
        return function(data) {
          if (data.status) {
            return _this.ctcTrigger.html('Number verified!');
          } else {
            return _this.ctcTrigger.html('Verify');
          }
        };
      }(this)
    );
  };

  return PhoneNumbers;
}();

module.exports = PhoneNumbers;
