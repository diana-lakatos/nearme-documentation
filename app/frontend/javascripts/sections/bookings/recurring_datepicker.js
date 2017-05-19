var Datepicker, DatepickerModelSingle, DatepickerView, RecurringDatepicker, asEvented;

asEvented = require('asevented');

Datepicker = require('../../components/datepicker');

DatepickerView = require('../../components/datepicker/view');

DatepickerModelSingle = require('../../components/datepicker/single');

/*
 * Wraps our custom Datepicker implementation for use as a Booking selection calendar.
 *
 * See also: components/datepicker.js
 */
RecurringDatepicker = function() {
  asEvented.call(RecurringDatepicker.prototype);

  /*
   * Some text constants used in the UI
   */
  RecurringDatepicker.prototype.TEXT_START = '<div class="datepicker-text-fadein">Select a start date</div>';

  RecurringDatepicker.prototype.TEXT_END_RANGE = '<div class="datepicker-text-fadein">Select an end date</div>';

  /*
   * Initialize the date picker components
   * options - Hash of options to initialize the component
   *           listing - The listing model
   *           startElement - The start range trigger element
   *           endElement - The end range trigger element
   */
  function RecurringDatepicker(options) {
    if (options == null) {
      options = {};
    }
    this.startElement = options.startElement;
    this.endElement = options.endElement;
    this.initializeStartDatepicker();
    this.initializeEndDatepicker();
    this.bindEvents();
  }

  RecurringDatepicker.prototype.bindEvents = function() {
    this.startDatepicker.on(
      'datesChanged',
      function(_this) {
        return function(dates) {
          return _this.startOnChanged(dates[0]);
        };
      }(this)
    );
    return this.endDatepicker.on(
      'datesChanged',
      function(_this) {
        return function(dates) {
          return _this.endOnChanged(dates[0]);
        };
      }(this)
    );
  };

  RecurringDatepicker.prototype.startOnChanged = function(date) {
    this.startElement.val(this.formatDateForLabel(date));
    this.trigger('startOnChanged', date);
    return this.startDatepicker.hide();
  };

  RecurringDatepicker.prototype.endOnChanged = function(date) {
    this.endElement.val(this.formatDateForLabel(date));
    this.trigger('endOnChanged', date);
    if (this.endDatepicker.getView().isVisible()) {
      return this.endDatepicker.hide();
    }
  };

  RecurringDatepicker.prototype.initializeStartDatepicker = function() {
    return this.startDatepicker = new Datepicker({
      trigger: this.startElement,
      /*
       * Custom view to handle bookings availability display
       */
      view: new DatepickerView({ trigger: this.startElement, text: this.TEXT_START }),
      /*
       * Limit to a single date selected at a time
       */
      model: new DatepickerModelSingle({ allowDeselection: false })
    });
  };

  RecurringDatepicker.prototype.initializeEndDatepicker = function() {
    return this.endDatepicker = new Datepicker({
      trigger: this.endElement,
      /*
       * Custom view to handle bookings availability display
       */
      view: new DatepickerView({ trigger: this.endElement, text: this.TEXT_END_RANGE }),
      /*
       * Limit to a single date selected at a time
       */
      model: new DatepickerModelSingle({ allowDeselection: false })
    });
  };

  RecurringDatepicker.prototype.formatDateForLabel = function(date) {
    return [ date.getFullYear(), date.getMonth() + 1, date.getDate() ].join('-');
  };

  RecurringDatepicker.prototype.setDates = function(dates) {
    this.startDatepicker.setDates(dates.slice(0, 1));
    this.endDatepicker.setDates([ dates[dates.length - 1] ]);
    this.startOnChanged(dates[0]);
    return this.endOnChanged(dates[dates.length - 1]);
  };

  return RecurringDatepicker;
}();

module.exports = RecurringDatepicker;
