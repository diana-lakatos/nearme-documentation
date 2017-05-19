var ChartWrapper;

ChartWrapper = function() {
  ChartWrapper.prototype.defaultColors = function() {
    return [
      {
        fillColor: 'rgba(220,220,220,0.5)',
        strokeColor: 'rgba(220,220,220,1)',
        pointColor: 'rgba(220,220,220,1)',
        pointStrokeColor: '#fff'
      },
      {
        fillColor: 'rgba(151,187,205,0.5)',
        strokeColor: 'rgba(151,187,205,1)',
        pointColor: 'rgba(151,187,205,1)',
        pointStrokeColor: '#fff'
      }
    ];
  };

  function ChartWrapper(canvas, data, labels, titles) {
    var canvasSupported;
    canvasSupported = function() {
      var elem;
      elem = document.createElement('canvas');
      return !!(elem.getContext && elem.getContext('2d'));
    };
    canvas = $(canvas);
    if (canvas.length === 0) {
      return;
    }
    this.canvas = canvas;
    this.globalGraphSettings = {
      animation: canvasSupported(),
      scaleFontFamily: "'Open Sans', 'Helvetica Neue', Helvetica, Arial, sans-serif",
      scaleFontSize: 18
    };
    this.titles = titles;
    this.data = { labels: labels, datasets: this.parseData(data) };
    this.bindEvents();
    if (this.titles.length > 0) {
      this.drawLegend();
    }
    this.refreshChart();
  }

  ChartWrapper.prototype.bindEvents = function() {
    return $(window).resize(
      function(_this) {
        return function() {
          return _this.refreshChart();
        };
      }(this)
    );
  };

  ChartWrapper.prototype.parseData = function(data) {
    var index, result, values;
    result = [];
    for (index in data) {
      values = data[index];
      result.push($.extend({ data: values }, this.defaultColors()[index]));
      if (this.titles[index]) {
        result[index]['title'] = this.titles[index];
      }
    }
    return result;
  };

  ChartWrapper.prototype.refreshChart = function() {
    this.setup();
    return this.draw();
  };

  ChartWrapper.prototype.draw = function() {
    /*
     * This method is intended to be overriden by classes that inherit from this class.
     * As such, this log statement will not be called in production and should be left in
     * so other developers know to override this function in their subclass.
     */
    return console.log('Please overwrite this function in your subclass.');
  };

  ChartWrapper.prototype.setup = function() {
    this.canvas.prop({ width: this.canvas.parent().width(), height: 250 });
    return this.ctx = this.canvas.get(0).getContext('2d');
  };

  ChartWrapper.prototype.drawLegend = function() {
    var dataset, i, legend, len, ref, results, title;
    legend = $('<div class="legend"></div>');
    this.canvas.parent().append(legend);
    ref = this.data.datasets;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      dataset = ref[i];
      title = $(
        "<span class='title' style='border-color: " + dataset.strokeColor +
          ";border-style: solid;'>" +
          dataset.title +
          '</span>'
      );
      results.push(legend.append(title));
    }
    return results;
  };

  return ChartWrapper;
}();

module.exports = ChartWrapper;
