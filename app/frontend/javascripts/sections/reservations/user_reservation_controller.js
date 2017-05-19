var Datepicker, ReservationUserReservationController;

Datepicker = require('../../components/datepicker');

/*
 * Controller for handling each reservation in my bookings page
 *
 * The controller is initialized with the reservation DOM container.
 */
ReservationUserReservationController = function() {
  function ReservationUserReservationController(container, options) {
    this.container = container;
    this.options = options != null ? options : {};
    this.dates = this.container.find('a[data-dates]');
    this.times = this.container.find('a[data-reservation-hours]');
    this.datepicker();
    this.tooltip();
    this.bindEvents();
  }

  ReservationUserReservationController.prototype.tooltip = function() {
    return this.times.each(function(idx, el) {
      var text;
      text = $(el).data('reservation-hours');
      return $(el).tooltip({ title: text, html: true });
    });
  };

  ReservationUserReservationController.prototype.datepicker = function() {
    return this.dates.each(function(idx, date) {
      var datepicker, dates;
      dates = $.each($(date).data('dates'), function(_, d) {
        return new Date(d);
      });
      datepicker = new Datepicker({ trigger: $(date), immutable: true, disablePastDates: false });
      return datepicker.model.setDates(dates);
    });
  };

  ReservationUserReservationController.prototype.bindEvents = function() {
    this.dates.on('click', function() {
      return false;
    });
    return this.times.on('click', function() {
      return false;
    });
  };

  return ReservationUserReservationController;
}();

module.exports = ReservationUserReservationController;
