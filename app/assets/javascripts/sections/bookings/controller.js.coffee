# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialize with the bookings DOM container, and an options hash including
# JS objects representing each Listing on the Location.
class Bookings.Controller

  constructor: (@container, @listingData, @options = {}) ->
    @listing = new Bookings.Listing(@listingData)

    @bindDomElements()
    @initializeDatepicker()

    if @listing.isReservedHourly()
      @initializeTimePicker()

    @bindEvents()

    @assignInitialDates()
    @updateQuantityField()

    if @listingData.initial_bookings and @options.showReviewBookingImmediately
      @reviewBooking()

  # Bind to the various DOM elements managed by this controller.
  bindDomElements: ->
    @quantityField = @container.find('select.quantity')
    @quantityResourceElement = @container.find('.quantity .resource')
    @totalElement = @container.find('.total')
    @daysElement = @container.find('.total-days')
    @bookButton = @container.find('[data-behavior=showReviewBookingListing]')

  bindEvents: ->
    @bookButton.on 'click', (event) =>
      event.preventDefault()
      @reviewBooking()

    @quantityField.on 'change', (event) =>
      @quantityWasChanged()

    @datepicker.bind 'datesChanged', (dates) =>
      @listing.setDates(dates)
      @delayedUpdateBookingStatus()

  # Setup the datepicker for the simple booking UI
  initializeDatepicker: ->
    startElement = @container.find(".calendar-wrapper.date-start")
    endElement = @container.find(".calendar-wrapper.date-end")

    if @listing.isReservedHourly()
      @datepicker = new window.Datepicker(
        trigger: startElement,

        # Custom view to handle bookings availability display
        view: new Bookings.Datepicker.AvailabilityView(@listing,
          trigger: startElement,
          text: '<div class="datepicker-text-fadein">Select date</div>'
        ),

        # Limit to a single date selected at a time
        model: new window.Datepicker.Model.Single(
          allowDeselection: false
        )
      )

      @datepicker.bind 'datesChanged', (dates) =>
        date = dates[0]
        startElement.find('.calendar-text').text("#{DNM.util.Date.monthName(date, 3)} #{date.getDate()}")
    else
      # Special datepicker wrapper that handles the start/end date semantics,
      # ranges, pick/choose, etc.
      @datepicker = new Bookings.Datepicker(
        listing: @listing
        startElement: startElement
        endElement: endElement
      )

  initializeTimePicker: ->
    @timePicker = new Bookings.TimePicker(
      @container.find('.time-picker')
    )

    @timePicker.on 'change', =>
      @updateTimesFromTimePicker()

    @updateTimesFromTimePicker()

  # Assign initial dates from a restored session or the default
  # start date.
  assignInitialDates: ->
    initialDates = if @listingData.initial_bookings
      # Format is:
      # {quantity: 1, dates: ['2013-11-04', ...] }
      @listing.setDefaultQuantity(@listingData.initial_bookings.quantity)

      # Map bookings to JS dates
      (DNM.util.Date.idToDate(date) for date in @listingData.initial_bookings.dates)
    else
      [@listing.firstAvailableDate]

    @datepicker.setDates(initialDates)

  updateTimesFromTimePicker: ->
    @listing.setStartMinute(@timePicker.startMinute())
    @listing.setEndMinute(@timePicker.endMinute())
    @updateSummary()

  # Trigger showing the review booking form based on selected
  # dates.
  reviewBooking: (callback = -> ) ->
    return unless @listing.isBooked()

    @disableBookButton()
    Modal.load({
      url: @listingData.review_url,
      type: 'POST',
      data: {
        listing_id: @listing.id,
        reservation: @listing.reservationOptions()
      }
    }, 'space-reservation-modal', => @enableBookButton())

  # Update the view to display pricing, date selections, etc. based on
  # current selected dates.
  updateBookingStatus: ->
    @updateSummary()
    if !@listing.isBooked()
      @bookButton.addClass('disabled')
      @bookButton.tooltip()
    else
      @bookButton.removeClass('disabled')
      @bookButton.tooltip('destroy')

  # A deferred version of the booking status view updating, so we don't
  # execute it multiple times in a short span of time.
  delayedUpdateBookingStatus: _.debounce(->
    @updateBookingStatus()
  , 5)

  disableBookButton: ->
    @bookButton.addClass('click-disabled').find('span.text').text('Booking...')

  enableBookButton: ->
    $('.click-disabled').removeClass('click-disabled').find('span.text').text('Book')

  quantityWasChanged: ->
    @listing.setDefaultQuantity(parseInt(@quantityField.val(), 10))
    @updateQuantityField()

    # Reset the datepicker if the booking is no longer available
    # with the new quantity.
    @datepicker.reset() unless @listing.bookingValid()
    @updateSummary()

  updateQuantityField: (qty = @listing.defaultQuantity) ->
    @container.find('.customSelect.quantity .customSelectInner').text(qty)
    @quantityField.val(qty)
    if qty > 1
      @quantityResourceElement.text(@quantityResourceElement.data('plural'))
    else
      @quantityResourceElement.text(@quantityResourceElement.data('singular'))

  updateSummary: ->
    @totalElement.text((@listing.bookingSubtotal()/100).toFixed(2))


