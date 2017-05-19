var AvailabilityRules;

AvailabilityRules = function() {
  function AvailabilityRules(container) {
    this.container = $(container);
    this.selector = this.container.find('input[type=radio][name*=availability_template]');
    if (!(this.selector.length > 0)) {
      return;
    }
    this.customFields = this.container.find('.custom-availability');
    this.bindEvents();
    this.updateCustomState(this.selector);
  }

  AvailabilityRules.prototype.updateCustomState = function(selector) {
    if (selector.filter(':checked').attr('data-custom-rules') != null) {
      return this.showCustom(selector);
    } else {
      return this.hideCustom(selector);
    }
  };

  AvailabilityRules.prototype.showCustom = function(selector) {
    this.customFields = selector.closest('.listing-availability').find('.custom-availability');
    this.customFields.find('input, select').prop('disabled', false);
    this.customFields.find('.disabled').removeClass('disabled');
    return this.customFields.show();
  };

  AvailabilityRules.prototype.hideCustom = function() {
    this.customFields.hide();
    return this.customFields.find('input, select').prop('disabled', true);
  };

  AvailabilityRules.prototype.bindEvents = function() {
    /*
     * Whenever the template selector changes we need to update the state of the UI
     */
    this.selector.change(
      function(_this) {
        return function(event) {
          return _this.updateCustomState($(event.target));
        };
      }(this)
    );
    this.customFields.on('cocoon:before-remove', function(e, fields) {
      var parent;
      parent = $(fields).closest('.nested-container');
      parent
        .find('.transactable_availability_template_availability_rules__destroy input')
        .val('true');
      parent.hide();
      return parent.prependTo(parent.closest('form'));
    });
    return this.customFields.on('cocoon:after-insert', function(e, insertedItem) {
      return $('html').trigger('timepickers.init.forms', [ insertedItem ]);
    });
  };

  return AvailabilityRules;
}();

module.exports = AvailabilityRules;
