# Wraps our custom Datepicker implementation for use as a Booking selection calendar.
#
# See also: components/datepicker.js
class @Bookings.RecurringDatepicker
  asEvented.call(RecurringDatepicker.prototype)

  # Some text constants used in the UI
  TEXT_START: '<div class="datepicker-text-fadein">Select a start date</div>'
  TEXT_END_RANGE: '<div class="datepicker-text-fadein">Select an end date</div>'

  # Initialize the date picker components
  #
  # options - Hash of options to initialize the component
  #           listing - The listing model
  #           startElement - The start range trigger element
  #           endElement - The end range trigger element
  constructor: (options = {}) ->
    @startElement = options.startElement
    @endElement = options.endElement

    @initializeStartDatepicker()
    @initializeEndDatepicker()
    @bindEvents()

  bindEvents: ->
    @startDatepicker.on 'datesChanged', (dates) =>
      @startOnChanged(dates[0])

    @endDatepicker.on 'datesChanged', (dates) =>
      @endOnChanged(dates[0])

  startOnChanged: (date) ->
    @startElement.val(@formatDateForLabel(date))
    @trigger 'startOnChanged', date
    @startDatepicker.hide()

  endOnChanged: (date) ->
    @endElement.val(@formatDateForLabel(date))
    @trigger 'endOnChanged', date

    if @endDatepicker.getView().isVisible()
      @endDatepicker.hide()


  initializeStartDatepicker: ->
    @startDatepicker = new window.Datepicker(
      trigger: @startElement,
      # Custom view to handle bookings availability display
      view: new window.Datepicker.View( trigger: @startElement, text: @TEXT_START),
      # Limit to a single date selected at a time
      model: new window.Datepicker.Model.Single( allowDeselection: false)
    )

  initializeEndDatepicker: ->
    @endDatepicker = new window.Datepicker(
      trigger: @endElement
      # Custom view to handle bookings availability display
      view: new window.Datepicker.View( trigger: @endElement, text: @TEXT_END_RANGE),
      # Limit to a single date selected at a time
      model: new window.Datepicker.Model.Single( allowDeselection: false)
    )

  formatDateForLabel: (date) ->
    [date.getFullYear(), (date.getMonth() + 1), date.getDate()].join("-")

  setDates: (dates) ->
    @startDatepicker.setDates(dates.slice(0,1))
    @endDatepicker.setDates([dates[dates.length-1]])
    @startOnChanged(dates[0])
    @endOnChanged(dates[dates.length-1])

