class @Dashboard.LocationController

  constructor: (@container) ->
    new AvailabilityRulesController(@container)
    new Dashboard.AddressController(@container)

