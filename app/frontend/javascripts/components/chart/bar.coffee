ChartWrapper = require('../chart_wrapper')
require 'imports?this=>window!chart.js/src/Chart.Core.js'
Chart = require 'imports?this=>window!exports?window.Chart!chart.js/src/Chart.Bar.js'

module.exports = class ChartWrapperBar extends ChartWrapper
  constructor: (canvas, data, labels, titles = []) ->
    super(canvas, data, labels, titles)

  draw: ->
    new Chart(@ctx).Bar(@data, @globalGraphSettings)

