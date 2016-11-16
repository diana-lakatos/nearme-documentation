require 'eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker'

datepickers = (context = 'body')->
  $(context).find('.datetimepicker:has(.date_picker), [data-date-picker]').datetimepicker({
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

  $(context).find('[data-date-range-picker]').each (index, wrap)->
    wrap = $(wrap)
    return if (wrap.data('initialised'))
    wrap.data('initialised', true)

    startDatePicker = wrap.find('[data-date-range-picker-start]').closest('.datetimepicker')
    endDatePicker = wrap.find('[data-date-range-picker-end]').closest('.datetimepicker')

    endDatePicker.data('DateTimePicker').useCurrent(false)

    startDatePicker.on 'dp.change', (e)=>
      endDatePicker.data('DateTimePicker').minDate(e.date)

    endDatePicker.on 'dp.change', (e)=>
      startDatePicker.data('DateTimePicker').maxDate(e.date)

module.exports = datepickers
