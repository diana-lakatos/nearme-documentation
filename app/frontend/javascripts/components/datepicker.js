var Datepicker, DatepickerModel, DatepickerView, asEvented;

asEvented = require('asevented');

DatepickerModel = require('./datepicker/model');

DatepickerView = require('./datepicker/view');

/*
 * Datepicker
 *
 * Supports multiple date selection
 *
 * datepicker = new Datepicker(
 *   trigger: $('triger')
 * )
 *
 */
Datepicker = function() {
  asEvented.call(Datepicker.prototype);

  Datepicker.prototype.defaultOptions = {
    containerClass: 'dnm-datepicker',
    appendTo: 'body',
    /*
     * Inject the view object managed by this Datepicker
     */
    view: null,
    viewClass: null,
    model: null,
    modelClass: null
  };

  function Datepicker(options) {
    this.options = options != null ? options : {};
    this.options = $.extend({}, this.defaultOptions, this.options);
    this.model = this.options.model || new this.options.modelClass || DatepickerModel(this.options);
    this.view = this.options.view || new this.options.viewClass || DatepickerView(this.options);
    this.view.setModel(this.model);
    this.view.appendTo($(this.options.appendTo));
    this.bindViewEvents();
    this.bindEvents();
  }

  Datepicker.prototype.bindEvents = function() {
    if (this.options.trigger) {
      if (this.options.trigger) {
        this.view.closeIfClickedOutside(this.options.trigger);
      }
      return $(this.options.trigger).on(
        'click',
        function(_this) {
          return function() {
            return _this.view.toggle();
          };
        }(this)
      );
    }
  };

  Datepicker.prototype.bindViewEvents = function() {
    this.view.bind(
      'prevClicked',
      function(_this) {
        return function() {
          return _this.model.advanceMonth(-1);
        };
      }(this)
    );
    this.view.bind(
      'nextClicked',
      function(_this) {
        return function() {
          return _this.model.advanceMonth(1);
        };
      }(this)
    );
    this.view.bind(
      'dateClicked',
      function(_this) {
        return function(date) {
          _this.model.toggleDate(date);
          return _this.trigger('datesChanged', _this.model.getDates());
        };
      }(this)
    );
    this.model.bind(
      'dateAdded',
      function(_this) {
        return function(date) {
          return _this.view.dateAdded(date);
        };
      }(this)
    );
    this.model.bind(
      'dateRemoved',
      function(_this) {
        return function(date) {
          return _this.view.dateRemoved(date);
        };
      }(this)
    );
    return this.model.bind(
      'monthChanged',
      function(_this) {
        return function(newMonth) {
          return _this.view.renderMonth(newMonth);
        };
      }(this)
    );
  };

  Datepicker.prototype.show = function() {
    return this.view.show();
  };

  Datepicker.prototype.hide = function() {
    return this.view.hide();
  };

  Datepicker.prototype.toggle = function() {
    return this.view.toggle();
  };

  Datepicker.prototype.getDates = function() {
    return this.model.getDates();
  };

  Datepicker.prototype.setDates = function(dates) {
    return this.model.setDates(dates);
  };

  Datepicker.prototype.removeDate = function(date) {
    return this.model.removeDate(date);
  };

  Datepicker.prototype.addDate = function(date) {
    return this.model.addDate(date);
  };

  Datepicker.prototype.getView = function() {
    return this.view;
  };

  Datepicker.prototype.getModel = function() {
    return this.model;
  };

  return Datepicker;
}();

module.exports = Datepicker;
