var Bar,
  Chart,
  ChartWrapper,
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

Bar = function(superClass) {
  extend(Bar, superClass);

  function Bar(canvas, data, labels, titles) {
    if (titles == null) {
      titles = [];
    }
    canvas = $(canvas);
    Bar.__super__.constructor.call(this, canvas, data, labels, titles);
  }

  Bar.prototype.draw = function() {
    return new Chart(this.ctx).Bar(this.data, this.globalGraphSettings);
  };

  return Bar;
}(ChartWrapper);

module.exports = Bar;
