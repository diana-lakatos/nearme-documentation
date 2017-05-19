var DatepickerInitializer;

require('eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker');

DatepickerInitializer = function() {
  function DatepickerInitializer(context) {
    this.initialize(context);
  }

  DatepickerInitializer.prototype.initialize = function(context) {
    if (context == null) {
      context = 'body';
    }
    return $(context)
      .find('.datetimepicker')
      .datetimepicker({
        allowInputToggle: true,
        icons: {
          time: 'fa fa-clock-o',
          date: 'fa fa-calendar-o',
          up: 'fa fa-chevron-up',
          down: 'fa fa-chevron-down',
          previous: 'fa fa-chevron-left',
          next: 'fa fa-chevron-right',
          today: 'fa fa-crosshairs',
          clear: 'fa fa-trash-o',
          close: 'fa fa-times'
        }
      });
  };

  return DatepickerInitializer;
}();

module.exports = DatepickerInitializer;
