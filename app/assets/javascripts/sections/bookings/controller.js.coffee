# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialize with the bookings DOM container, and an options hash including
# JS objects representing each Listing on the Location.
class Bookings.Controller
  # Initialize the Bookings controller
  #
  # protected
  constructor: (@container, @options = {}) ->
    requested_bookings =  _.toArray(@options.requested_bookings)

    fetchCompleteCallback = $.noop()
    if !_.isEmpty(requested_bookings)
      fetchCompleteCallback = -> $("#book-#{requested_bookings[0].id}").trigger('click')

    @availabilityManager = new Bookings.AvailabilityManager(
      @options.availability_summary_url, fetchCompleteCallback
    )

    # The Listings collection is the set of all Listings being managed for bookings on
    # the page. Each listing keeps track of the bookings made on it.
    @listings = _.map @options.listings, (listingData) =>
      bookings = {}
      match_listing = _.find(requested_bookings, (bookings) ->  bookings.id == listingData.id.toString() )
      if match_listing != undefined
         _.each  match_listing.bookings, (bookingData) =>
           bookings[bookingData.date] = Number(bookingData.quantity)

      listing = new Bookings.Listing(
        listingData,
        availability: new Bookings.AvailabilityManager.Listing(@availabilityManager, listingData.id),
        bookings: bookings
      )

    # We automatically add a booking for 'tomorrow'
    tomorrow = new Date(new Date().getTime() + 24 * 60 * 60 * 1000)
    for listing in @listings
      if _.isEmpty(listing.bookings)
        listing.addDate(tomorrow)

    # Initialize each of the listing views
    @listingViews = $.map @listings, (listing) =>
      new Bookings.ListingView(listing, @container.find(".listing[data-listing-id=#{listing.id}]"))

    @bindEvents()

  bindEvents: ->
    # Show review booking for a single listing
    # On each of the listing views, watch for review triggering and trigger the review modal
    for listingView in @listingViews
      listingView.bind 'reviewTriggered', (listing) =>
        @reviewBooking([listing])

  # Return the listing with the specified ID from the Listing bookings collection
  findListing: (listingId) ->
    return listing for listing in @listings when listing.id is parseInt(listingId, 10)

  reviewBooking: (forListings = @listings) ->
    Modal.load({
      url: @options.review_url,
      type: 'POST',
      data: @bookingDataForReview(forListings)
    }, 'space-reservation-modal')

  # Build data for booking review
  #
  # forListings - The set of listings to gather booking parameters for. Defaults to all listings.
  bookingDataForReview: (forListings = @listings) ->
    listings = []
    for listing in forListings when listing.isBooked()
      listings.push {
        id: listing.id,
        bookings: listing.getBookings()
      }
    { listings: listings }

