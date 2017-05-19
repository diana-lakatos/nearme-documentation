/*
 * Wrap queries on the availability data
 */
var ScheduleAvailability;

ScheduleAvailability = function() {
  function ScheduleAvailability(data) {
    this.data = data;
  }

  ScheduleAvailability.prototype.openFor = function() {
    return true;
  };

  ScheduleAvailability.prototype.availableFor = function() {
    return 1000;
  };

  return ScheduleAvailability;
}();

module.exports = ScheduleAvailability;
