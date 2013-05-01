# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialize with the bookings DOM container, and an options hash including
# JS objects representing each Listing on the Location.
class Bookings.Controller
  
  constructor: (@container, @listingData, @options = {}) ->
    @listing = new Bookings.Listing(@listingData)

    @bindDomElements()
    @initializeDatepicker()
    @bindEvents()
 
    @assignInitialDates()
    @updateQuantityField()

    if @listingData.initial_bookings and @options.showReviewBookingImmediately
      @reviewBooking()

  # Bind to the various DOM elements managed by this controller.
  bindDomElements: ->
    @quantityField = @container.find('select.quantity')
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
    @datepicker = new Bookings.Datepicker(
      listing: @listing
      startElement: @container.find(".calendar-wrapper.date-start")
      endElement: @container.find(".calendar-wrapper.date-end")
    )

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
        reservation: {
          dates: @listing.bookedDays(),
          quantity: @listing.getQuantity()
        }
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
    @listing.setDefaultQuantity(parseInt($(event.target).val()))
    @updateQuantityField()

    # Reset the datepicker if the booking is no longer available
    # with the new quantity.
    @datepicker.reset() unless @listing.bookingValid()
    @updateSummary()

  updateQuantityField: (qty = @listing.defaultQuantity) ->
    @container.find('.customSelect.quantity .customSelectInner').text(qty)
    @quantityField.val(qty)

  updateSummary: ->
    @totalElement.text((@listing.bookingSubtotal()/100).toFixed(2))


