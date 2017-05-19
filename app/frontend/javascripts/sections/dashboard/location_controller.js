var AvailabilityRulesController, DashboardAddressController, DashboardLocationController;

AvailabilityRulesController = require('../../components/availability_rules_controller');

DashboardAddressController = require('./address_controller');

DashboardLocationController = function() {
  function DashboardLocationController(container) {
    this.container = container;
    new AvailabilityRulesController(this.container);
    new DashboardAddressController(this.container);
  }

  return DashboardLocationController;
}();

module.exports = DashboardLocationController;
