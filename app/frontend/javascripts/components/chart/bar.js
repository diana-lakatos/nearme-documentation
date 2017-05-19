var Chart,
  ChartWrapper,
  ChartWrapperBar,
  extend = function(child, parent) {
    for (var key in parent) {
      if (hasProp.call(parent, key))
        child[key] = parent[key];
    }
    function ctor() {
      this.constructor = child;
    }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
    return child;
  },
  hasProp = {}.hasOwnProperty;

ChartWrapper = require('../chart_wrapper');

require('imports?this=>window!chart.js/src/Chart.Core.js');

Chart = require('imports?this=>window!exports?window.Chart!chart.js/src/Chart.Bar.js');

ChartWrapperBar = function(superClass) {
  extend(ChartWrapperBar, superClass);

  function ChartWrapperBar(canvas, data, labels, titles) {
    if (titles == null) {
      titles = [];
    }
    ChartWrapperBar.__super__.constructor.call(this, canvas, data, labels, titles);
  }

  ChartWrapperBar.prototype.draw = function() {
    return new Chart(this.ctx).Bar(this.data, this.globalGraphSettings);
  };

  return ChartWrapperBar;
}(ChartWrapper);

module.exports = ChartWrapperBar;
