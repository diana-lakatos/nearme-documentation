var Datepicker,
  DatepickerModelSingle,
  SearchRangeDatePickerFilter,
  SearchRangeDatepickerView,
  dateUtil;

dateUtil = require('../../lib/utils/date');

Datepicker = require('../../components/datepicker');

DatepickerModelSingle = require('../../components/datepicker/single');

SearchRangeDatepickerView = require('./search_range_datepicker_view');

SearchRangeDatePickerFilter = function() {
  function SearchRangeDatePickerFilter(start, end, updateCallback) {
    this.start = start;
    this.end = end;
    this.updateCallback = updateCallback;
    this.initDatepickers();
    this.setInitialDates();
    this.addEventHandlers();
  }

  SearchRangeDatePickerFilter.prototype.updateDateFields = function() {
    var endDate, formatDate, startDate;
    formatDate = function(date) {
      if (date) {
        return dateUtil.monthName(date, 3) + ' ' + date.getDate();
      } else {
        return '';
      }
    };
    startDate = formatDate(this.startDatepicker.getDates()[0]);
    endDate = formatDate(this.endDatepicker.getDates()[0]);
    this.startInput().val(startDate);
    this.endInput().val(endDate);
    this.startInput().data('value', dateUtil.toId(this.startDatepicker.getDates()[0]));
    this.endInput().data('value', dateUtil.toId(this.endDatepicker.getDates()[0]));
    return this.updateCallback([ startDate, endDate ]);
  };

  SearchRangeDatePickerFilter.prototype.startDatepickerChanged = function() {
    var endDate, startDate;
    this.startDatepicker.hide();
    startDate = this.startDatepicker.getDates()[0];
    if (startDate) {
      endDate = this.endDatepicker.getDates()[0];
      if (!endDate || endDate.getTime() < startDate.getTime()) {
        this.endDatepicker.setDates([ startDate ]);
      }
      this.endDatepicker.show();
    } else {
      /*
       * Deselection
       */
      this.endDatepicker.setDates([]);
    }
    return this.updateDateFields();
  };

  SearchRangeDatePickerFilter.prototype.endInput = function() {
    return this.end.find('input');
  };

  SearchRangeDatePickerFilter.prototype.startInput = function() {
    return this.start.find('input');
  };

  SearchRangeDatePickerFilter.prototype.initDatepickers = function() {
    this.startDatepicker = new Datepicker({
      trigger: this.start,
      positionTarget: this.startInput(),
      text: '<div class="datepicker-text-fadein">Select a start date</div>',
      /*
       * Limit to a single date selected at a time
       */
      model: new DatepickerModelSingle({ allowDeselection: true })
    });
    return this.endDatepicker = new Datepicker({
      trigger: this.end,
      view: new SearchRangeDatepickerView(this.startDatepicker, {
        positionTarget: this.endInput(),
        text: '<div class="datepicker-text-fadein">Select an end date</div>'
      }),
      /*
       * Limit to a single date selected at a time
       */
      model: new DatepickerModelSingle({ allowDeselection: false })
    });
  };

  SearchRangeDatePickerFilter.prototype.setInitialDates = function() {
    var date;
    if (!(this.startDatepicker && this.endDatepicker)) {
      return;
    }
    date = new Date();
    if (this.startInput().data('value')) {
      date.setTime(Date.parse(this.startInput().data('value')));
      this.startDatepicker.addDate(date);
    }
    if (this.endInput().data('value')) {
      date.setTime(Date.parse(this.endInput().data('value')));
      return this.endDatepicker.addDate(date);
    }
  };

  SearchRangeDatePickerFilter.prototype.addEventHandlers = function() {
    this.startDatepicker.on(
      'datesChanged',
      function(_this) {
        return function() {
          return _this.startDatepickerChanged();
        };
      }(this)
    );
    this.endDatepicker.on(
      'datesChanged',
      function(_this) {
        return function() {
          return _this.updateDateFields();
        };
      }(this)
    );
    return this.end.on(
      'click',
      function(_this) {
        return function(e) {
          if (_this.startDatepicker.getDates()[0]) {
            _this.startDatepicker.hide();
          } else {
            _this.startDatepicker.show();
            _this.endDatepicker.hide();
          }
          e.stopPropagation();
          return false;
        };
      }(this)
    );
  };

  return SearchRangeDatePickerFilter;
}();

module.exports = SearchRangeDatePickerFilter;
