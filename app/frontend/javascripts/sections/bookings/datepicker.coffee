AvailabilityView = require('./datepicker/availability_view')
ModeAndConstraintModel = require('./datepicker/mode_and_constraint_model')
asEvented = require('asevented')
Datepicker = require('../../components/datepicker')
DatepickerModelSingle = require('../../components/datepicker/single')
dateUtil = require('../../lib/utils/date')
urlUtil = require('../../lib/utils/url')
TimePicker = require('./time_picker')
require('../../../vendor/gf3-strftime')

# Wraps our custom Datepicker implementation for use as a Booking selection calendar.
#
# See also: components/datepicker.js
module.exports = class BookingsDatepicker
  asEvented.call @prototype

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
    @initializeEndDatepicker() if @endElement.length > 0

    @bindEvents()
    @assignInitialDates()

    if @listing.canReserveHourly()
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
    @listing.on 'quantityChanged', =>
      if @timePicker
        setTimeout (=>
          @timePicker.updateSelectableTimes()
        ), 100

    @startDatepicker.on 'datesChanged', (dates) =>
      @startDatepickerWasChanged()
      @timePicker.updateSelectableTimes() if @timePicker

    if @endDatepicker
      @endDatepicker.on 'datesChanged', (dates) =>
        @datesWereChanged()


    if @endDatepicker
      # The 'rangeApplied' event is fired by our custom endDatepicker model when a date
      # is toggled with the 'range' mode on. We bind this to set the mode to the second
      # mode, to add/remove dates.
      @endDatepicker.getModel().on 'rangeApplied', =>
        # For now, we only provide the add/remove pick mode for listings allowing
        # individual day selection.
        @setDatepickerToPickMode() unless @listing.data.continuous_dates

        # If the user selects the same start/end date, let's close the datepicker
        # and assume they were only trying to select one day.
        if @listing.minimumBookingDays() > 1 or @endDatepicker.getDates().length <= 1
          @endDatepicker.hide()

  initializeStartDatepicker: ->
    @startDatepicker = new Datepicker(
      trigger: @startElement,

      # Custom view to handle bookings availability display
      view: new AvailabilityView(@listing,
        trigger: @startElement,
        text: @start_text(),
        isContinous: !!@listing.data.continuous_dates
      ),

      # Limit to a single date selected at a time
      model: new DatepickerModelSingle(
        allowDeselection: false
      )
    )

  initializeEndDatepicker: ->
    @endDatepicker = new Datepicker(
      trigger: @endElement

      # Custom view to handle bookings availability display
      view: new AvailabilityView(@listing,
        trigger: @endElement,
        text: @TEXT_END_RANGE,
        isContinous: !!@listing.data.continuous_dates
      ),

      # Custom backing model to handle logic of range and constraints
      model: new ModeAndConstraintModel(@listing)
    )

  setDates: (dates) ->
    dates = dateUtil.sortDates(dates)
    @startDatepicker.setDates(dates.slice(0,1))

    if @endDatepicker
      @endDatepicker.setDates(dates)
      @endDatepicker.getModel().ensureDatesMeetConstraint()

    # If we're specifying more than just a start date, we need
    # to set the mode to Pick.
    if dates.length > 1 && !@listing.isOvernightBooking()
      @setDatepickerToPickMode()
    @updateElementText()

    @trigger 'datesChanged', @getDates()

  reset: ->
    @setDates([])
    @timePicker.updateSelectableTimes() if @timePicker

  addDate: (date) ->
    # If the added date is prior to the current start date, we set the
    # start date range to that date.
    startDate = @startDatepicker.getDates()[0]
    if !startDate or startDate.getTime() > date.getTime()
      @startDatepicker.addDate(date)

    if @endDatepicker
      @endDatepicker.addDate(date)
      @endDatepicker.getModel().extendRangeToMeetConstraint(date)
    @updateElementText()

  removeDate: (date) ->
    @startDatepicker.removeDate(date)
    @endDatepicker.removeDate(date) if @endDatepicker

    if !@startDatepicker.getDates()[0] and @endDatepicker
      firstEndDate = @endDatepicker.getDates()[0]
      @startDatepicker.addDate(firstEndDate) if firstEndDate
    @updateElementText()

  getDates: ->
    if @endDatepicker
      @endDatepicker.getDates()
    else
      @startDatepicker.getDates()


  updateElementText: ->
    startDate = _.first(@getDates())
    startText = if startDate then @formatDateForLabel(startDate) else 'Start'
    @startElement.find('.calendar-text').text(startText)

    if @endDatepicker
      endDate = _.last(@getDates())

      if endDate
        endText = @formatDateForLabel(endDate)
        @endDatepicker.getModel().setCurrentMonth(endDate)
      else
        endText = 'End'

      @endElement.find('.calendar-text').text(endText)

  setDatepickerToPickMode: ->
    return if @listing.minimumBookingDays() > 1
    if @endDatepicker
      @endDatepicker.getModel().setMode(ModeAndConstraintModel.MODE_PICK)
      @endDatepicker.getView().setText(@end_text())

  setDatepickerToRangeMode: ->
    if @endDatepicker
      @endDatepicker.getModel().setMode(ModeAndConstraintModel.MODE_RANGE)
      @endDatepicker.getView().setText(@TEXT_END_RANGE)

  datesWereChanged: ->
    @updateElementText()

    @trigger 'datesChanged', @getDates()

  startDatepickerWasChanged: ->
    # We want to instantly hide the start datepicker on selection
    @startDatepicker.hide()

    # Reset the end datepicker
    @setDates(@startDatepicker.getDates())
    @setDatepickerToRangeMode()

    # Show the end datepicker instantly
    if @listing.isReservedHourly()
      @timePicker.show()
    else if @endDatepicker
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

    @timePicker = new TimePicker(
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
    if urlUtil.getParameterByName('start_date')
      startDate = new Date(urlUtil.getParameterByName('start_date'))
      if startDate < @listing.firstAvailableDate
        startDate = @listing.firstAvailableDate
      for i in [0..50]
        if @endDatepicker and @endDatepicker.getModel().canSelectDate(dateUtil.nextDateIterator(startDate)())
          endDate = dateUtil.nextDateIterator(startDate)()
          break

    if startDate == null || endDate == null
      startDate = @listing.firstAvailableDate
      endDate = @listing.secondAvailableDate

    initialDates = if @listingData.initial_bookings
      # Format is:
      # {quantity: 1, dates: ['2013-11-04', ...] }
      @listing.setDefaultQuantity(@listingData.initial_bookings.quantity)

      # Map bookings to JS dates
      (dateUtil.idToDate(date) for date in @listingData.initial_bookings.dates)
    else if @listing.isOvernightBooking() && endDate == dateUtil.next(startDate)
      [startDate, endDate]
    else
      [startDate]

    @trigger 'datesChanged', initialDates
    @setDates(initialDates)
    @listing.setDates(initialDates)
