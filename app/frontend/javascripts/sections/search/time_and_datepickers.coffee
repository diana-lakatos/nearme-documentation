require('./../../../vendor/jquery-ui-datepicker')

module.exports = class SearchTimeAndDatepickers
  constructor: (@dateInput) ->
    @timeFromInput = $("select[name='time_from']")
    @timeToInput = $("select[name='time_to']")
    @initialize()

    @disableHours(@dateInput.val()) if @dateInput.val()

  initialize: ->
    @dateInput.datepicker
      altField: "input[name='date']",
      altFormat: "yy-mm-dd",
      minDate: new Date(),
      dateFormat: window.I18n.dateFormats["day_month_year"].replace('%d', 'dd').replace('%m', 'mm').replace('%Y', 'yy'),
      onSelect: (date_string) =>
        if @timeFromInput.length > 0 && @timeToInput.length > 0
          @disableHours(date_string)
        @dateInput.trigger('change')

  disableHours: (date_string) ->
    date = new Date(date_string)

    opts = $.merge(@timeFromInput.find('option'), @timeToInput.find('option'))
    current_date = new Date()

    if date.toDateString() == current_date.toDateString()
      current_hour = parseInt("#{current_date.getHours()}#{('0' + current_date.getMinutes()).substr(-2)}")

      opts.each (i, option) ->
        time = parseInt($(option).val().replace(':',''))
        return if isNaN(time)
        if (time > current_hour)
          $(option).attr 'disabled', false
          $(option).css 'display', 'block'
        else
          $(option).attr 'disabled', 'disabled'
          $(option).css 'display', 'none'
    else
      opts.attr('disabled', false)
      opts.css 'display', 'block'
