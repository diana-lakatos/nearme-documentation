var DatepickerModel,
  ModeAndConstraintModel,
  dateUtil,
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

DatepickerModel = require('../../../components/datepicker/model');

dateUtil = require('../../../lib/utils/date');

/*
 * Custom backing model for datepicker date selection
 * Applies special semantics specific for booking selection:
 *   * Multiple mode (select range, add/remove dates)
 *   * Require minimum date selection (automatically constraint selection)
 *
 */
ModeAndConstraintModel = function(superClass) {
  /*
   * Modes for the selection type. The different modes have different semantics when
   * a date is toggled.
   */
  extend(ModeAndConstraintModel, superClass);

  ModeAndConstraintModel.MODE_RANGE = 'range';

  ModeAndConstraintModel.MODE_PICK = 'pick';

  ModeAndConstraintModel.prototype.mode = ModeAndConstraintModel.MODE_RANGE;

  function ModeAndConstraintModel(listing) {
    ModeAndConstraintModel.__super__.constructor.apply(this, arguments);
    this.listing = listing;

    /*
     * "Range dates" are dates which haven't been explicitly added,
     * but are implicitly added through range selection or as a requirement
     * for minimum consecutive days. We keep track of these so we can display
     * them differently on the view.
     */
    this.rangeDates = {};
  }

  ModeAndConstraintModel.prototype.setMode = function(mode) {
    return this.mode = mode;
  };

  ModeAndConstraintModel.prototype.minDays = function() {
    return this.listing.minimumBookingDays() || 1;
  };

  ModeAndConstraintModel.prototype.toggleDate = function(date) {
    var startDate;
    if (!this.canSelectDate(date)) {
      return;
    }
    startDate = this.getDates().slice(0, 1)[0];
    if (this.listing.isOvernightBooking() && !this.areConsecutiveDays(startDate, date)) {
      return;
    }
    switch (this.mode) {
      case ModeAndConstraintModel.MODE_RANGE:
        /*
         * Return if there is no start date, or if date selected
         * is before the start date (can't select backwards)
         */
        if (!startDate || startDate.getTime() > date.getTime()) {
          return;
        }

        /*
         * Don't allow making a range selection that doesn't meet
         * the consecutive days constraint
         */
        if (this.minDays() > 1 && this.consecutiveDaysBetween(startDate, date) < this.minDays()) {
          return;
        }

        /*
         * Reset the range
         */
        this.setDates([ startDate ]);

        /*
         * Extend the range
         */
        this.setRangeTo(date);
        this.extendRangeToMeetConstraint(date);
        return this.trigger('rangeApplied');
      case ModeAndConstraintModel.MODE_PICK:
        if (this.isSelected(date)) {
          this.removeDate(date);
          return this.reduceRangeToMeetConstraint(date);
        } else {
          this.addDate(date);
          return this.extendRangeToMeetConstraint(date);
        }
    }
  };

  /*
   * Set the date range to the specified date, from the first date.
   */
  ModeAndConstraintModel.prototype.setRangeTo = function(date) {
    var current, startDate;
    if (!this.listing.dateWithinBounds(date)) {
      return;
    }
    startDate = this.getDates()[0] || date;

    /*
     * If the to-date is before the start-date, then we set both ends to
     * the same date (i.e. no range)
     */
    if (startDate.getTime() > date.getTime()) {
      startDate = date;
    }
    current = startDate;
    while (dateUtil.toId(current) !== dateUtil.toId(date)) {
      if (this.canSelectDate(current)) {
        this.addRangeDate(current);
      }
      current = dateUtil.next(current);
    }
    if (this.canSelectDate(date)) {
      return this.addDate(date);
    }
  };

  /*
   * Wrap remove date to clear the previous 'range date' state, a special
   * state for this specific use case.
   */
  ModeAndConstraintModel.prototype.removeDate = function(date) {
    this.clearRangeDate(date);
    return ModeAndConstraintModel.__super__.removeDate.apply(this, arguments);
  };

  /*
   * Wrapper for addDate that sets the date as an range-added date.
   */
  ModeAndConstraintModel.prototype.addRangeDate = function(date) {
    this.setRangeDate(date);
    return this.addDate(date);
  };

  /*
   * Test whether a date was implicitly added as a 'range date'
   */
  ModeAndConstraintModel.prototype.isRangeDate = function(date) {
    return this.rangeDates[dateUtil.toId(date)];
  };

  /*
   * Flag whether a date was implicitly selected via a range selection
   * (and also constraint requirement)
   */
  ModeAndConstraintModel.prototype.setRangeDate = function(date) {
    return this.rangeDates[dateUtil.toId(date)] = true;
  };

  /*
   * Clear that a date was selected via range selection
   */
  ModeAndConstraintModel.prototype.clearRangeDate = function(date) {
    return this.rangeDates[dateUtil.toId(date)] = false;
  };

  /*
   * Returns whether or not a date is 'selectable' based on the listing availability
   */
  ModeAndConstraintModel.prototype.canSelectDate = function(date) {
    return this.listing.canBookDate(date);
  };

  /*
   * Ensure all included dates meet the consecutive days constraint, and
   * extend them if they don't.
   */
  ModeAndConstraintModel.prototype.ensureDatesMeetConstraint = function() {
    var date, i, len, ref, results;
    ref = this.getDates();
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      date = ref[i];
      results.push(this.extendRangeToMeetConstraint(date));
    }
    return results;
  };

  /*
   * Returns whether or not there are minDays available days booked around
   * the specified date.
   */
  ModeAndConstraintModel.prototype.meetsConstraint = function(date) {
    return this.consecutiveDays(date) >= this.minDays();
  };

  /*
   * Starting at a given date, scan dates validate that it meets the consecutive bookings
   * constraint. If it doesn't, add next available dates until it does.
   */
  ModeAndConstraintModel.prototype.extendRangeToMeetConstraint = function(date) {
    /*
     * Algorithm for extending to meet the min days constraint
     */
    var bookingExtensionAlgorithm;
    bookingExtensionAlgorithm = function(_this) {
      return function(dateIterator) {
        /*
         * We try to keep going until the target date meets the
         * 'consecutive days' constraint.
         */
        var currentDate, results;
        results = [];
        while (!_this.meetsConstraint(date)) {
          currentDate = dateIterator();

          /*
           * If we fall outside of the bookable dates for this listing,
           * break our loop.
           */
          if (!_this.listing.dateWithinBounds(currentDate)) {
            break;
          }

          /*
           * If we can select this date, we add it.
           */
          if (_this.canSelectDate(currentDate)) {
            results.push(_this.addRangeDate(currentDate));
          } else if (_this.listing.isOvernightBooking()) {
            break;
          } else {
            results.push(void 0);
          }
        }
        return results;
      };
    }(this);

    /*
     * Try to extend forward first, then work backwards.
     * We go backwards due to an edge case at the end of the bookable range,
     * where we need to add dates in the past to constraint the selection.
     */
    bookingExtensionAlgorithm(dateUtil.nextDateIterator(date));
    if (!this.listing.isOvernightBooking()) {
      return bookingExtensionAlgorithm(dateUtil.previousDateIterator(date));
    }
  };

  /*
   * Starting from a given date, scan the dates around it to ensure that the act of removing that
   * date hasn't invalidated the minimum date selection constraints. If it has, remove relevant
   * dates to restore selected dates to a state that reflects the minimum consecutive days constraint.
   */
  ModeAndConstraintModel.prototype.reduceRangeToMeetConstraint = function(date) {
    /*
     * Iterates with an advancer through the selected dates adjacent to the starting date,
     * and validates that that date meets the restrictions.
     *
     * Three cases:
     *   * Date is selected. We validate that it still meets the constraints
     *     * If it does, we are done.
     *     * If it doesn't, we unselect the date and try the next one
     *   * Date is not selectable
     *     * We move to the next date - as it being unselectable isn't included
     *       in 'consecutive' semantics.
     *   * Date is not selected
     *     * We are done - as we assume other dates already meet requirements.
     */
    var bookingRemovalAlgorithm;
    bookingRemovalAlgorithm = function(_this) {
      return function(dateIterator) {
        var currentDate, results;
        currentDate = dateIterator();
        results = [];
        while (currentDate) {
          if (!_this.listing.dateWithinBounds(currentDate)) {
            break;
          }
          if (_this.canSelectDate(currentDate)) {
            if (!_this.isSelected(currentDate)) {
              break;
            }
            if (_this.meetsConstraint(currentDate)) {
              break;
            }

            /*
             * Can no longer have this date selected
             */
            _this.removeDate(currentDate);
          }
          results.push(currentDate = dateIterator());
        }
        return results;
      };
    }(this);

    /*
     * Check both future and past connected selected dates are now valid
     */
    bookingRemovalAlgorithm(dateUtil.previousDateIterator(date));
    return bookingRemovalAlgorithm(dateUtil.nextDateIterator(date));
  };

  /*
   * Return the consecutive days currently booked at the date, *or*
   * the required minumum consecutive days - whatever is less.
   */
  ModeAndConstraintModel.prototype.consecutiveDays = function(date) {
    var consecutiveDaysCount, countingAlgorithm;
    if (!this.isSelected(date)) {
      return 0;
    }
    consecutiveDaysCount = 1;
    countingAlgorithm = function(_this) {
      return function(dateIterator) {
        /*
         * We're trying to count the "consecutive days" total for the target date.
         * That is the number of connected days before or after the current date,
         * ignoring dates that aren't available for booking.
         */
        var currentDate, results;
        results = [];
        while (consecutiveDaysCount < _this.minDays()) {
          currentDate = dateIterator();
          if (!_this.listing.dateWithinBounds(currentDate)) {
            break;
          }
          if (_this.isSelected(currentDate)) {
            /*
             * We increment our counter if the date is selected
             */
            results.push(consecutiveDaysCount++);
          } else {
            /*
             * As soon as we encounter a date that is selectable, but isn't selected
             * we can break our counting loop, as it is no longer consecutive.
             */
            if (_this.canSelectDate(currentDate)) {
              break;
            } else {
              results.push(void 0);
            }
          }
        }
        return results;
      };
    }(this);

    /*
     * Count backwards and forwards, using the same algorithm with a different
     * iteration function.
     */
    countingAlgorithm(dateUtil.previousDateIterator(date));
    countingAlgorithm(dateUtil.nextDateIterator(date));
    return consecutiveDaysCount;
  };

  /*
   * Return a count of the available consecutive days between two dates, or the
   * minimum required consecutive days - whichever is less.
   */
  ModeAndConstraintModel.prototype.consecutiveDaysBetween = function(startDate, endDate) {
    var count, current;
    if (endDate.getTime() < startDate.getTime()) {
      return 0;
    }
    count = 0;
    current = startDate;
    while (count < this.minDays() && current.getTime() <= endDate.getTime()) {
      if (this.canSelectDate(current)) {
        count += 1;
      }
      current = dateUtil.next(current);
    }
    return count;
  };

  /*
   * Checks whether range doesn't contain unavailable days
   */
  ModeAndConstraintModel.prototype.areConsecutiveDays = function(startDate, endDate) {
    var current;
    if (endDate.getTime() < startDate.getTime()) {
      return false;
    }
    current = startDate;
    while (current.getTime() <= endDate.getTime()) {
      if (
        !this.canSelectDate(current) ||
          endDate.toDateString() !== current.toDateString() &&
            this.listing.firstUnavailableDay(current)
      ) {
        return false;
      }
      current = dateUtil.next(current);
    }
    return true;
  };

  return ModeAndConstraintModel;
}(DatepickerModel);

module.exports = ModeAndConstraintModel;
