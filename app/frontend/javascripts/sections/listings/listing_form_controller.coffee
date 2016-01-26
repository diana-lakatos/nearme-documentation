AvailabilityRulesController = require('../../components/availability_rules_controller')

module.exports = class ListingFormController

  constructor: (@container) ->
    @setupComponents()

  setupComponents: ->
    @availabilityRuleController = new AvailabilityRulesController(@container.find('.availability-rules'))

