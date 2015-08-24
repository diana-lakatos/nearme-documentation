class @UserDimensionsTemplates extends @JavascriptModule
  @include ShippoDimensionableAdmin

  constructor: (units) ->
    @units = units

    @updateUnitsOfMeasure()

