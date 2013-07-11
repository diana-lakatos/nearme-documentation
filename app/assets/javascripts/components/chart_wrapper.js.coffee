#= require_self
#= require ./chart/line

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

  constructor: (canvas, data, labels) ->

    @canvas = canvas
    @globalGraphSettings = {
      animation : Modernizr.canvas
    }

    @data = {
        labels : labels,
        datasets : @parseData(data)
    }
    @bindEvents()
    @refreshChart()

  bindEvents: ->
    $(window).resize =>
      @refreshChart()

  parseData: (data) ->
    result = []
    for index, values of data
      result.push $.extend({ data : values }, @defaultColors()[index])
    result

  refreshChart: ->
    @setup()
    @draw()



  draw: ->
    console.log 'overwrite needed'
    
  setup: ->
    @canvas.prop({
      width: @canvas.parent().width(),
      height: 200
    })
    @ctx = @canvas.get(0).getContext("2d")
