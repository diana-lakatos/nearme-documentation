AvailabilityRulesController = require('../../components/availability_rules_controller')

module.exports = class LocationFormController

  constructor: (@container) ->
    @availabilityRuleController = new AvailabilityRulesController(@container.find('.availability-rules'))

