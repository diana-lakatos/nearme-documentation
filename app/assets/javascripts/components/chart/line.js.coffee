class @ChartWrapper.Line extends @ChartWrapper

  constructor: (canvas, data, labels, titles = []) ->
    super(canvas, data, labels, titles)

  draw: ->
    new Chart(@ctx).Line(@data, @globalGraphSettings)

