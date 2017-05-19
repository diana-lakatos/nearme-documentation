var AvailabilityView,
  DatepickerView,
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

DatepickerView = require('../../../components/datepicker/view');

/*
 * A view wrapper for the Datepicker to show a loading indicator while we load the date availability
 */
AvailabilityView = function(superClass) {
  extend(AvailabilityView, superClass);

  function AvailabilityView(listing, options) {
    this.listing = listing;
    if (options == null) {
      options = {};
    }
    this.isContinous = options.isContinous || false;
    this.firstUnavailable = null;
    this.activeDate = null;
    this.isEndDatepicker = options.endDatepicker;
    AvailabilityView.__super__.constructor.call(this, options);
  }

  AvailabilityView.prototype.show = function() {
    /*
     * Refresh if listing quantity has changed since last display
     * We do this to update the display of available vs unavailable dates
     */
    if (this.lastDefaultQuantity && this.listing.defaultQuantity !== this.lastDefaultQuantity) {
      this.refresh();
    }
    this.lastDefaultQuantity = this.listing.defaultQuantity;
    return AvailabilityView.__super__.show.apply(this, arguments);
  };

  AvailabilityView.prototype.renderDate = function(date, monthDate) {
    var klasses, title;
    klasses = this.classForDate(date, monthDate);
    title = null;
    if (klasses.indexOf('not-available') >= 0) {
      title = this.listing.data.date_not_available_title;
    }
    return this._render(this.dayTemplate, {
      title: title,
      year: date.getFullYear(),
      month: date.getMonth(),
      day: date.getDate(),
      dow: date.getDay(),
      klass: this.classForDate(date, monthDate)
    });
  };

  /*
   * Extend the class generation method to add disabled state if the listing quantity selection
   * exceeds the availability for a given date.
   */
  AvailabilityView.prototype.classForDate = function(date) {
    var klass, qty;
    klass = [ AvailabilityView.__super__.classForDate.apply(this, arguments) ];
    qty = this.listing.defaultQuantity;
    if (qty < 1) {
      qty = 1;
    }
    if (this.model.isSelected(date)) {
      this.activeDate = date;
    }
    if (this.listing.availabilityFor(date) < qty) {
      if (
        this.listing.isOvernightBooking() && this.isEndDatepicker &&
          this.listing.firstUnavailableDay(date)
      ) {
        klass.push('datepicker-booking-end-only');
        if (!this.firstUnavailable && this.activeDate && date >= this.activeDate) {
          this.firstUnavailable = date;
        }
      } else {
        klass.push('disabled');
        if (!this.listing.openFor(date)) {
          klass.push('closed');
        }
      }
    }
    if (this.isEndDatepicker && date < this.activeDate) {
      klass.push('before-start-date');
    }
    if (
      this.listing.isOvernightBooking() && this.firstUnavailable && date > this.firstUnavailable
    ) {
      klass.push('not-available');
    }

    /*
     * Our custom model keeps track of whether dates were added via the range
     * selection.
     */
    if (this.model.isRangeDate && this.model.isRangeDate(date)) {
      if (this.isContinous) {
        klass.push('implicit');
      } else {
        klass.push('active');
      }
    }
    return klass.join(' ');
  };

  return AvailabilityView;
}(DatepickerView);

module.exports = AvailabilityView;
