JavascriptModule = require('../../lib/javascript_module')
ShippoDimensionableAdmin = require('../../lib/shippo_dimensionable_admin')

module.exports = class UserDimensionsTemplates extends JavascriptModule
  @include ShippoDimensionableAdmin

  constructor: (units) ->
    @units = units

    @updateUnitsOfMeasure()

