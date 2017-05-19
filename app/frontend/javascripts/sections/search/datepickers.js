var SearchDatepickers;

SearchDatepickers = function() {
  function SearchDatepickers(container) {
    this.container = container;
    if (this.container) {
      this.start_date = this.container.find('[name="start_date"]');
      this.end_date = this.container.find('[name="end_date"]');
      if (this.start_date.length > 0 && this.end_date.length > 0) {
        this.initializeDatepickers();
      }
    }
  }

  SearchDatepickers.prototype.initializeDatepickers = function() {
    var common_options, dateEndFormat, dateStartFormat;
    common_options = { altFormat: 'yy-mm-dd', constrainInput: true, minDate: 0 };
    dateStartFormat = 'mm/dd/yy';
    if (this.container.find('[name="start_date"]').attr('data-date-format')) {
      dateStartFormat = this.container.find('[name="start_date"]').attr('data-date-format');
    } else if (this.container.find('[name="fake_start_date"]').attr('data-date-format')) {
      dateStartFormat = this.container.find('[name="fake_start_date"]').attr('data-date-format');
    }
    this.container.find('[name="start_date"], [name="fake_start_date"]').datepicker(
      $.extend({}, common_options, {
        altField: this.container.find('[name="availability[dates][start]"]'),
        showOtherMonths: true,
        selectOtherMonths: true,
        dateFormat: dateStartFormat,
        onClose: function(_this) {
          return function(selectedDateString) {
            var newEndDate, selectedDate;
            selectedDate = new Date(selectedDateString);
            if (
              selectedDate > new Date(_this.end_date.val()) ||
                selectedDate > new Date(_this.container.find('[name="fake_end_date"]').val())
            ) {
              newEndDate = new Date(
                selectedDate.getFullYear(),
                selectedDate.getMonth(),
                selectedDate.getDate() + 1
              );
              return _this.container
                .find('[name="end_date"], [name="fake_end_date"]')
                .datepicker('setDate', newEndDate);
            }
          };
        }(this)
      })
    );
    dateEndFormat = 'mm/dd/yy';
    if (this.container.find('[name="end_date"]').attr('data-date-format')) {
      dateEndFormat = this.container.find('[name="end_date"]').attr('data-date-format');
    } else if (this.container.find('[name="fake_end_date"]').attr('data-date-format')) {
      dateEndFormat = this.container.find('[name="fake_end_date"]').attr('data-date-format');
    }
    return this.container.find('[name="end_date"], [name="fake_end_date"]').datepicker(
      $.extend({}, common_options, {
        altField: this.container.find('[name="availability[dates][end]"]'),
        defaultDate: 1,
        showOtherMonths: false,
        selectOtherMonths: false,
        dateFormat: dateEndFormat,
        onClose: function(_this) {
          return function(selectedDateString) {
            var newStartDate, selectedDate;
            selectedDate = new Date(selectedDateString);
            if (
              selectedDate < new Date(_this.start_date.val()) ||
                selectedDate < new Date(_this.container.find('[name="fake_start_date"]').val())
            ) {
              newStartDate = new Date(
                selectedDate.getFullYear(),
                selectedDate.getMonth(),
                selectedDate.getDate() - 1
              );
              return _this.container
                .find('[name="start_date"], [name="fake_start_date"]')
                .datepicker('setDate', newStartDate);
            }
          };
        }(this)
      })
    );
  };

  return SearchDatepickers;
}();

module.exports = SearchDatepickers;
