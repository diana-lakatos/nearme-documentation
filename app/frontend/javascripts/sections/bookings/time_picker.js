/* global I18n */
var PositionedView,
  TimePicker,
  asEvented,
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

asEvented = require('asevented');

require('../../../vendor/gf3-strftime');

PositionedView = require('../../components/lib/positioned_view');

TimePicker = function() {
  var BOOKING_STEP, DEFAULT_STEPS, View;

  asEvented.call(TimePicker.prototype);

  BOOKING_STEP = 15;

  DEFAULT_STEPS = 4;

  function TimePicker(listing, container, options) {
    this.listing = listing;
    this.container = container;
    if (options == null) {
      options = {};
    }
    this.allMinutes = [];
    this.disabledStartTimes = [];
    this.disabledEndTimes = [];
    this.openMinute = options.openMinute != null ? options.openMinute : 9 * 60;
    this.closeMinute = options.closeMinute || 18 * 60;
    this.minimumBookingMinutes = options.minimumBookingMinutes;
    if (options.startMinute != null) {
      this.initialStartMinute = options.startMinute;
    }
    this.initialStartMinute || (this.initialStartMinute = this.openMinute);
    if (options.endMinute != null) {
      this.initialEndMinute = options.endMinute;
    }
    this.initialEndMinute || (this.initialEndMinute = this.openMinute + this.minimumBookingMinutes);
    this.view = new View({ positionTarget: this.container }, this.listing);
    this.view.appendTo($('body'));
    this.view.closeIfClickedOutside(this.container);
    this.startTime = this.view.startTime;
    this.endTime = this.view.endTime;
    this.loading = this.view.loading;
    this.changeDisplayedHour();

    /*
     * Populate the time selects based on the open hours
     */
    this.populateTimeOptions();
    this.bindEvents();
    if (this.initialStartMinute) {
      this.startTime.val('' + this.initialStartMinute);
      this.startTime.trigger('change');
    }
    if (this.initialEndMinute) {
      this.endTime.val('' + this.initialEndMinute);
      this.endTime.trigger('change');
    }
    this.disableEndTimesFromStartTime();
  }

  TimePicker.prototype.bindEvents = function() {
    this.container.on(
      'click',
      function(_this) {
        return function() {
          _this.view.toggle();
          return _this.loading.hide();
        };
      }(this)
    );
    this.startTime.on(
      'change',
      function(_this) {
        return function() {
          _this.disableEndTimesFromStartTime();
          return _this.trigger('change');
        };
      }(this)
    );
    this.endTime.on(
      'change',
      function(_this) {
        return function() {
          return _this.trigger('change');
        };
      }(this)
    );
    return this.bind(
      'change',
      function(_this) {
        return function() {
          return _this.changeDisplayedHour();
        };
      }(this)
    );
  };

  TimePicker.prototype.show = function() {
    return this.view.show();
  };

  TimePicker.prototype.hide = function() {
    return this.view.hide();
  };

  TimePicker.prototype.changeDisplayedHour = function() {
    return this.container.find('.time-text').text(this.formatMinute(this.startTime.val()));
  };

  /*
   * Return the selected start minute
   */
  TimePicker.prototype.startMinute = function() {
    var val;
    val = this.startTime.val();
    if (val) {
      return parseInt(val, 10);
    }
  };

  /*
   * Return the selected end minute
   */
  TimePicker.prototype.endMinute = function() {
    var val;
    val = this.endTime.val();
    if (val) {
      return parseInt(val, 10);
    }
  };

  /*
   * Set the selectable time range for potential valid opening hours for the listing.
   * Creates a set of <option> elements in the relevent <select> containers.
   */
  TimePicker.prototype.populateTimeOptions = function() {
    var curr, options, steps;
    if (this.closeMinute <= this.openMinute) {
      return;
    }

    /*
     * Reset the allowed minute list
     */
    this.allMinutes = [];

    /*
     * Build up a list of minutes and select option html elements
     */
    options = [];
    curr = this.openMinute;
    while (curr <= this.closeMinute) {
      this.allMinutes.push(curr);
      options.push("<option value='" + curr + "'>" + this.formatMinute(curr) + '</option>');
      curr += BOOKING_STEP;
    }

    /*
     * Start time is all but the last end time
     */
    this.startTime.html(_.difference(options, [ _.last(options) ]).join('\n'));

    /*
     * End time is all but the first start time
     */
    steps = _.difference(options, [ options[0] ]);

    /*
     * Add the selected attribute to the nth element in the array
     */
    steps[DEFAULT_STEPS - 1] = $('<div>')
      .append($(steps[DEFAULT_STEPS - 1]).attr('selected', 'selected'))
      .html();
    this.endTime.html(steps.join('\n'));
    this.view.startTimeDidChange();
    return this.view.endTimeDidChange();
  };

  /*
   * Update the selectable options  based on the hourly
   * availability schedule of the listing for the current date.
   */
  TimePicker.prototype.updateSelectableTimes = function() {
    var date;
    date = this.listing.bookedDates()[0];

    /*
     * Load schedule runs instantly if available, or fires an ajax
     * requests to load the hourly schedule for the date then returns.
     */
    this.loading.show();
    return this.listing.availability.loadSchedule(
      date,
      function(_this) {
        return function() {
          /*
         * Ignore callback if no longer selected this date
         */
          var i, len, min, ref;
          if (date.getTime() !== _this.listing.bookedDates()[0].getTime()) {
            return;
          }

          /*
         * Build up a new list of disabled start/end times
         */
          _this.disabledStartTimes = [];
          _this.disabledEndTimes = [];
          ref = _this.allMinutes;
          for (i = 0, len = ref.length; i < len; i++) {
            min = ref[i];
            if (!_this.listing.canBookDate(date, min)) {
              /*
             * If the minute is unbookable, can't start on that minute, and
             * therefore can't end STEP minutes after that.
             */
              _this.disabledStartTimes.push(min);
              _this.disabledEndTimes.push(min + BOOKING_STEP);
              /*
              * We want to disable minutes that are unbookable because of
              * MinimumBookingMinutes constraint. If 11:30 is unbookable then
              * 10:45, 11:00, 11:15 should be unbookable
              */
              if (!_this.listing.canBookDate(date, ref[i-1])) {
                _this.disabledStartTimes.push(min - _this.listing.minimumBookingMinutes);
              }
            }
          }
          _this.minutesWhichCantBeBooked = _this.closeMinute - _this.minimumBookingMinutes +
            BOOKING_STEP;
          while (_this.minutesWhichCantBeBooked <= _this.closeMinute) {
            _this.disabledStartTimes.push(_this.minutesWhichCantBeBooked);
            _this.minutesWhichCantBeBooked += BOOKING_STEP;
          }

          /*
         * Set the disabled start times
         */
          _this.setDisabledTimesForSelect(_this.startTime, _this.disabledStartTimes);

          /*
         * Automatically pick the first available start-time
         */
          if (!_this.startMinute()) {
            min = _.difference(_this.allMinutes, _this.disabledStartTimes)[0];
            if (min) {
              _this.startTime.val(min).trigger('change');
            }
          }

          /*
         * Disable the relevant end-times based on the available end times
         * and also the current start time selected.
         */
          _this.disableEndTimesFromStartTime();

          /*
         * Hide the loading state
         */
          _this.loading.hide();

          /*
         * We trigger change, because the selected times could have potentially
         * changed.
         */
          return _this.trigger('change');
        };
      }(this)
    );
  };

  TimePicker.prototype.setDisabledTimesForSelect = function(select, minutes) {
    var i, len, minute, results;
    select.find('option').prop('disabled', false);
    results = [];
    for (i = 0, len = minutes.length; i < len; i++) {
      minute = minutes[i];
      results.push(select.find('option[value=' + minute + ']').prop('disabled', true));
    }
    return results;
  };

  TimePicker.prototype.disableEndTimesFromStartTime = function() {
    var after, before, disable, firstAfter, min, start, usable;
    start = this.startMinute();
    if (start != null) {
      /*
       * We disable all times before or at the current start time + minimumBookingMinutes
       */
      before = function() {
        var i, len, ref, results;
        ref = this.allMinutes;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          min = ref[i];
          if (min <= start + this.minimumBookingMinutes - BOOKING_STEP) {
            results.push(min);
          }
        }
        return results;
      }.call(this);

      /*
       * We disable any time after the first unavailable end-time,
       * as a time booking needs to be contiguous.
       */
      firstAfter = _.detect(this.disabledEndTimes, function(min) {
        return min > start + BOOKING_STEP;
      });
      after = function() {
        var i, len, ref, results;
        ref = this.allMinutes;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          min = ref[i];
          if (min >= firstAfter) {
            results.push(min);
          }
        }
        return results;
      }.call(this);

      /*
       * Combine the two sets for the times to disable
       */
      disable = _.union(this.disabledEndTimes, before, after);
    } else {
      disable = this.allMinutes;
    }

    /*
     * Disable the minute options in the array for the end time picker
     */
    this.setDisabledTimesForSelect(this.endTime, disable);

    /*
     * If we don't have a valid end time now, assign a default based on the next
     * available end time.
     */
    if (!this.endMinute()) {
      usable = this.endTime.find('option:not(:disabled)')[0];
      if (usable) {
        return this.endTime.val(usable.value).trigger('change');
      }
    }
  };

  /*
   * Return a minute of the day formatted in h:mmpm
   */
  TimePicker.prototype.formatMinute = function(minute) {
    var date, hours, minutes;
    hours = parseInt(minute / 60, 10);
    minutes = minute % 60;
    date = new Date();
    date.setHours(hours, minutes);
    return date.strftime(I18n.timeFormats['short'].replace('-', ''));
  };

  View = function(superClass) {
    extend(View, superClass);

    View.prototype.viewTemplate = '<div class="datepicker-header">\n  Time\n</div>\n\n\n<div class="datepicker-text">\n  <div class="datepicker-text-fadein">Select booking duration</div>\n</div>\n<div class="datepicker-text">\n  <div class="datepicker-text-fadein timezone"></div>\n</div>\n\n<div class="time-wrapper">\n  <div class="time-start">\n    <span><label></label><i class="ico-chevron-down"></i></span>\n    <select />\n  </div>\n  <span class="ico-arrow-right">\n  </span>\n  <div class="time-end">\n    <span><label></label><i class="ico-chevron-down"></i></span>\n    <select />\n  </div>\n\n  <div class="datepicker-loading" style="display: none"></div>\n</div>';

    View.prototype.defaultOptions = { containerClass: 'dnm-datepicker' };

    function View(options1, listing) {
      this.options = options1;
      this.listing = listing;
      this.options = $.extend({}, this.defaultOptions, this.options);
      View.__super__.constructor.call(this, this.options);
      this.container.html(this.viewTemplate);
      this.startTime = this.container.find('.time-start select');
      this.startTimeSpan = this.container.find('.time-start span label');
      this.endTime = this.container.find('.time-end select');
      this.endTimeSpan = this.container.find('.time-end span label');
      this.loading = this.container.find('.datepicker-loading');
      this.timezone = this.container.find('.timezone');
      this.bindEvents();
    }

    View.prototype.bindEvents = function() {
      this.startTime.on(
        'change',
        function(_this) {
          return function() {
            return _this.startTimeDidChange();
          };
        }(this)
      );
      this.endTime.on(
        'change',
        function(_this) {
          return function() {
            return _this.endTimeDidChange();
          };
        }(this)
      );
      return this.addTimezoneInfo();
    };

    View.prototype.startTimeDidChange = function() {
      return this.startTimeSpan.text(this.startTime.find('option:selected').text());
    };

    View.prototype.endTimeDidChange = function() {
      return this.endTimeSpan.text(this.endTime.find('option:selected').text());
    };

    View.prototype.addTimezoneInfo = function() {
      if (this.listing.data.timezone_info != null) {
        return this.timezone.text(this.listing.data.timezone_info);
      }
    };

    return View;
  }(PositionedView);

  return TimePicker;
}();

module.exports = TimePicker;
