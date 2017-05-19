var DashboardStripeConnectController;

DashboardStripeConnectController = function() {
  function DashboardStripeConnectController(container) {
    this.container = container;
    this.accountTypeSelect = this.container.find('select[data-account-type]');
    this.bindEvents();
    this.accountTypeSelect.change();
  }

  DashboardStripeConnectController.prototype.bindEvents = function() {
    return this.accountTypeSelect.on('change', function() {
      var companyFields;
      companyFields = $('div[data-account-type=company]');
      if ($(this).val() === 'company') {
        return companyFields.removeClass('hidden');
      } else {
        return companyFields.addClass('hidden');
      }
    });
  };

  return DashboardStripeConnectController;
}();

module.exports = DashboardStripeConnectController;
