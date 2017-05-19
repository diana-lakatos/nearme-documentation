var Forms;

Forms = function() {
  function Forms() {
    this.bindEvents();
    this.initialize();
  }

  Forms.prototype.bindEvents = function() {
    $('html').on('datepickers.init.forms', function(event, context) {
      if (context == null) {
        context = 'body';
      }
      return require.ensure('../../dashboard/forms/datepickers', function(require) {
        var DatepickersInitializer;
        DatepickersInitializer = require('../../dashboard/forms/datepickers');
        return new DatepickersInitializer(context);
      });
    });
    $('html').on('timepickers.init.forms', function(event, context) {
      if (context == null) {
        context = 'body';
      }
      return require.ensure('../../dashboard/forms/timepickers', function(require) {
        var timepickers;
        timepickers = require('../../dashboard/forms/timepickers');
        return timepickers(context);
      });
    });
    return $('html').on('selects.init.forms', function(event, context) {
      if (context == null) {
        context = 'body';
      }
      return require.ensure('./chosen', function(require) {
        var ChosenInitializer;
        ChosenInitializer = require('./chosen');
        return new ChosenInitializer(context);
      });
    });
  };

  Forms.prototype.initialize = function() {
    if ($('.datetimepicker').length > 0) {
      require.ensure('../../dashboard/forms/datepickers', function(require) {
        var DatepickersInitializer;
        DatepickersInitializer = require('../../dashboard/forms/datepickers');
        return new DatepickersInitializer();
      });
    }
    if ($('select.chosen, select.select').length > 0) {
      require.ensure('./chosen', function(require) {
        var ChosenInitializer;
        ChosenInitializer = require('./chosen');
        return new ChosenInitializer();
      });
    }
    if ($('.selectpicker').length > 0) {
      require.ensure('./selectpicker', function(require) {
        var SelectpickerInitializer;
        SelectpickerInitializer = require('./selectpicker');
        return new SelectpickerInitializer();
      });
    }
    if ($('.select2').length > 0) {
      require.ensure('./select2', function(require) {
        var Select2Initializer;
        Select2Initializer = require('./select2');
        return new Select2Initializer();
      });
    }
    if ($('.time_picker').length > 0) {
      return require.ensure('../../dashboard/forms/timepickers', function(require) {
        var timepickers;
        timepickers = require('../../dashboard/forms/timepickers');
        return timepickers();
      });
    }
  };

  return Forms;
}();

module.exports = Forms;
