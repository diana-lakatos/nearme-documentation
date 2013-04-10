# Wraps our custom Datepicker implementation for use as a Booking selection calendar.
#
# See also: components/datepicker.js
class @Bookings.Datepicker
  asEvented.call(Datepicker.prototype)

  # Some text constants used in the UI
  TEXT_START: 'Select a start date'
  TEXT_END_RANGE: 'Select an end date'
  TEXT_END_PICK: 'Add or remove days'

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
      trigger: @startElement
      view: new DatepickerAvailabilityView(@listing, trigger: @startElement, text: @TEXT_START)
      model: new window.Datepicker.Model.Single(
        allowDeselection: false
      )
    )

    # Initialize the end datepicker component
    @endDatepickerModel = new DatepickerModelWithModeAndConstraints(@listing)
    @endDatepickerView = new DatepickerAvailabilityView(@listing, trigger: @endElement, text: @TEXT_END_RANGE)
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
      @setDatepickerMode(DatepickerModelWithModeAndConstraints.MODE_PICK)

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
      when DatepickerModelWithModeAndConstraints.MODE_RANGE
        @endDatepickerModel.setMode(DatepickerModelWithModeAndConstraints.MODE_RANGE)
        @endDatepickerView.setText(@TEXT_END_RANGE)
      when DatepickerModelWithModeAndConstraints.MODE_PICK
        @endDatepickerModel.setMode(DatepickerModelWithModeAndConstraints.MODE_PICK)
        @endDatepickerView.setText(@TEXT_END_PICK)

  datesWereChanged: ->
    @updateElementText()
    @trigger 'datesChanged', @endDatepicker.getDates()

  startDatepickerWasChanged: ->
    # We want to instantly hide the start datepicker on selection
    @startDatepicker.hide()

    # Reset the end datepicker
    @endDatepicker.setDates(@startDatepicker.getDates())
    @setDatepickerMode(DatepickerModelWithModeAndConstraints.MODE_RANGE)

    # Show the end datepicker instantly
    @endDatepicker.show()

    @datesWereChanged()

  sortDates: (datesArray) ->
    _.sortBy datesArray, (date) -> date.getTime()

  formatDateForLabel: (date) ->
    "#{DNM.util.Date.monthName(date, 3)} #{date.getDate()}"

  # A view wrapper for the Datepicker to show a loading indicator while we load the date availability
  class DatepickerAvailabilityView extends window.Datepicker.View
    constructor: (@listing, options = {}) ->
      super(options)

    show: ->
      # Refresh if listing quantity has changed since last display
      # We do this to update the display of available vs unavailable dates
      if @lastDefaultQuantity && @listing.defaultQuantity != @lastDefaultQuantity
        @refresh()

      @lastDefaultQuantity = @listing.defaultQuantity
      super

    # Extend the class generation method to add disabled state if the listing quantity selection
    # exceeds the availability for a given date.
    classForDate: (date, monthDate) ->
      klass = [super]
      qty = @listing.defaultQuantity
      qty = 1 if qty < 1

      klass.push 'disabled' unless @listing.availabilityFor(date) >= qty
      klass.push 'closed' unless @listing.openFor(date)
      klass.join ' '


  class DatepickerModelWithModeAndConstraints extends window.Datepicker.Model
    # Modes for the selection type. The different modes have different semantics when
    # a date is toggled.
    @MODE_RANGE = 'range'
    @MODE_PICK = 'pick'

    mode: @MODE_RANGE

    constructor: (listing) ->
      super({})

      @listing = listing
      @minDays = listing.minimumBookingDays or 1

    setMode: (mode) ->
      @mode = mode

    toggleDate: (date) ->
      switch @mode
        when DatepickerModelWithModeAndConstraints.MODE_RANGE
          @setRangeTo(date)
          @extendRangeToMeetConstraint(date)
          @trigger 'rangeApplied'

        when DatepickerModelWithModeAndConstraints.MODE_PICK
          if @isSelected(date)
            @removeDate(date)
            @reduceRangeToMeetConstraint(date)
          else
            # Add the date
            @addDate(date)
            @extendRangeToMeetConstraint(date)

    # Set the date range to the specified date, from the first date.
    setRangeTo: (date) ->
      return unless @listing.dateWithinBounds(date)

      startDate = @getDates()[0] || date

      # If the to-date is before the start-date, then we set both ends to
      # the same date (i.e. no range)
      startDate = date if startDate.getTime() > date.getTime()

      current = startDate
      while DNM.util.Date.toId(current) != DNM.util.Date.toId(date)
        @addDate(current) if @canSelectDate(current)
        current = DNM.util.Date.next(current)
      @addDate(date) if @canSelectDate(date)

    canSelectDate: (date) ->
      @listing.availabilityFor(date) >= @listing.defaultQuantity

    # Starting at a given date, scan dates validate that it meets the consecutive bookings
    # constraint. If it doesn't, add next available dates until it does.
    extendRangeToMeetConstraint: (date) ->
      futureIterator = (date) -> DNM.util.Date.next(date)
      pastIterator   = (date) -> DNM.util.Date.previous(date)

      extender = (iteratorFunc) =>
        current = iteratorFunc(date)
        until @meetsConstraint(date)
          break unless @listing.dateWithinBounds(current)
          @addDate(current) if @canSelectDate(current)
          current = iteratorFunc(current)

      # Try to extend forward first, then work backwards.
      # We go backwards due to an edge case at the end of the bookable range,
      # where we need to add dates in the past to constraint the selection.
      extender(futureIterator)
      extender(pastIterator)

    # Starting from a given date, scan the dates around it to ensure that the act of removing that
    # date hasn't invalidated the minimum date selection constraints. If it has, remove relevant
    # dates to restore selected dates to a state that reflects the minimum consecutive days constraint.
    reduceRangeToMeetConstraint: (date) ->
      # Remove previous date if doesn't meet constraint anymore
      previous = (date) -> DNM.util.Date.previous(date)
      next     = (date) -> DNM.util.Date.next(date)

      # Iterates with an advancer through the selected dates adjacent to the starting date, 
      # and validates that that date meets the restrictions.
      #
      # Three cases:
      #   * Date is selected. We validate that it still meets the constraints
      #     * If it does, we are done.
      #     * If it doesn't, we unselect the date and try the next one
      #   * Date is not selectable 
      #     * We move to the next date - as it being unselectable isn't included
      #       in 'consecutive' semantics.
      #   * Date is not selected
      #     * We are done - as we assume other dates already meet requirements.
      reducer = (iteratorFunc) =>
        current = iteratorFunc(date)
        while @listing.dateWithinBounds(current)
          if @canSelectDate(current)
            break if !@isSelected(current)
            break if @meetsConstraint(current)

            # Can no longer have this date selected
            @removeDate(current)

          # Iterate along to the next date
          current = iteratorFunc(current)

      # Check both future and past connected selected dates are now valid
      reducer(previous)
      reducer(next)

    # Returns whether or not there are minDays available days booked around
    # the specified date.
    meetsConstraint: (date) ->
      @consecutiveDays(date) >= @minDays

    # Return the consecutive days currently at the date, *or* the required minumum
    # consecutive days - whatever is less.
    consecutiveDays: (date) ->
      return 0 if !@isSelected(date)

      # Counter
      consecutive = 1

      # Iterator functions (backwards, forwards)
      directionPrev = (date) -> DNM.util.Date.previous(date)
      directionNext = (date) -> DNM.util.Date.next(date)

      # Our counting algorithm
      counter = (iteratorFunc) =>
        current = iteratorFunc(date)
        i = 0
        while consecutive < @minDays
          break if i > 28 # Count only up to 28, hard code prevention of infinite loop
          break unless @listing.dateWithinBounds(current)

          isSelected = @isSelected(current)
          break if @canSelectDate(current) and !isSelected
          
          consecutive++ if isSelected
          current = iteratorFunc(current)
          i++

      # Count backwards and forwards
      counter(directionPrev)
      counter(directionNext)

      # Return our count
      consecutive

