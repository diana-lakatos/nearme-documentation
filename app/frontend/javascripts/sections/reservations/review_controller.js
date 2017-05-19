var ReservationReviewController;

ReservationReviewController = function() {
  require('./../../../vendor/jquery-ui-datepicker');

  function ReservationReviewController(container) {
    var OverlappingReservationsController;
    this.container = container;
    this.dateInput = this.container.find('.jquery-datepicker');
    this.startTimeInput = this.container.find('#order_start_time');
    if (this.dateInput.length > 0) {
      OverlappingReservationsController = require('./overlapping_reservations');
      this.overlappingCheck = new OverlappingReservationsController(
        this.container.find('[data-reservation-dates-controller]')
      );
      this.initializeDatepicker();
      this.disableHours(this.dateInput.val());
      this.overlappingCheck.checkNewDate();
    }
  }

  ReservationReviewController.prototype.initializeDatepicker = function() {
    return this.dateInput.datepicker({
      altField: '#order_dates',
      altFormat: 'yy-mm-dd',
      minDate: new Date(),
      dateFormat: window.I18n.datepickerFormats['dformat']
        .replace('%d', 'dd')
        .replace('%m', 'mm')
        .replace('%Y', 'yy'),
      beforeShowDay: function(date) {
        var except_periods, j, len, opened_days, period;
        opened_days = $(this).data('open-on-days');
        except_periods = $(this).data('except-periods');
        for (j = 0, len = except_periods.length; j < len; j++) {
          period = except_periods[j];
          if (
            new Date(period.from.replace(/-/g, '/') + ' 00:00:00') <= date &&
              date <= new Date(period.to.replace(/-/g, '/') + ' 23:59:59')
          ) {
            return [ false ];
          }
        }
        return [ opened_days.indexOf(date.getDay()) > -1 ];
      },
      onSelect: function(_this) {
        return function(date_string) {
          _this.disableHours(date_string);
          return _this.overlappingCheck.checkNewDate();
        };
      }(this)
    });
  };

  ReservationReviewController.prototype.disableHours = function(date_string) {
    var current_date, current_hour, date, opts, ranges;
    date = new Date(date_string);
    ranges = this.dateInput.data('days-with-ranges')[date.getDay()];
    opts = this.startTimeInput.find('option');
    if (opts.length === 0) {
      return;
    }
    opts.attr('disabled', 'disabled');
    current_date = new Date();
    if (date.toDateString() === current_date.toDateString()) {
      current_hour = parseInt(
        '' + (current_date.getHours() + 2) + ('0' + current_date.getMinutes()).substr(-2)
      );
    }
    opts.each(function(i, option) {
      return $.each(ranges, function(i, val) {
        var time;
        time = parseInt($(option).data('time'));
        if ((current_hour == null || time > current_hour) && (time >= val[0] && time <= val[1])) {
          return $(option).attr('disabled', false);
        }
      });
    });
    opts = this.startTimeInput.find('option');
    if (opts.filter(':not([disabled])').length === 0) {
      return this.startTimeInput
        .append(
          "<option selected='selected' data-no-options>" + this.startTimeInput.data('no-options') +
            '</option>'
        )
        .trigger('change');
    } else {
      opts.filter('[data-no-options]').remove();
      if (opts.filter('[selected]').length === 0 || opts.filter('[selected]').is('[disabled]')) {
        opts.filter('[selected]').prop('selected', false);
        opts.filter(':not([disabled])').first().prop('selected', true);
        this.startTimeInput.trigger('change');
        return this.startTimeInput.val(this.startTimeInput.val());
      }
    }
  };

  return ReservationReviewController;
}();

module.exports = ReservationReviewController;
