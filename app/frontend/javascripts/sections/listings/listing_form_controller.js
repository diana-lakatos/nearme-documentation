var AvailabilityRulesController, ListingFormController;

AvailabilityRulesController = require('../../components/availability_rules_controller');

ListingFormController = function() {
  function ListingFormController(container) {
    this.container = container;
    this.setupComponents();
  }

  ListingFormController.prototype.setupComponents = function() {
    return this.availabilityRuleController = new AvailabilityRulesController(
      this.container.find('.availability-rules')
    );
  };

  return ListingFormController;
}();

module.exports = ListingFormController;
