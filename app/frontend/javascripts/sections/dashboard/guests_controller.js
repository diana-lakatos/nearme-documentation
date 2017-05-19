var DashboardGuestsController, Datepicker;

Datepicker = require('../../components/datepicker');

DashboardGuestsController = function() {
  function DashboardGuestsController(container) {
    this.container = container;
    this.dates = this.container.find('a[data-dates]');
    this.dates.each(function(idx, date) {
      var datepicker, dates;
      dates = $.each($(date).data('dates'), function(_, d) {
        return new Date(d);
      });
      datepicker = new Datepicker({ trigger: $(date), immutable: true, disablePastDates: false });
      return datepicker.model.setDates(dates);
    });
    this.bindEvents();
  }

  DashboardGuestsController.prototype.bindEvents = function() {
    return this.dates.on('click', function() {
      return false;
    });
  };

  return DashboardGuestsController;
}();

module.exports = DashboardGuestsController;
