class @ChartWrapper.Bar extends @ChartWrapper

  constructor: (canvas, data, labels, titles = []) ->
    super(canvas, data, labels, titles)

  draw: ->
    new Chart(@ctx).Bar(@data, @globalGraphSettings)

