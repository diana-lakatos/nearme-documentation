var Availability,
  HourlyAvailability,
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

Availability = require('./availability');

dateUtil = require('../../../lib/utils/date');

/*
 * Extends the simple daily availability wrapper to provide quantity
 * down to the hourly level for specific days. Provides the same semantics
 * if called without a provided minute, or provides hourly semantics if called
 * with a minute as an additional parameter.
 * Encapsulates deferred loading of the hourly availability.
 */
HourlyAvailability = function(superClass) {
  extend(HourlyAvailability, superClass);

  function HourlyAvailability(data1, schedule, scheduleUrl) {
    this.data = data1;
    this.schedule = schedule;
    this.scheduleUrl = scheduleUrl;
    HourlyAvailability.__super__.constructor.call(this, this.data);
  }

  HourlyAvailability.prototype.openFor = function(date, minute) {
    return this._value(date, minute) !== null;
  };

  HourlyAvailability.prototype.availableFor = function(date, minute) {
    return this._value(date, minute) || 0;
  };

  HourlyAvailability.prototype.hasSchedule = function(date) {
    return !!this._schedule(date);
  };

  /*
   * Fire off a remote request (if required) to load the hourly availability
   * schedule for a given date. Execute the provided callback when ready
   * to use.
   */
  HourlyAvailability.prototype.loadSchedule = function(date, callback) {
    var dateId;
    if (!this.hasSchedule(date)) {
      dateId = dateUtil.toId(date);
      return $.get(this.scheduleUrl + ('?date=' + dateId)).success(
        function(_this) {
          return function(data) {
            _this.schedule[dateId] = data;
            return callback(date);
          };
        }(this)
      );
    } else {
      return callback(date);
    }
  };

  HourlyAvailability.prototype._schedule = function(date) {
    return this.schedule[dateUtil.toId(date)];
  };

  HourlyAvailability.prototype._value = function(date, minute) {
    var hours;
    if (minute != null) {
      hours = this._schedule(date);
      if (hours) {
        return hours[minute.toString()] || null;
      } else {
        return HourlyAvailability.__super__._value.call(this, date);
      }
    } else {
      return HourlyAvailability.__super__._value.call(this, date);
    }
  };

  return HourlyAvailability;
}(Availability);

module.exports = HourlyAvailability;
