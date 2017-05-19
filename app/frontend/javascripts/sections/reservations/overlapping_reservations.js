var OverlappingReservationsController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('../../components/modal');

require('../../dashboard/modules/dialog');

OverlappingReservationsController = function() {
  function OverlappingReservationsController(container, review_options) {
    this.container = container;
    this.review_options = review_options != null ? review_options : {};
    this.handleResponse = bind(this.handleResponse, this);
    this.dateField = this.container.find('#order_dates');
    this.visibleDateField = this.container.find('.jquery-datepicker');
    this.validatorUrl = this.container.data('validator-url');
    this.checkEnabled = this.container.data('check-overlapping-dates');
  }

  OverlappingReservationsController.prototype.formAttributes = function() {
    return { date: this.dateField.val() };
  };

  OverlappingReservationsController.prototype.checkNewDate = function() {
    if (this.checkEnabled === void 0) {
      return true;
    }
    this.clearWarnings();
    return $.getJSON(this.validatorUrl, this.formAttributes()).then(this.handleResponse);
  };

  OverlappingReservationsController.prototype.handleResponse = function(response) {
    var warning;
    if (!response.warnings) {
      return;
    }
    warning = $('<div class="warning"></div>').html(response.warnings.overlaping_reservations);
    return this.displayMessage(warning);
  };

  OverlappingReservationsController.prototype.clearWarnings = function() {
    return this.visibleDateField.siblings('.warning').remove();
  };

  OverlappingReservationsController.prototype.displayMessage = function(warning) {
    return this.visibleDateField.parent().append(warning);
  };

  return OverlappingReservationsController;
}();

module.exports = OverlappingReservationsController;
