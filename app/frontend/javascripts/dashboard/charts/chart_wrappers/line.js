var Chart,
  ChartWrapper,
  Line,
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

Chart = require('imports?this=>window!exports?window.Chart!chart.js/src/Chart.Line.js');

Line = function(superClass) {
  extend(Line, superClass);

  function Line(canvas, data, labels, titles, customYScale) {
    if (titles == null) {
      titles = [];
    }
    if (customYScale == null) {
      customYScale = false;
    }
    canvas = $(canvas);
    this.customYScale = customYScale;
    Line.__super__.constructor.call(this, canvas, data, labels, titles);
  }

  Line.prototype.draw = function() {
    var dataset, datasetMax, datasetMin, i, len, maxValue, minValue, ref, step, stepsCount;
    if (this.customYScale) {
      minValue = 999999;
      maxValue = -999999;
      ref = this.data.datasets;
      for (i = 0, len = ref.length; i < len; i++) {
        dataset = ref[i];
        datasetMin = _.min(_.toArray(dataset.data));
        datasetMax = _.max(_.toArray(dataset.data));
        if (datasetMax > maxValue) {
          maxValue = datasetMax;
        }
        if (datasetMin < minValue) {
          minValue = datasetMin;
        }
      }
      if (minValue === maxValue) {
        minValue -= maxValue;
      }
      stepsCount = 10;
      if (stepsCount > maxValue) {
        /*
         * in case we have only small values like [1, 2, 2, 0]
         */
        stepsCount = maxValue;
      }
      step = parseInt((maxValue - minValue) / stepsCount);
      this.customYScaleSettings = {
        scaleOverride: true,
        scaleStepWidth: step,
        scaleSteps: stepsCount,
        scaleStartValue: minValue
      };
      this.globalGraphSettings = _.extend(this.globalGraphSettings, this.customYScaleSettings);
    }
    return new Chart(this.ctx).Line(this.data, this.globalGraphSettings);
  };

  return Line;
}(ChartWrapper);

module.exports = Line;
