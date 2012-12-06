@Space.Booking = {}
class @Space.Booking.Controller

  constructor: (@container, @options = {}) ->
    @listings = $.map @options.listings, (listing) =>
      new Listing(this, listing)

    @summaryContainer = @container.find('.summary').hide()
    @_setupCalendar()
    @_setupMultiDatesPicker()
    @_bindEvents()

  addDateForBookings: (date, calendar = null) ->
    # Do we need availability info for days?
    needsLoading = !_.all @listings, (listing) =>
      listing.availabilityLoadedFor(date)

    # Callback to add date option to the listings
    addDateToListings = =>
      listing.addDate(date) for listing in @listings

    if needsLoading
      calendar.setLoading(date) if calendar
      $.ajax(@options.availability_summary_url, {
        dataType: 'json',
        data: { dates: [DNM.util.Date.toId(date)] },
        success: (data) =>
          calendar.setLoading(date, false) if calendar

          # Go through each response and add date info
          _.each data, (listingData) =>
            @findListing(listingData.id).addAvailability(listingData.availability)

          addDateToListings()
      })
    else
      addDateToListings()

  removeDateForBookings: (date) ->
    listing.removeDate(date) for listing in @listings

  _bindEvents: ->
    @summaryContainer.find('[data-behavior=showReviewBooking]').click (event) =>
      event.preventDefault()
      Modal.load({
        url: @options.review_url,
        type: 'POST',
        data: @bookingDataForReview()
      }, 'space-reservation-modal')

    # Show review booking for a single listing
    @container.find('[data-behavior=showReviewBookingListing]').click (event) =>
      event.preventDefault()
      listing_id = $(event.target).attr('data-listing-id')
      Modal.load({
        url: @options.review_url,
        type: 'POST',
        data: @bookingDataForReview([@findListing(listing_id)])
      })


  findListing: (listingId) ->
    return listing for listing in @listings when listing.id is parseInt(listingId, 10)

  # Build data for booking review
  bookingDataForReview: (forListings = @listings) ->
    listings = []
    for listing in forListings when listing.isBooked()
      listings.push {
        id: listing.id,
        bookings: listing.getBookings()
      }
    { listings: listings }

  # Update the summary of the bookings so far
  updateSummary: ->
    listings = 0
    days = []
    subtotal = 0
    for listing in @listings when listing.isBooked()
      listings += 1
      days = _.union(days, listing.bookedDays())
      subtotal += listing.bookingSubtotal()

    if listings > 0
      summaryText = Mustache.render(@summaryTemplate, {
        listings: listings,
        days: days.length,
        currency_symbol: @options.currencySymbol || '$',
        subtotal_dollars: (subtotal / 100).toFixed(2)
      })
      @summaryContainer.show().find('span').html(summaryText)
    else
      @summaryContainer.hide()

  # Notifiction received when bookings changed for a listing
  bookingsChanged: (listing) ->
    @updateSummary()


