var SearchTimeAndDatepickers;

require('./../../../vendor/jquery-ui-datepicker');

SearchTimeAndDatepickers = function() {
  function SearchTimeAndDatepickers(dateInput) {
    this.dateInput = dateInput;
    this.timeFromInput = $("select[name='time_from']");
    this.timeToInput = $("select[name='time_to']");
    this.initialize();
    if (this.dateInput.val()) {
      this.disableHours(this.dateInput.val());
    }
  }

  SearchTimeAndDatepickers.prototype.initialize = function() {
    return this.dateInput.datepicker({
      altField: "input[name='date']",
      altFormat: 'yy-mm-dd',
      minDate: new Date(),
      dateFormat: window.I18n.dateFormats['day_month_year']
        .replace('%d', 'dd')
        .replace('%m', 'mm')
        .replace('%Y', 'yy'),
      onSelect: function(_this) {
        return function(date_string) {
          if (_this.timeFromInput.length > 0 && _this.timeToInput.length > 0) {
            _this.disableHours(date_string);
          }
          return _this.dateInput.trigger('change');
        };
      }(this)
    });
  };

  SearchTimeAndDatepickers.prototype.disableHours = function(date_string) {
    var current_date, current_hour, date, opts;
    date = new Date(date_string);
    opts = $.merge(this.timeFromInput.find('option'), this.timeToInput.find('option'));
    current_date = new Date();
    if (date.toDateString() === current_date.toDateString()) {
      current_hour = parseInt(
        '' + current_date.getHours() + ('0' + current_date.getMinutes()).substr(-2)
      );
      return opts.each(function(i, option) {
        var time;
        time = parseInt($(option).val().replace(':', ''));
        if (isNaN(time)) {
          return;
        }
        if (time > current_hour) {
          $(option).attr('disabled', false);
          return $(option).css('display', 'block');
        } else {
          $(option).attr('disabled', 'disabled');
          return $(option).css('display', 'none');
        }
      });
    } else {
      opts.attr('disabled', false);
      return opts.css('display', 'block');
    }
  };

  return SearchTimeAndDatepickers;
}();

module.exports = SearchTimeAndDatepickers;
