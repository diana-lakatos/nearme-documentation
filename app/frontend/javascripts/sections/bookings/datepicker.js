/* global I18n */
var AvailabilityView,
  BookingsDatepicker,
  Datepicker,
  DatepickerModelSingle,
  ModeAndConstraintModel,
  TimePicker,
  asEvented,
  dateUtil,
  urlUtil;

AvailabilityView = require('./datepicker/availability_view');

ModeAndConstraintModel = require('./datepicker/mode_and_constraint_model');

asEvented = require('asevented');

Datepicker = require('../../components/datepicker');

DatepickerModelSingle = require('../../components/datepicker/single');

dateUtil = require('../../lib/utils/date');

urlUtil = require('../../lib/utils/url');

TimePicker = require('./time_picker');

require('../../../vendor/gf3-strftime');

/*
 * Wraps our custom Datepicker implementation for use as a Booking selection calendar.
 *
 * See also: components/datepicker.js
 */
BookingsDatepicker = function() {
  asEvented.call(BookingsDatepicker.prototype);

  /*
   * Some text constants used in the UI
   */
  BookingsDatepicker.prototype.TEXT_END_RANGE = '<div class="datepicker-text-fadein">Select an end date</div>';

  /*
   * Initialize the date picker components
   * options - Hash of options to initialize the component
   *           listing - The listing model
   *           startElement - The start range trigger element
   *           endElement - The end range trigger element
   */
  function BookingsDatepicker(options) {
    if (options == null) {
      options = {};
    }
    this.listing = options.listing;
    this.container = options.container;
    this.startElement = this.container.find('.calendar-wrapper.date-start');
    this.endElement = this.container.find('.calendar-wrapper.date-end');
    this.listingData = options.listingData;
    this.initializeStartDatepicker();
    if (this.endElement.length > 0) {
      this.initializeEndDatepicker();
    }
    this.bindEvents();
    this.assignInitialDates();
    if (this.listing.canReserveHourly()) {
      this.initializeTimePicker();
    }
  }

  /*
  #TODO: replace these with JS i18n system
   */
  BookingsDatepicker.prototype.start_text = function() {
    if (this.listing.isOvernightBooking()) {
      return '<div class="datepicker-text-fadein">Check in</div>';
    } else if (this.listing.isReservedHourly()) {
      return '<div class="datepicker-text-fadein">Select date</div>';
    } else {
      return '<div class="datepicker-text-fadein">Select a start date</div>';
    }
  };

  BookingsDatepicker.prototype.end_text = function() {
    if (this.listing.isOvernightBooking()) {
      return '<div class="datepicker-text-fadein">Check out</div>';
    } else {
      return '<div class="datepicker-text-fadein">Select an end date</div>';
    }
  };

  BookingsDatepicker.prototype.bindEvents = function() {
    this.listing.on(
      'quantityChanged',
      function(_this) {
        return function() {
          if (_this.timePicker) {
            return setTimeout(
              function() {
                return _this.timePicker.updateSelectableTimes();
              },
              100
            );
          }
        };
      }(this)
    );
    this.startDatepicker.on(
      'datesChanged',
      function(_this) {
        return function() {
          _this.startDatepickerWasChanged();
          if (_this.timePicker) {
            return _this.timePicker.updateSelectableTimes();
          }
        };
      }(this)
    );
    if (this.endDatepicker) {
      this.endDatepicker.on(
        'datesChanged',
        function(_this) {
          return function() {
            return _this.datesWereChanged();
          };
        }(this)
      );
    }
    if (this.endDatepicker) {
      /*
       * The 'rangeApplied' event is fired by our custom endDatepicker model when a date
       * is toggled with the 'range' mode on. We bind this to set the mode to the second
       * mode, to add/remove dates.
       */
      return this.endDatepicker.getModel().on(
        'rangeApplied',
        function(_this) {
          return function() {
            /*
           * For now, we only provide the add/remove pick mode for listings allowing
           * individual day selection.
           */
            if (!_this.listing.data.continuous_dates) {
              _this.setDatepickerToPickMode();
            }

            /*
           * If the user selects the same start/end date, let's close the datepicker
           * and assume they were only trying to select one day.
           */
            if (
              _this.listing.minimumBookingDays() > 1 || _this.endDatepicker.getDates().length <= 1
            ) {
              return _this.endDatepicker.hide();
            }
          };
        }(this)
      );
    }
  };

  BookingsDatepicker.prototype.initializeStartDatepicker = function() {
    return this.startDatepicker = new Datepicker({
      trigger: this.startElement,
      /*
       * Custom view to handle bookings availability display
       */
      view: new AvailabilityView(this.listing, {
        trigger: this.startElement,
        text: this.start_text(),
        isContinous: !!this.listing.data.continuous_dates
      }),
      /*
       * Limit to a single date selected at a time
       */
      model: new DatepickerModelSingle({ allowDeselection: false })
    });
  };

  BookingsDatepicker.prototype.initializeEndDatepicker = function() {
    return this.endDatepicker = new Datepicker({
      trigger: this.endElement,
      /*
       * Custom view to handle bookings availability display
       */
      view: new AvailabilityView(this.listing, {
        trigger: this.endElement,
        text: this.TEXT_END_RANGE,
        isContinous: !!this.listing.data.continuous_dates,
        endDatepicker: true
      }),
      /*
       * Custom backing model to handle logic of range and constraints
       */
      model: new ModeAndConstraintModel(this.listing)
    });
  };

  BookingsDatepicker.prototype.setDates = function(dates) {
    dates = dateUtil.sortDates(dates);
    this.startDatepicker.setDates(dates.slice(0, 1));
    if (this.endDatepicker) {
      this.endDatepicker.setDates(dates);
      this.endDatepicker.getModel().ensureDatesMeetConstraint();
    }

    /*
     * If we're specifying more than just a start date, we need
     * to set the mode to Pick.
     */
    if (dates.length > 1 && !this.listing.isOvernightBooking()) {
      this.setDatepickerToPickMode();
    }
    this.updateElementText();
    return this.trigger('datesChanged', this.getDates());
  };

  BookingsDatepicker.prototype.reset = function() {
    this.setDates([]);
    if (this.timePicker) {
      return this.timePicker.updateSelectableTimes();
    }
  };

  BookingsDatepicker.prototype.addDate = function(date) {
    /*
     * If the added date is prior to the current start date, we set the
     * start date range to that date.
     */
    var startDate;
    startDate = this.startDatepicker.getDates()[0];
    if (!startDate || startDate.getTime() > date.getTime()) {
      this.startDatepicker.addDate(date);
    }
    if (this.endDatepicker) {
      this.endDatepicker.addDate(date);
      this.endDatepicker.getModel().extendRangeToMeetConstraint(date);
    }
    return this.updateElementText();
  };

  BookingsDatepicker.prototype.removeDate = function(date) {
    var firstEndDate;
    this.startDatepicker.removeDate(date);
    if (this.endDatepicker) {
      this.endDatepicker.removeDate(date);
    }
    if (!this.startDatepicker.getDates()[0] && this.endDatepicker) {
      firstEndDate = this.endDatepicker.getDates()[0];
      if (firstEndDate) {
        this.startDatepicker.addDate(firstEndDate);
      }
    }
    return this.updateElementText();
  };

  BookingsDatepicker.prototype.getDates = function() {
    if (this.endDatepicker) {
      return this.endDatepicker.getDates();
    } else {
      return this.startDatepicker.getDates();
    }
  };

  BookingsDatepicker.prototype.updateElementText = function() {
    var endDate, endText, startDate, startText;
    startDate = _.first(this.getDates());
    startText = startDate ? this.formatDateForLabel(startDate) : 'Start';
    this.startElement.find('.calendar-text').text(startText);
    if (this.endDatepicker) {
      endDate = _.last(this.getDates());
      if (endDate) {
        endText = this.formatDateForLabel(endDate);
        this.endDatepicker.getModel().setCurrentMonth(endDate);
      } else {
        endText = 'End';
      }
      return this.endElement.find('.calendar-text').text(endText);
    }
  };

  BookingsDatepicker.prototype.setDatepickerToPickMode = function() {
    if (this.listing.minimumBookingDays() > 1) {
      return;
    }
    if (this.endDatepicker) {
      this.endDatepicker.getModel().setMode(ModeAndConstraintModel.MODE_PICK);
      return this.endDatepicker.getView().setText(this.end_text());
    }
  };

  BookingsDatepicker.prototype.setDatepickerToRangeMode = function() {
    if (this.endDatepicker) {
      this.endDatepicker.getModel().setMode(ModeAndConstraintModel.MODE_RANGE);
      return this.endDatepicker.getView().setText(this.TEXT_END_RANGE);
    }
  };

  BookingsDatepicker.prototype.datesWereChanged = function() {
    this.updateElementText();
    return this.trigger('datesChanged', this.getDates());
  };

  BookingsDatepicker.prototype.startDatepickerWasChanged = function() {
    /*
     * We want to instantly hide the start datepicker on selection
     */
    this.startDatepicker.hide();

    /*
     * Reset the end datepicker
     */
    this.setDates(this.startDatepicker.getDates());
    this.setDatepickerToRangeMode();

    /*
     * Show the end datepicker instantly
     */
    if (this.listing.isReservedHourly()) {
      this.timePicker.show();
    } else if (this.endDatepicker) {
      this.endDatepicker.show();
    }

    /*
     * Bubble event
     */
    return this.datesWereChanged();
  };

  BookingsDatepicker.prototype.formatDateForLabel = function(date) {
    return date.strftime(I18n.dateFormats['day_and_month'].replace(/%(\^|-|_)/g, '%'));
  };

  /*
   * Sets up the time picker view controller which handles the user selecting the
   * start/end times for the reservation.
   */
  BookingsDatepicker.prototype.initializeTimePicker = function() {
    var options;
    options = {
      openMinute: this.listing.data.earliest_open_minute,
      closeMinute: this.listing.data.latest_close_minute,
      minimumBookingMinutes: this.listing.data.minimum_booking_minutes
    };
    if (
      this.listingData.initial_bookings && this.listingData.initial_bookings.start_minute &&
        this.listingData.initial_bookings.end_minute
    ) {
      options.startMinute = this.listingData.initial_bookings.start_minute;
      options.endMinute = this.listingData.initial_bookings.end_minute;
    }
    this.timePicker = new TimePicker(this.listing, this.container.find('.time-picker'), options);
    this.timePicker.on(
      'change',
      function(_this) {
        return function() {
          return _this.updateTimes();
        };
      }(this)
    );
    this.updateTimes();
    return this.timePicker.updateSelectableTimes();
  };

  BookingsDatepicker.prototype.updateTimes = function() {
    this.listing.setTimes(this.timePicker.startMinute(), this.timePicker.endMinute());
    return this.trigger('timesChanged');
  };

  /*
   * Assign initial dates from a restored session or the default
   * start date.
   */
  BookingsDatepicker.prototype.assignInitialDates = function() {
    var date, endDate, i, initialDates, startDate;
    startDate = null;
    endDate = null;
    if (urlUtil.getParameterByName('start_date')) {
      startDate = new Date(urlUtil.getParameterByName('start_date'));
      if (startDate < this.listing.firstAvailableDate) {
        startDate = this.listing.firstAvailableDate;
      }
      i = 0;
      while (i < 50) {
        if (
          this.endDatepicker &&
            this.endDatepicker.getModel().canSelectDate(dateUtil.nextDateIterator(startDate)())
        ) {
          endDate = dateUtil.nextDateIterator(startDate)();
          break;
        }
        i++;
      }
    }
    if (startDate === null || endDate === null) {
      startDate = this.listing.firstAvailableDate;
      endDate = this.listing.secondAvailableDate;
    }
    initialDates = function() {
      var j, len, ref, results;
      if (this.listingData.initial_bookings) {
        /*
         * Format is:
         * {quantity: 1, dates: ['2013-11-04', ...] }
         */
        this.listing.setDefaultQuantity(this.listingData.initial_bookings.quantity);

        /*
         * Map bookings to JS dates
         */
        ref = this.listingData.initial_bookings.dates;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          date = ref[j];
          results.push(dateUtil.idToDate(date));
        }
        return results;
      } else if (this.listing.isOvernightBooking() && endDate === dateUtil.next(startDate)) {
        return [ startDate, endDate ];
      } else {
        return [ startDate ];
      }
    }.call(this);
    this.trigger('datesChanged', initialDates);
    this.setDates(initialDates);
    return this.listing.setDates(initialDates);
  };

  return BookingsDatepicker;
}();

module.exports = BookingsDatepicker;
