require 'eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker'

module.exports = class DatepickerInitializer
  constructor: (context) ->
    @initialize()

  initialize: (context = 'body') ->
    $(context).find('.datetimepicker').datetimepicker({
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
    })
