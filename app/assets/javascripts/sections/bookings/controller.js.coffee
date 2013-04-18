# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialize with the bookings DOM container, and an options hash including
# JS objects representing each Listing on the Location.
class Bookings.Controller
  
  constructor: (@container, @listingData, @options = {}) ->
    @listing = new Bookings.Listing(@listingData)

    @setupMultiDatesPicker()
    @quantityField = @container.find('select.quantity')
    @totalElement = @container.find('.total')
    @resourceElement = @container.find('.resource')
    @daysElement = @container.find('.total-days')
    @bookButton = @container.find('[data-behavior=showReviewBookingListing]')
    @bindModel()
    @initializeQuantityField()
    @bindEvents()
 
    # Initialize default bookings
    # Determine if there are any bookings to assign that have been passed through
    initialDates = @options.initialBookings or [@listing.firstAvailableDate]
    @datepicker.setDates(initialDates)

    if @options.initialBookings and @options.showReviewBookingImmediately
      @reviewBooking()

  bindEvents: ->
    @bookButton.on 'click', (event) =>
      event.preventDefault()
      @reviewBooking()

    @quantityField.on 'change', (event) =>
      qty = parseInt($(event.target).val())
      qty = @validateQuantityAndUpdatePlural(qty)
      $(event.target).val(qty)
      @listing.setDefaultQuantity(qty)
      @listing.resetBookings()

    @datepicker.bind 'datesChanged', (dates) =>
      @listing.setDates(dates)

    @listing.bind 'bookingChanged', =>
      @updateSummary()
      if @listing.bookedDays().length == 0
        @bookButton.addClass('disabled')
        @bookButton.tooltip()
      else
        @bookButton.removeClass('disabled')
        @bookButton.tooltip('destroy')

  reviewBooking: (callback = -> ) ->
    return unless @listing.isBooked()

    @disableBookButton()
    Modal.load({
      url: @options.reviewUrl,
      type: 'POST',
      data: {
        listings: [{
          id: @listing.id,
          bookings: @listing.getBookings()
        }]
      }
    }, 'space-reservation-modal sign-up-modal', => @enableBookButton())

  bindModel: ->
    @listing.bind 'dateAdded', (date) =>
      @datepicker.addDate(date)

    @listing.bind 'dateRemoved', (date) =>
      @datepicker.removeDate(date)

  disableBookButton : () ->
      @bookButton.addClass('click-disabled').find('span').text('Booking...')

  enableBookButton : () ->
    $('.click-disabled').removeClass('click-disabled').find('span').text('Book')

  initializeQuantityField: (value = @listing.defaultQuantity) ->
    qty = @validateQuantityAndUpdatePlural(value)
    @quantityField.val(qty)
    @container.find('.customSelect.quantity .customSelectInner').text(qty)

  validateQuantityAndUpdatePlural: (qty) ->
    qty = 1 unless qty >= 0
    plural = if qty == 1 then '' else 's'
    @resourceElement.text("desk#{plural}")
    return qty

  updateSummary: ->
    @totalElement.text((@listing.bookingSubtotal()/100).toFixed(2))
    days = @listing.bookedDays().length
    plural = if days == 1 then '' else 's'
    @daysElement.text("#{days} day#{plural}")

  # Setup the datepicker for the simple booking UI
  setupMultiDatesPicker: ->
    @datepicker = new Bookings.Datepicker(
      listing: @listing
      startElement: @container.find(".calendar-wrapper.date-start")
      endElement: @container.find(".calendar-wrapper.date-end")
    )

