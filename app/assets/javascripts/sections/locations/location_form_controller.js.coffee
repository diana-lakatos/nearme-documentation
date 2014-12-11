class @LocationFormController

  constructor: (@container) ->
    @availabilityRuleController = new AvailabilityRulesController(@container.find('.availability-rules'))

