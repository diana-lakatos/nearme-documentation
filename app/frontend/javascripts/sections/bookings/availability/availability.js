/*
 * Wrap queries on the availability data
 */
var Availability;

Availability = function() {
  function Availability(data) {
    this.data = data;
  }

  Availability.prototype.openFor = function(date) {
    return this._value(date) !== null;
  };

  Availability.prototype.availableFor = function(date) {
    return this._value(date) || 0;
  };

  Availability.prototype.firstUnavailableDay = function(date) {
    var prevDay;
    prevDay = new Date(date);
    prevDay.setDate(date.getDate() - 1);
    return !this._value(date) && this._value(prevDay);
  };

  Availability.prototype._value = function(date) {
    var month;
    month = this.data[date.getFullYear() + '-' + (date.getMonth() + 1)];
    if (month) {
      return month[date.getDate() - 1];
    } else {
      return null;
    }
  };

  return Availability;
}();

module.exports = Availability;
