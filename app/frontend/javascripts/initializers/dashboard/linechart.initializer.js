$(document).on('line:chart.nearme', function(event, el, values, labels){
  require.ensure('../../dashboard/charts/chart_wrappers/line', function(require){
    var LineChart = require('../../dashboard/charts/chart_wrappers/line');
    new LineChart(el, values, labels);
  });
});
