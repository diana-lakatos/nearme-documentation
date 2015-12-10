ChartWrapper = require('../chart_wrapper')
require 'Chart.js/src/Chart.Bar.js'

module.exports = class Bar extends ChartWrapper

  constructor: (canvas, data, labels, titles = []) ->
    canvas = $(canvas)
    super(canvas, data, labels, titles)

  draw: ->
    new Chart(@ctx).Bar(@data, @globalGraphSettings)

