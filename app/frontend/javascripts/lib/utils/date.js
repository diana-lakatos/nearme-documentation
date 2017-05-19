/* global I18n */
var UtilDate;

UtilDate = {
  MONTHS: [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ],
  DAYS: [ 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday' ],
  toClassName: function(date) {
    return 'd-' + this.toId(date);
  },
  toId: function(date) {
    var f;
    if (typeof date === 'string' || date instanceof String) {
      return date;
    }
    f = function(i) {
      if (i < 10) {
        return '0' + i;
      } else {
        return i;
      }
    };
    return date.getFullYear() + '-' + f(date.getMonth() + 1) + '-' + f(date.getDate());
  },
  idToDate: function(dateId) {
    var matches, month_names;
    if (!dateId) {
      return null;
    }
    if (dateId instanceof Date) {
      return dateId;
    }
    month_names = new RegExp(I18n.abbrMonthNames);
    if (dateId.match(month_names)) {
      return new Date(dateId);
    }
    matches = dateId.match(/^([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})$/);
    if (matches) {
      return new Date(
        parseInt(matches[1], 10),
        parseInt(matches[2], 10) - 1,
        parseInt(matches[3], 10),
        0,
        0,
        0,
        0
      );
    }
    return null;
  },
  suffix: function(date) {
    switch (date.getDate()) {
      case 1:
      case 21:
      case 31:
        return 'st';
      case 2:
      case 22:
        return 'nd';
      case 3:
      case 23:
        return 'rd';
      default:
        return 'th';
    }
  },
  advance: function(date, options) {
    var days, months, years;
    if (options == null) {
      options = {};
    }
    months = options.months || 0;
    days = options.days || 0;
    years = options.years || 0;
    return new Date(
      date.getFullYear() + years,
      date.getMonth() + months,
      date.getDate() + days,
      0,
      0,
      0
    );
  },
  next: function(date) {
    return this.advance(date, { days: 1 });
  },
  previous: function(date) {
    return this.advance(date, { days: -1 });
  },
  nextMonth: function(date) {
    return this.advance(date, { months: 1 });
  },
  previousMonth: function(date) {
    return this.advance(date, { months: -1 });
  },
  monthName: function(date, sub) {
    var name;
    if (sub == null) {
      sub = null;
    }
    name = this.MONTHS[date.getMonth()];
    if (sub) {
      return name.substring(0, sub);
    } else {
      return name;
    }
  },
  dayName: function(date, sub) {
    var name;
    if (sub == null) {
      sub = null;
    }
    name = this.DAYS[date.getDay()];
    if (sub) {
      return name.substring(0, sub);
    } else {
      return name;
    }
  },
  sortDates: function(datesArray) {
    return _.sortBy(datesArray, function(date) {
      return date.getTime();
    });
  },
  /*
   * Return a function which returns a Date, and for each call advances the
   * date one day from the previously returned date provided date.
   */
  nextDateIterator: function(currentDate) {
    return function() {
      return currentDate = UtilDate.next(currentDate);
    };
  },
  /*
   * Return a function which returns a Date, and for each call advances the
   * date one day previous from the previously returned date or provided date.
   */
  previousDateIterator: function(currentDate) {
    return function() {
      return currentDate = UtilDate.previous(currentDate);
    };
  }
};

module.exports = UtilDate;
