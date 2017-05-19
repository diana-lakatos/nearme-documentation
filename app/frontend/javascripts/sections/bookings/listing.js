var Availability,
  BookingListing,
  FixedPriceCalculator,
  HourlyAvailability,
  HourlyPriceCalculator,
  PerUnitPriceCalculator,
  PriceCalculator,
  ScheduleAvailability,
  SubscriptionPriceCalculator,
  asEvented,
  dateUtil;

SubscriptionPriceCalculator = require('./price_calculator/subscription_price_calculator');

HourlyPriceCalculator = require('./price_calculator/hourly_price_calculator');

FixedPriceCalculator = require('./price_calculator/fixed_price_calculator');

PerUnitPriceCalculator = require('./price_calculator/per_unit_price_calculator');

PriceCalculator = require('./price_calculator');

Availability = require('./availability/availability');

ScheduleAvailability = require('./availability/schedule_availability');

HourlyAvailability = require('./availability/hourly_availability');

dateUtil = require('../../lib/utils/date');

asEvented = require('asevented');

/*
 * Each Listing has it's own object which keeps track of number booked, availability etc.
 */
BookingListing = function() {
  asEvented.call(BookingListing.prototype);

  BookingListing.prototype.defaultQuantity = 1;

  function BookingListing(data, container) {
    this.data = data;
    this.container = container;
    this.id = parseInt(this.data.id, 10);
    this.bookedDatesArray = [];
    this.bookedDateAvailability = 0;
    this.maxQuantity = this.data.quantity;
    this.initial_bookings = this.data.initial_bookings || {};
    this.possibleUnits = this.data.possible_units;
    this.pricings = this.data.pricings;
    this.no_action = this.data.no_action;
    if (this.withCalendars()) {
      if (this.canBeSubscribed()) {
        this.firstAvailableDate = this.minimumDate = dateUtil.idToDate(this.data.minimum_date);
        this.maximumDate = dateUtil.idToDate(this.data.maximum_date);
        this.availability = new ScheduleAvailability(this.data.availability);
      } else {
        this.firstAvailableDate = dateUtil.idToDate(this.data.first_available_date);
        this.secondAvailableDate = dateUtil.idToDate(this.data.second_available_date);
        if (this.canReserveHourly()) {
          this.availability = new HourlyAvailability(
            this.data.availability,
            this.data.hourly_availability_schedule,
            this.data.hourly_availability_schedule_url
          );
        } else {
          this.availability = new Availability(this.data.availability);
        }
        this.minimumDate = dateUtil.idToDate(this.data.minimum_date);
        this.maximumDate = dateUtil.idToDate(this.data.maximum_date);
        this.favourablePricingRate = this.data.favourable_pricing_rate;
        this.pricesByHours = this.data.prices_by_hours;
        this.pricesByDays = this.data.prices_by_days;
        this.pricesByNights = this.data.prices_by_nights;
        this.hourlyPrice = this.data.hourly_price_cents;
        this.minimumBookingMinutes = this.data.minimum_booking_minutes;
      }
    } else {
      this.fixedPrice = this.data.fixed_price_cents;
      this.exclusivePrice = this.data.exclusive_price_cents;
    }
  }

  BookingListing.prototype.setDefaultQuantity = function(qty) {
    this.trigger('quantityChanged');
    if (qty >= 0) {
      return this.defaultQuantity = qty;
    }
  };

  BookingListing.prototype.setHourlyBooking = function(hourlyBooking) {
    if (hourlyBooking) {
      this.bookedDatesArray = this.bookedDatesArray.slice(0, 1);
    }
    return this.data.action_hourly_booking = hourlyBooking;
  };

  BookingListing.prototype.getId = function() {
    return this.id;
  };

  BookingListing.prototype.getQuantity = function() {
    return this.defaultQuantity;
  };

  BookingListing.prototype.getMaxQuantity = function() {
    return this.maxQuantity;
  };

  BookingListing.prototype.hasFavourablePricingRate = function() {
    return this.favourablePricingRate;
  };

  /*
   * If the listing is an overnight booking we have to select +1 day in calendar
   */
  BookingListing.prototype.minimumBookingDays = function() {
    if (this.isOvernightBooking()) {
      return this.data.minimum_booking_days + 1;
    } else {
      return this.data.minimum_booking_days;
    }
  };

  BookingListing.prototype.onlyRfqAction = function() {
    return this.possibleUnits.length === 0 && this.data.action_rfq;
  };

  BookingListing.prototype.canReserveHourly = function() {
    return this.possibleUnits.indexOf('hour') > -1;
  };

  BookingListing.prototype.canReserveDaily = function() {
    return this.possibleUnits.indexOf('day') > -1 || this.possibleUnits.indexOf('night') > -1;
  };

  BookingListing.prototype.canBePurchased = function() {
    return this.possibleUnits.indexOf('item') > -1;
  };

  BookingListing.prototype.canBeSubscribed = function() {
    return this.possibleUnits.indexOf('subscription_day') > -1 ||
      this.possibleUnits.indexOf('subscription_month') > -1;
  };

  BookingListing.prototype.isReservedHourly = function() {
    return this.container.find('.pricing-tabs li.active').data('unit') === 'hour';
  };

  BookingListing.prototype.isSubscriptionBooking = function() {
    return this.container.find('.pricing-tabs li.active').data('unit') &&
      this.container.find('.pricing-tabs li.active').data('unit').indexOf('subscription') > -1;
  };

  BookingListing.prototype.isPurchaseAction = function() {
    return $('.pricing-tabs li.active').data('unit') === 'item';
  };

  BookingListing.prototype.isOvernightBooking = function() {
    return this.container.find('.pricing-tabs li.active').data('unit') === 'night';
  };

  BookingListing.prototype.isFixedBooking = function() {
    return this.data.booking_type === 'schedule';
  };

  BookingListing.prototype.withCalendars = function() {
    return this.canBeSubscribed() ||
      (this.canReserveHourly() || this.canReserveDaily()) && this.data.first_available_date != null;
  };

  BookingListing.prototype.isReservedDaily = function() {
    return this.container.find('.pricing-tabs li.active').data('unit') === 'day';
  };

  BookingListing.prototype.isPerUnitBooking = function() {
    return this.data.action_price_per_unit;
  };

  BookingListing.prototype.currentUnit = function() {
    return this.container.find('.pricing-tabs li.active').data('unit');
  };

  /*
   * Returns whether the date is within the bounds available for booking
   */
  BookingListing.prototype.dateWithinBounds = function(date) {
    var time;
    time = date.getTime();
    if (time < this.minimumDate.getTime()) {
      return false;
    }
    if (time > this.maximumDate.getTime()) {
      return false;
    }
    return true;
  };

  BookingListing.prototype.canBookDate = function(date, min) {
    /*
     * clt = current location zone time
     */
    var clt, period_starts;
    clt = new Date();
    clt.setHours(clt.getHours() + this.data.zone_offset);
    clt.setHours(clt.getHours() + clt.getTimezoneOffset() / 60);
    period_starts = new Date(date);
    period_starts.setMinutes(min % 60);
    period_starts.setHours(parseInt(min / 60));
    if (period_starts.getTime() < clt.getTime()) {
      return false;
    }
    return this.availabilityFor(date, min) >= this.defaultQuantity ||
      this.isOvernightBooking() && this.firstUnavailableDay(date, min);
  };

  BookingListing.prototype.availabilityFor = function(date, minute) {
    if (minute == null) {
      minute = null;
    }
    return this.availability.availableFor(date, minute);
  };

  BookingListing.prototype.firstUnavailableDay = function(date, minute) {
    if (minute == null) {
      minute = null;
    }
    return this.availability.firstUnavailableDay(date, minute);
  };

  BookingListing.prototype.bookItOutMin = function() {
    return this.data.book_it_out_minimum_qty;
  };

  BookingListing.prototype.bookItOutDiscount = function() {
    return this.data.book_it_out_discount;
  };

  BookingListing.prototype.bookItOutAvailable = function() {
    return this.isFixedBooking() && this.data.book_it_out_discount > 0;
  };

  BookingListing.prototype.exclusivePriceAvailable = function() {
    return this.data.exclusive_price_cents > 0;
  };

  BookingListing.prototype.bookItOutAvailableForDate = function() {
    return this.bookItOutAvailable() &&
      this.fixedAvailability() >= this.data.book_it_out_minimum_qty;
  };

  BookingListing.prototype.fixedAvailability = function() {
    return this.bookedDateAvailability;
  };

  BookingListing.prototype.openFor = function(date) {
    return this.availability.openFor(date);
  };

  BookingListing.prototype.isBooked = function() {
    var hasDate, hasTime;
    if (this.canBePurchased()) {
      return true;
    }
    hasDate = this.bookedDates().length > 0;
    hasTime = this.isReservedHourly() && this.withCalendars() ? this.minutesBooked() > 0 : true;
    return hasDate && hasTime;
  };

  /*
   * Return the days where there exist bookings
   */
  BookingListing.prototype.bookedDays = function() {
    var date, i, len, ref, results;
    ref = this.bookedDates();
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      date = ref[i];
      results.push(dateUtil.toId(date));
    }
    return results;
  };

  /*
   * Return the days where bookings exist as Date objects
   */
  BookingListing.prototype.bookedDates = function() {
    return this.bookedDatesArray;
  };

  /*
   * Return the subtotal for booking this listing
   */
  BookingListing.prototype.bookingSubtotal = function(book_it_out, exclusive_price) {
    if (book_it_out == null) {
      book_it_out = false;
    }
    if (exclusive_price == null) {
      exclusive_price = false;
    }
    if (this.no_action) {
      return;
    }
    if (book_it_out) {
      return this.priceCalculator().getPriceForBookItOut();
    } else if (exclusive_price) {
      return this.exclusivePrice;
    } else if (this.isSubscriptionBooking()) {
      return this.priceCalculator().getPrice();
    } else if (this.canBePurchased()) {
      return this.fixedPrice * this.getQuantity();
    } else {
      return this.priceCalculator().getPrice();
    }
  };

  BookingListing.prototype.bookItOutSubtotal = function() {
    return this.priceCalculator().getPriceForBookItOut();
  };

  BookingListing.prototype.priceCalculator = function() {
    if (this.isReservedHourly()) {
      return new HourlyPriceCalculator(this);
    } else if (this.isPerUnitBooking()) {
      return new PerUnitPriceCalculator(this);
    } else if (this.isFixedBooking()) {
      return new FixedPriceCalculator(this);
    } else if (this.isSubscriptionBooking()) {
      return new SubscriptionPriceCalculator(this);
    } else {
      return new PriceCalculator(this);
    }
  };

  /*
   * Set the dates active on this listing for booking
   */
  BookingListing.prototype.setDates = function(dates) {
    return this.bookedDatesArray = dates;
  };

  /*
   * Set the start/end minutes for an hourly listing reservation.
   */
  BookingListing.prototype.setTimes = function(start, end) {
    this.startMinute = start;
    return this.endMinute = end;
  };

  BookingListing.prototype.setStartOn = function(start) {
    return this.startOn = start;
  };

  BookingListing.prototype.setEndOn = function(end) {
    return this.endOn = end;
  };

  BookingListing.prototype.minutesBooked = function() {
    if (!(this.startMinute != null && this.endMinute != null)) {
      return 0;
    }
    return this.endMinute - this.startMinute;
  };

  /*
   * Check the selected dates are valid with the quantity
   * and availability
   */
  BookingListing.prototype.bookingValid = function() {
    var date, i, len, ref;
    ref = this.bookedDates();
    for (i = 0, len = ref.length; i < len; i++) {
      date = ref[i];
      if (this.availabilityFor(date) < this.getQuantity()) {
        return false;
      }
    }
    return true;
  };

  BookingListing.prototype.reservationOptions = function() {
    var options;
    options = {
      quantity: this.initial_bookings.quantity || this.getQuantity(),
      book_it_out: this.initial_bookings.book_it_out,
      exclusive_price: this.initial_bookings.exclusive_price,
      guest_notes: this.initial_bookings.guest_notes,
      dates: this.initial_bookings.dates || this.bookedDays()
    };
    if (this.withCalendars()) {
      /*
       * Hourly reserved listings send through the start/end minute of
       * the day with the booking request.
       */
      if (this.isReservedHourly()) {
        options.start_minute = this.initial_bookings.start_minute || this.startMinute;
        options.end_minute = this.initial_bookings.end_minute || this.endMinute;
      }
      if (this.isSubscriptionBooking()) {
        options.start_on = this.initial_bookings.start_on || this.startOn;
        options.end_on = this.initial_bookings.end_on || this.endOn;
      }
    }
    return options;
  };

  return BookingListing;
}();

module.exports = BookingListing;
