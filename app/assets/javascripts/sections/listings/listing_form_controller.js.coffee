class @ListingFormController

  constructor: (@container) ->
    @setupComponents()

  setupComponents: ->
    @availabilityRuleController = new AvailabilityRulesController(@container.find('.availability-rules'))

