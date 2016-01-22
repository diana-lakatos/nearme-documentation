#= require_self
#= require ./datepicker/availability_view
#= require ./datepicker/mode_and_constraint_model
#
# Wraps our custom Datepicker implementation for use as a Booking selection calendar.
#
# See also: components/datepicker.js
class @Bookings.Datepicker
  asEvented.call(Datepicker.prototype)

  # Some text constants used in the UI
  TEXT_END_RANGE: '<div class="datepicker-text-fadein">Select an end date</div>'

  # Initialize the date picker components
  #
  # options - Hash of options to initialize the component
  #           listing - The listing model
  #           startElement - The start range trigger element
  #           endElement - The end range trigger element
  constructor: (options = {}) ->
    @listing = options.listing
    @container = options.container
    @startElement = @container.find(".calendar-wrapper.date-start")
    @endElement = @container.find(".calendar-wrapper.date-end")

    @listingData = options.listingData

    @initializeStartDatepicker()
    @initializeEndDatepicker()

    @bindEvents()
    @assignInitialDates()

    if @listing.isReservedHourly()
      @initializeTimePicker()

  #TODO: replace these with JS i18n system
  start_text: ->
    if @listing.isOvernightBooking()
      '<div class="datepicker-text-fadein">Check in</div>'
    else if @listing.isReservedHourly()
      '<div class="datepicker-text-fadein">Select date</div>'
    else
      '<div class="datepicker-text-fadein">Select a start date</div>'

  end_text: ->
    if @listing.isOvernightBooking()
      '<div class="datepicker-text-fadein">Check out</div>'
    else
      '<div class="datepicker-text-fadein">Select an end date</div>'

  bindEvents: ->
    @startDatepicker.on 'datesChanged', (dates) =>
      @startDatepickerWasChanged()
      @timePicker.updateSelectableTimes() if @timePicker

    @endDatepicker.on 'datesChanged', (dates) =>
      @datesWereChanged()


    # The 'rangeApplied' event is fired by our custom endDatepicker model when a date
    # is toggled with the 'range' mode on. We bind this to set the mode to the second
    # mode, to add/remove dates.
    @endDatepicker.getModel().on 'rangeApplied', =>
      # For now, we only provide the add/remove pick mode for listings allowing
      # individual day selection.
      @setDatepickerToPickMode() unless @listing.data.continuous_dates

      # If the user selects the same start/end date, let's close the datepicker
      # and assume they were only trying to select one day.
      if @listing.minimumBookingDays > 1 or @endDatepicker.getDates().length <= 1
        @endDatepicker.hide()

  initializeStartDatepicker: ->
    @startDatepicker = new window.Datepicker(
      trigger: @startElement,

      # Custom view to handle bookings availability display
      view: new Bookings.Datepicker.AvailabilityView(@listing,
        trigger: @startElement,
        text: @start_text()
      ),

      # Limit to a single date selected at a time
      model: new window.Datepicker.Model.Single(
        allowDeselection: false
      )
    )

  initializeEndDatepicker: ->
    @endDatepicker = new window.Datepicker(
      trigger: @endElement

      # Custom view to handle bookings availability display
      view: new Bookings.Datepicker.AvailabilityView(@listing,
        trigger: @endElement,
        text: @TEXT_END_RANGE
      ),

      # Custom backing model to handle logic of range and constraints
      model: new Bookings.Datepicker.ModeAndConstraintModel(@listing)
    )

  setDates: (dates) ->
    dates = DNM.util.Date.sortDates(dates)
    @startDatepicker.setDates(dates.slice(0,1))
    @endDatepicker.setDates(dates)
    @endDatepicker.getModel().ensureDatesMeetConstraint()

    # If we're specifying more than just a start date, we need
    # to set the mode to Pick.
    if dates.length > 1 && !@listing.isOvernightBooking()
      @setDatepickerToPickMode()
    @updateElementText()
    @trigger 'datesChanged', @endDatepicker.getDates()

  reset: ->
    @setDates([])
    @timePicker.updateSelectableTimes() if @timePicker

  addDate: (date) ->
    # If the added date is prior to the current start date, we set the
    # start date range to that date.
    startDate = @startDatepicker.getDates()[0]
    if !startDate or startDate.getTime() > date.getTime()
      @startDatepicker.addDate(date)

    @endDatepicker.addDate(date)
    @endDatepicker.getModel().extendRangeToMeetConstraint(date)
    @updateElementText()

  removeDate: (date) ->
    @startDatepicker.removeDate(date)
    @endDatepicker.removeDate(date)

    if !@startDatepicker.getDates()[0]
      firstEndDate = @endDatepicker.getDates()[0]
      @startDatepicker.addDate(firstEndDate) if firstEndDate
    @updateElementText()

  getDates: ->
    @endDatepicker.getDates()

  updateElementText: ->
    # Set the date on the element
    startDate = _.first(@endDatepicker.getDates())
    endDate = _.last(@endDatepicker.getDates())
    startText = if startDate then @formatDateForLabel(startDate) else 'Start'
    endText = if endDate then @formatDateForLabel(endDate) else 'End'

    @startElement.find('.calendar-text').text(startText)
    @endElement.find('.calendar-text').text(endText)

  setDatepickerToPickMode: ->
    return if @listing.minimumBookingDays > 1
    @endDatepicker.getModel().setMode(Bookings.Datepicker.ModeAndConstraintModel.MODE_PICK)
    @endDatepicker.getView().setText(@end_text())

  setDatepickerToRangeMode: ->
    @endDatepicker.getModel().setMode(Bookings.Datepicker.ModeAndConstraintModel.MODE_RANGE)
    @endDatepicker.getView().setText(@TEXT_END_RANGE)

  datesWereChanged: ->
    @updateElementText()
    @trigger 'datesChanged', @endDatepicker.getDates()

  startDatepickerWasChanged: ->
    # We want to instantly hide the start datepicker on selection
    @startDatepicker.hide()

    # Reset the end datepicker
    @setDates(@startDatepicker.getDates())
    @setDatepickerToRangeMode()

    # Show the end datepicker instantly
    if @container.find("li[data-hourly]").hasClass('active')
      @timePicker.show()
    else
      @endDatepicker.show()

    # Bubble event
    @datesWereChanged()

  formatDateForLabel: (date) ->
    date.strftime I18n.dateFormats["day_and_month"].replace(/%(\^|-|_)/g, '%')

  # Sets up the time picker view controller which handles the user selecting the
  # start/end times for the reservation.
  initializeTimePicker: ->
    options = {
      openMinute: @listing.data.earliest_open_minute,
      closeMinute: @listing.data.latest_close_minute,
      minimumBookingMinutes: @listing.data.minimum_booking_minutes
    }

    if @listingData.initial_bookings && @listingData.initial_bookings.start_minute && @listingData.initial_bookings.end_minute
      options.startMinute = @listingData.initial_bookings.start_minute
      options.endMinute = @listingData.initial_bookings.end_minute

    @timePicker = new Bookings.TimePicker(
      @listing,
      @container.find('.time-picker'),
      options
    )

    @timePicker.on 'change', =>
      @updateTimes()
    @updateTimes()
    @timePicker.updateSelectableTimes()



  updateTimes: ->
    @listing.setTimes(@timePicker.startMinute(), @timePicker.endMinute())
    @trigger 'timesChanged'

  # Assign initial dates from a restored session or the default
  # start date.
  assignInitialDates: ->
    startDate = null
    endDate = null

    if DNM.util.Url.getParameterByName('start_date')
      startDate = new Date(DNM.util.Url.getParameterByName('start_date'))
      for i in [0..50]
        if @endDatepicker.getModel().canSelectDate(DNM.util.Date.nextDateIterator(startDate)())
          endDate = DNM.util.Date.nextDateIterator(startDate)()
          break

    if startDate == null || endDate == null
      startDate = @listing.firstAvailableDate
      endDate = @listing.secondAvailableDate

    initialDates = if @listingData.initial_bookings
      # Format is:
      # {quantity: 1, dates: ['2013-11-04', ...] }
      @listing.setDefaultQuantity(@listingData.initial_bookings.quantity)

      # Map bookings to JS dates
      (DNM.util.Date.idToDate(date) for date in @listingData.initial_bookings.dates)
    else if @listing.isOvernightBooking()
      [startDate, endDate]
    else
      [startDate]

    @trigger 'datesChanged', initialDates
    @setDates(initialDates)
    @listing.setDates(initialDates)
