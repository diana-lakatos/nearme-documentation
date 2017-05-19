var AvailabilityRulesController;

AvailabilityRulesController = function() {
  function AvailabilityRulesController(container) {
    this.container = container;
    if (this.container.find('input[type=radio][name*=availability_template]').length > 0) {
      this.selector = this.container.find('input[type=radio][name*=availability_template]');
      this.customFields = this.container.find('.custom-availability-rules');

      /*
       * Set up event listeners
       */
      this.bindEvents();

      /*
       * Update for initial state
       */
      this.updateCustomState();
    }
  }

  AvailabilityRulesController.prototype.updateCustomState = function() {
    if (this.selector.filter(':checked').attr('data-custom-rules') != null) {
      return this.showCustom();
    } else {
      return this.hideCustom();
    }
  };

  AvailabilityRulesController.prototype.showCustom = function() {
    this.customFields.find('input, select').prop('disabled', false);
    this.customFields.find('.disabled').removeClass('disabled');
    return this.customFields.show();
  };

  AvailabilityRulesController.prototype.hideCustom = function() {
    this.customFields.hide();
    return this.customFields.find('input, select').prop('disabled', true);
  };

  AvailabilityRulesController.prototype.bindEvents = function() {
    /*
     * Whenever the template selector changes we need to update the state of the UI
     */
    this.selector.change(
      function(_this) {
        return function() {
          return _this.updateCustomState();
        };
      }(this)
    );
    return this.customFields.on('cocoon:before-remove', function(e, fields) {
      return $(fields)
        .closest('.nested-container')
        .find('.transactable_availability_template_availability_rules__destroy input')
        .val('true');
    });
  };

  return AvailabilityRulesController;
}();

module.exports = AvailabilityRulesController;
