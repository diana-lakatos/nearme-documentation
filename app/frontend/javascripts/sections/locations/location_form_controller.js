var AvailabilityRulesController, LocationFormController;

AvailabilityRulesController = require('../../components/availability_rules_controller');

LocationFormController = function() {
  function LocationFormController(container) {
    this.container = container;
    this.availabilityRuleController = new AvailabilityRulesController(
      this.container.find('.availability-rules')
    );
  }

  return LocationFormController;
}();

module.exports = LocationFormController;
