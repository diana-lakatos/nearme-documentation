$(document).on('line:chart.nearme', function(event, el, values, labels){
  require.ensure('../../components/chart/line', function(require){
    var LineChart = require('../../components/chart/line');
    new LineChart(el, values, labels);
  });
});
