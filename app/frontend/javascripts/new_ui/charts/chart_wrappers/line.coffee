ChartWrapper = require('../chart_wrapper')
require 'imports?this=>window!chart.js/src/Chart.Core.js'
Chart = require 'imports?this=>window!exports?window.Chart!chart.js/src/Chart.Line.js'

module.exports = class Line extends ChartWrapper

  constructor: (canvas, data, labels, titles = [], customYScale = false) ->
    canvas = $(canvas)
    @customYScale = customYScale
    super(canvas, data, labels, titles)

  draw: ->
    if @customYScale
      minValue = 999999
      maxValue = -999999
      for dataset in @data.datasets
        datasetMin = _.min(_.toArray(dataset.data))
        datasetMax = _.max(_.toArray(dataset.data))
        if datasetMax > maxValue
          maxValue = datasetMax
        if datasetMin < minValue
          minValue = datasetMin

      if minValue == maxValue
        minValue -= maxValue

      stepsCount = 10  # 10 steps ideally fit our charts
      if stepsCount > maxValue
        # in case we have only small values like [1, 2, 2, 0]
        stepsCount = maxValue

      step = parseInt((maxValue - minValue) / stepsCount)

      @customYScaleSettings = {
        scaleOverride: true,
        scaleStepWidth: step,
        scaleSteps: stepsCount,
        scaleStartValue: minValue
      }
      @globalGraphSettings = _.extend @globalGraphSettings, @customYScaleSettings

    new Chart(@ctx).Line(@data, @globalGraphSettings)

