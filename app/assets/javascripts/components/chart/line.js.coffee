class @ChartWrapper.Line extends @ChartWrapper

  constructor: (canvas, data, labels) ->
    super(canvas, data, labels)

  draw: ->
    new Chart(@ctx).Line(@data, @globalGraphSettings)

