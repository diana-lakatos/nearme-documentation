JavascriptModule = require('../../../lib/javascript_module')
ShippoDimensionableAdmin = require('../../../lib/shippo_dimensionable_admin')

module.exports = class DimensionsTemplates extends JavascriptModule
  @include ShippoDimensionableAdmin

  constructor: (el) ->
    @units = $(el).data('units')
    @updateUnitsOfMeasure()

