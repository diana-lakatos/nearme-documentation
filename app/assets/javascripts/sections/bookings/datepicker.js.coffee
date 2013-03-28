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

    # Extend the rendering method to trigger a "loading" indicator/overlay.
    # We need to load the date availability for the listing for all of the dates
    # that display, so that we can render whether or not there is availability on
    # the calendar.
    renderMonth: (month) ->
      dates = @datesForMonth(month)
      unless @listing.availabilityLoadedFor(dates)
        @setLoading(true)
        @listing.withAvailabilityLoaded dates, =>
          # Will need to re-render for availability information
          @renderMonth(month)
      else
        @setLoading(false)

      super(month)

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

    setMode: (mode) ->
      @mode = mode

    toggleDate: (date) ->
      switch @mode
        when DatepickerModelWithModeAndConstraints.MODE_RANGE
          @setRangeTo(date)
          # extendRangeToFitConstraints()
          @trigger 'rangeApplied'

        when DatepickerModelWithModeAndConstraints.MODE_PICK
          super(date)
          # addOrRemoveDateAdjustingForConstraints(date)
          # NB: if trying to remove a single range, the above
          #     should re-add the range. i.e. can't remove the minimum
        #     range.

    setRangeTo: (date) ->
      startDate = @getDates()[0] || date

      if startDate.getTime() > date.getTime()
        startDate = date

      current = startDate
      while DNM.util.Date.toId(current) != DNM.util.Date.toId(date)
        @addDate(current) if @listing.availabilityFor(current) >= @listing.defaultQuantity
        current = new Date(current.getFullYear(), current.getMonth(), current.getDate()+1, 0, 0, 0)
      @addDate(date) if @listing.availabilityFor(date) >= @listing.defaultQuantity
