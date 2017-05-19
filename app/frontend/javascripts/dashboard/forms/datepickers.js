var datepickers;

require('eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker');

datepickers = function(context) {
  if (context == null) {
    context = 'body';
  }
  return $(context)
    .find('.datetimepicker:has(.date_picker)')
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

module.exports = datepickers;
