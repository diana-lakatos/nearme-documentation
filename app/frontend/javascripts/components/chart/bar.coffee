require('exports?Chart!Chart.js');
ChartWrapper = require('../chart_wrapper')

module.exports = class ChartWrapperBar extends ChartWrapper
  constructor: (canvas, data, labels, titles = []) ->
    super(canvas, data, labels, titles)

  draw: ->
    new Chart(@ctx).Bar(@data, @globalGraphSettings)

