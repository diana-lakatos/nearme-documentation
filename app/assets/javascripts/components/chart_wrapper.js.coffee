#= require_self
#= require ./chart/line
#= require ./chart/bar

class @ChartWrapper

  defaultColors: ->
    [
      {
        fillColor : "rgba(220,220,220,0.5)",
        strokeColor : "rgba(220,220,220,1)",
        pointColor : "rgba(220,220,220,1)",
        pointStrokeColor : "#fff",
      },
      {
        fillColor : "rgba(151,187,205,0.5)",
        strokeColor : "rgba(151,187,205,1)",
        pointColor : "rgba(151,187,205,1)",
        pointStrokeColor : "#fff",
      }
    ]

  constructor: (canvas, data, labels, titles) ->

    @canvas = canvas
    @globalGraphSettings = {
      animation : Modernizr.canvas,
      scaleFontFamily : "'Futura-regular', sans-serif",
      scaleFontSize : 18
    }
    @titles = titles

    @data = {
        labels : labels,
        datasets : @parseData(data)
    }
    @bindEvents()
    if @titles.length > 0
      @drawLegend()
    @refreshChart()

  bindEvents: ->
    $(window).resize =>
      @refreshChart()

  parseData: (data) ->
    result = []
    for index, values of data
      result.push $.extend({ data : values }, @defaultColors()[index])
      if @titles[index]
        result[index]['title'] = @titles[index]
    result

  refreshChart: ->
    @setup()
    @draw()

  draw: ->
    console.log 'overwrite needed'

  setup: ->
    @canvas.prop({
      width: @canvas.parent().width(),
      height: 250
    })
    @ctx = @canvas.get(0).getContext("2d")

  drawLegend: ->
      legend = $('<div class="legend"></div>')
      @canvas.parent().append(legend)
      for dataset in @data.datasets
        title = $("<span class='title' style='border-color: #{dataset.strokeColor};border-style: solid;'>#{dataset.title}</span>")
        legend.append(title)
