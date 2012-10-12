class @LocationFormController

  constructor: (@container) ->
    @setupComponents()

  setupComponents: ->
    @availabilityRuleController = new AvailabilityRulesController(@container.find('.availability-rules'))
