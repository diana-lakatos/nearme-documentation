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
  TEXT_START: '<div class="datepicker-text-fadein">Select a start date</div>'
  TEXT_END_RANGE: '<div class="datepicker-text-fadein">Select an end date</div>'
  TEXT_END_PICK: '<div class="datepicker-text-fadein">Add or remove days</div>'

  # Initialize the date picker components
  #
  # options - Hash of options to initialize the component
  #           listing - The listing model
  #           startElement - The start range trigger element
  #           endElement - The end range trigger element
  constructor: (options = {}) ->
    @listing = options.listing
    @startElement = options.startElement
    @endElement = options.endElement

    # Initialize the start datepicker component
    @startDatepicker = new window.Datepicker(
      trigger: @startElement,

      # We define a custom view which adds custom classes to the dates
      # based on the availability of the listing.
      view: new Bookings.Datepicker.AvailabilityView(@listing,
        trigger: @startElement,
        text: @TEXT_START
      ),

      # Limit to a single date selected at a time
      model: new window.Datepicker.Model.Single(
        allowDeselection: false
      )
    )

    # Initialize the end datepicker component
    @endDatepickerModel = new Bookings.Datepicker.ModeAndConstraintModel(@listing)
    @endDatepickerView = new Bookings.Datepicker.AvailabilityView(@listing,
      trigger: @endElement,
      text: @TEXT_END_RANGE
    )
    @endDatepicker = new window.Datepicker(
      trigger: @endElement
      view: @endDatepickerView
      model: @endDatepickerModel
    )

    # Whenever the user modifies their date selection we trigger the datesChanged event
    @startDatepicker.on 'datesChanged', (dates) =>
      @startDatepickerWasChanged()

    @endDatepicker.on 'datesChanged', (dates) =>
      @datesWereChanged()

    # The 'rangeApplied' event is fired by our custom endDatepicker model when a date
    # is toggled with the 'range' mode on. We bind this to set the mode to the second
    # mode, to add/remove dates.
    @endDatepickerModel.on 'rangeApplied', =>
      @setDatepickerMode(Bookings.Datepicker.ModeAndConstraintModel.MODE_PICK)

      # If the user selects the same start/end date, let's close the datepicker
      # and assume they were only trying to select one day.
      if @endDatepicker.getDates().length <= 1
        @endDatepicker.hide()

  setDates: (dates) ->
    dates = @sortDates(date)
    @startDatepicker.setDates(dates)
    @endDatepicker.setDates(dates)
    @updateElementText()

  addDate: (date) ->
    startDate = @startDatepicker.getDates()[0]
    if !startDate or startDate.getTime() > date.getTime()
      @startDatepicker.addDate(date)
    @endDatepicker.addDate(date)
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
    startDate = @startDatepicker.getDates()[0]
    endDate = _.last @endDatepicker.getDates()
    startText = if startDate then @formatDateForLabel(startDate) else 'Start'
    endText = if endDate then @formatDateForLabel(endDate) else 'End'

    @startElement.find('.calendar-text').text(startText)
    @endElement.find('.calendar-text').text(endText)

  # Sets the mode of the end datepicker, and adjusts the instructional text accordingly
  setDatepickerMode: (mode) ->
    switch mode
      when Bookings.Datepicker.ModeAndConstraintModel.MODE_RANGE
        @endDatepickerModel.setMode(Bookings.Datepicker.ModeAndConstraintModel.MODE_RANGE)
        @endDatepickerView.setText(@TEXT_END_RANGE)
      when Bookings.Datepicker.ModeAndConstraintModel.MODE_PICK
        @endDatepickerModel.setMode(Bookings.Datepicker.ModeAndConstraintModel.MODE_PICK)
        @endDatepickerView.setText(@TEXT_END_PICK)

  datesWereChanged: ->
    @updateElementText()
    @trigger 'datesChanged', @endDatepicker.getDates()

  startDatepickerWasChanged: ->
    # We want to instantly hide the start datepicker on selection
    @startDatepicker.hide()

    # Reset the end datepicker
    @endDatepicker.setDates(@startDatepicker.getDates())
    @setDatepickerMode(Bookings.Datepicker.ModeAndConstraintModel.MODE_RANGE)

    # Show the end datepicker instantly
    @endDatepicker.show()

    @datesWereChanged()

  sortDates: (datesArray) ->
    _.sortBy datesArray, (date) -> date.getTime()

  formatDateForLabel: (date) ->
    "#{DNM.util.Date.monthName(date, 3)} #{date.getDate()}"


