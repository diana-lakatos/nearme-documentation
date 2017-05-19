/*
 * Handles the behaviour of entering country+mobile+phone fields
 * Used on the user account form, booking modal and the space setup wizard form.
 */
var PhoneNumberFieldsForm;

PhoneNumberFieldsForm = function() {
  function PhoneNumberFieldsForm(container, arg) {
    var ref;
    if (container == null) {
      container = 'div[data-phone-fields-container]';
    }
    ref = arg != null
      ? arg
      : {}, this.countrySelector = ref.countrySelector, this.codeSelector = ref.codeSelector, this.mobileSelector = ref.mobileSelector, this.phoneSelector = ref.phoneSelector, this.sameAsSelector = ref.sameAsSelector;
    this.container = $(container);
    _.defaults(this, {
      countrySelector: 'select[data-country-selector]',
      codeSelector: '.phone-number-country-code-field',
      mobileSelector: 'input[data-mobile-number]',
      phoneSelector: 'input[data-phone]',
      sameAsSelector: 'input[data-same-as-phone-checkbox]'
    });
    this.findFields();
    this.bindEvents();
    this.updateCountryCallingCode();
    this.updatePhoneNumber();
  }

  PhoneNumberFieldsForm.prototype.findFields = function() {
    this.countryNameField = this.container.find(this.countrySelector);
    this.callingCodeText = this.container.find(this.codeSelector);
    this.mobileNumberField = this.container.find(this.mobileSelector);
    this.phoneNumberField = this.container.find(this.phoneSelector);
    return this.sameAsPhoneField = this.container.find(this.sameAsSelector);
  };

  PhoneNumberFieldsForm.prototype.bindEvents = function() {
    this.countryNameField.on(
      'change',
      function(_this) {
        return function() {
          return _this.updateCountryCallingCode();
        };
      }(this)
    );
    this.phoneNumberField.on(
      'change',
      function(_this) {
        return function() {
          return _this.updatePhoneNumber();
        };
      }(this)
    );
    return this.sameAsPhoneField.on(
      'change',
      function(_this) {
        return function() {
          return _this.updatePhoneNumber();
        };
      }(this)
    );
  };

  PhoneNumberFieldsForm.prototype.updatePhoneNumber = function() {
    this.mobileNumberField.prop('readonly', !!this.isMobileSameAsPhone());
    if (this.isMobileSameAsPhone()) {
      return this.mobileNumberField.val(this.phoneNumberField.val());
    }
  };

  PhoneNumberFieldsForm.prototype.isMobileSameAsPhone = function() {
    return this.sameAsPhoneField.is(':checked');
  };

  PhoneNumberFieldsForm.prototype.updateCountryCallingCode = function() {
    var code;
    code = this.countryNameField.find('option:selected').data('calling-code');
    code = code ? '+' + code : '';
    if (code !== '') {
      if (this.callingCodeText.find('.country-calling-code').length > 0) {
        return this.callingCodeText.find('.country-calling-code').text(code);
      } else {
        return this.callingCodeText.prepend("<div class='country-calling-code'>" + code + '</div>');
      }
    } else {
      return this.callingCodeText.find('.country-calling-code').remove();
    }
  };

  return PhoneNumberFieldsForm;
}();

module.exports = PhoneNumberFieldsForm;
