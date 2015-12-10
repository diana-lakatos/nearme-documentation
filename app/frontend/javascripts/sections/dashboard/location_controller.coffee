AvailabilityRulesController = require('../../components/availability_rules_controller')
DashboardAddressController = require('./address_controller')

module.exports = class DashboardLocationController

  constructor: (@container) ->
    new AvailabilityRulesController(@container)
    new DashboardAddressController(@container)
