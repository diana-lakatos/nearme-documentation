var Forms;

Forms = function() {
  function Forms() {
    this.root = $('html');
    this.bindEvents();
    this.initialize();
  }

  Forms.prototype.bindEvents = function() {
    this.root.on(
      'loaded:dialog.nearme',
      function(_this) {
        return function() {
          return _this.initialize('.dialog');
        };
      }(this)
    );
    this.root.on('datepickers.init.forms', function(event, context) {
      if (context == null) {
        context = 'body';
      }
      return require.ensure('./datepickers', function(require) {
        var datepickers;
        datepickers = require('./datepickers');
        return datepickers(context);
      });
    });
    this.root.on('timepickers.init.forms', function(event, context) {
      if (context == null) {
        context = 'body';
      }
      return require.ensure('./timepickers', function(require) {
        var timepickers;
        timepickers = require('./timepickers');
        return timepickers(context);
      });
    });
    this.root.on('hints.init.forms', function(event, context) {
      if (context == null) {
        context = 'body';
      }
      return require.ensure('./hints', function(require) {
        var hints;
        hints = require('./hints');
        return hints(context);
      });
    });
    this.root.on('tooltips.init.forms', function(event, context) {
      if (context == null) {
        context = 'body';
      }
      return require.ensure('./tooltips', function(require) {
        var tooltips;
        tooltips = require('./tooltips');
        return tooltips(context);
      });
    });
    return this.root.on('selects.init.forms', function(event, context) {
      if (context == null) {
        context = 'body';
      }
      return require.ensure('./selects', function(require) {
        var selects;
        selects = require('./selects');
        return selects(context);
      });
    });
  };

  Forms.prototype.hints = function(context) {
    var els;
    if (context == null) {
      context = 'body';
    }
    els = $(context).find('.form-group .help-block.hint');
    if (!(els.length > 0)) {
      return;
    }
    return require.ensure('./hints', function(require) {
      var hints;
      hints = require('./hints');
      return hints(context);
    });
  };

  Forms.prototype.tooltips = function(context) {
    var els;
    if (context == null) {
      context = 'body';
    }
    els = $(context).find('[data-toggle="tooltip"]');
    if (!(els.length > 0)) {
      return;
    }
    return require.ensure('./tooltips', function(require) {
      var tooltips;
      tooltips = require('./tooltips');
      return tooltips(context);
    });
  };

  Forms.prototype.selects = function(context) {
    var els;
    if (context == null) {
      context = 'body';
    }
    els = $(context).find('.form-group select');
    if (!(els.length > 0)) {
      return;
    }
    return require.ensure('./selects', function(require) {
      var selects;
      selects = require('./selects');
      return selects(context);
    });
  };

  Forms.prototype.datepickers = function(context) {
    var els;
    if (context == null) {
      context = 'body';
    }
    els = $(context).find('.datetimepicker');
    if (!(els.length > 0)) {
      return;
    }
    return require.ensure('./datepickers', function(require) {
      var datepickers;
      datepickers = require('./datepickers');
      return datepickers(context);
    });
  };

  Forms.prototype.timepickers = function(context) {
    var els;
    if (context == null) {
      context = 'body';
    }
    els = $(context).find('.time_picker');
    if (!(els.length > 0)) {
      return;
    }
    return require.ensure('./timepickers', function(require) {
      var timepickers;
      timepickers = require('./timepickers');
      return timepickers(context);
    });
  };

  Forms.prototype.ranges = function(context) {
    var els;
    if (context == null) {
      context = 'body';
    }
    els = $(context).find('.custom_range');
    if (!(els.length > 0)) {
      return;
    }
    return require.ensure('./ranges', function(require) {
      var ranges;
      ranges = require('./ranges');
      return ranges(els);
    });
  };

  Forms.prototype.initialize = function(context) {
    if (context == null) {
      context = 'body';
    }
    this.hints(context);
    this.tooltips(context);
    this.datepickers(context);
    this.selects(context);
    this.timepickers(context);
    return this.ranges(context);
  };

  return Forms;
}();

module.exports = Forms;
