module.exports = class ReservationReviewController

  require('./../../../vendor/jquery-ui-datepicker')

  constructor: (@container) ->
    @dateInput = @container.find('.jquery-datepicker')
    @startTimeInput = @container.find('#order_start_time')
    if @dateInput.length > 0
      OverlappingReservationsController = require('./overlapping_reservations')
      @overlappingCheck = new OverlappingReservationsController(@container.find('[data-reservation-dates-controller]'))
      @initializeDatepicker()
      @disableHours(@dateInput.val())
      @overlappingCheck.checkNewDate()

  initializeDatepicker: ->
    @dateInput.datepicker
      altField: '#order_dates'
      altFormat: 'yy-mm-dd'
      minDate: new Date()
      dateFormat: window.I18n.datepickerFormats['dformat'].replace('%d', 'dd').replace('%m', 'mm').replace('%Y', 'yy')
      beforeShowDay: (date) ->
        opened_days = $(@).data('open-on-days')
        except_periods = $(@).data('except-periods')
        for period in except_periods
          if new Date(period.from.replace(/-/g, "/") + " 00:00:00") <= date && date <= new Date(period.to.replace(/-/g, "/") + " 23:59:59")
            return [ false ]

        [ opened_days.indexOf(date.getDay()) > -1 ]
      onSelect: (date_string) =>
        @disableHours(date_string)
        @overlappingCheck.checkNewDate()

  disableHours: (date_string) ->
    date = new Date(date_string)
    ranges = @dateInput.data('days-with-ranges')[date.getDay()]

    opts = @startTimeInput.find('option')
    return if opts.length is 0

    opts.attr 'disabled', 'disabled'
    current_date = new Date()
    if date.toDateString() == current_date.toDateString()
      current_hour = parseInt("#{current_date.getHours() + 2}#{('0' + current_date.getMinutes()).substr(-2)}")
    opts.each (i, option) ->
      $.each ranges, (i, val) ->
        time = parseInt($(option).data('time'))
        if (!current_hour? || time > current_hour) && (time >= val[0] && time <= val[1])
          $(option).attr 'disabled', false
    opts = @startTimeInput.find('option')
    if opts.filter(':not([disabled])').length == 0
      @startTimeInput.append("<option selected='selected' data-no-options>#{@startTimeInput.data('no-options')}</option>").trigger('change')
    else
      opts.filter('[data-no-options]').remove()
      if opts.filter('[selected]').length == 0 || opts.filter('[selected]').is('[disabled]')
        opts.filter('[selected]').prop('selected', false)
        opts.filter(':not([disabled])').first().prop('selected', true)
        @startTimeInput.trigger('change')
        @startTimeInput.val(@startTimeInput.val())

