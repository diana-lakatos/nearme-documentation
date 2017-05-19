var AddressController, Datepickers, StripeConnectController;

AddressController = require('../../sections/dashboard/address_controller');

Datepickers = require('../../dashboard/forms/datepickers');

StripeConnectController = function() {
  function StripeConnectController(container) {
    this.container = $(container);
    this.accountTypeSelect = this.container.find('select[data-account-type]');
    this.bindEvents();
    this.accountTypeSelect.change();
    Datepickers(this.container);
    this.container.find('.location').each(function(index, el) {
      return new AddressController($(el));
    });
  }

  StripeConnectController.prototype.bindEvents = function() {
    this.accountTypeSelect.on('change', function() {
      var el, fields, i, len, match, ref, ref1, results;
      ref = [ 'company', 'individual', 'both' ];
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        el = ref[i];
        fields = $('div[data-account-type=' + el + ']');
        if (el === 'both') {
          match = (ref1 = $(this).val()) === 'individual' || ref1 === 'company';
        } else {
          match = $(this).val() === el;
        }
        results.push(fields.toggleClass('hidden', !match));
      }
      return results;
    });
    return this.container.on('cocoon:after-insert', function(e, fields) {
      Datepickers(fields);
      return new AddressController(fields);
    });
  };

  return StripeConnectController;
}();

module.exports = StripeConnectController;
