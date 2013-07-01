#= require_self
#= require ./chart/line

class @ChartWrapper

  constructor: (canvas, data, labels) ->

    @canvas = canvas
    @globalGraphSettings = {
      animation : Modernizr.canvas
    }

    @data = {
        labels : labels,
        datasets : [
            {
                fillColor : "rgba(151,187,205,0.5)",
                strokeColor : "rgba(151,187,205,1)",
                pointColor : "rgba(151,187,205,1)",
                pointStrokeColor : "#fff",
                data : data
            }
        ]
    }
    @bindEvents()
    @refreshChart()

  bindEvents: ->
    $(window).resize =>
      @refreshChart()

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
