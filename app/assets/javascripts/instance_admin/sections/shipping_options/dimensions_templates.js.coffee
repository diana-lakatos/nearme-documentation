class @DimensionsTemplates extends @JavascriptModule
  @include ShippoDimensionableAdmin

  constructor: (units) ->
    @units = units

    @updateUnitsOfMeasure()

