# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialize with the bookings DOM container, and an options hash including
# JS objects representing each Listing on the Location.
class Bookings.Controller
  
  constructor: (@container, @options = {}) ->
    @options.initial_bookings ||= {}

    # The Listings collection is the set of all Listings being managed for bookings on
    # the page. Each listing keeps track of the bookings made on it.
    @listings = _.map @options.listings, (listingData) =>
      new Bookings.Listing(listingData)

    # Initialize each of the listing views
    @listingViews = _.map @listings, (listing) =>
      new Bookings.ListingView(listing, @container.find(".listing[data-listing-id=#{listing.id}]"))

    # Initialize default bookings
    listingsWithRestoredBookings = []
    for listing in @listings
      # Determine if there are any bookings to assign that have been passed through
      if initialBookings = @options.initial_bookings[listing.id.toString()]
        # We set the bookings - passing false as second argument to add them instantly, rather than
        # deferring to availability loaded.
        #
        # FIXME: We should remove that availability behaviour from the model?
        listing.setBookings(initialBookings, false)

      if listing.isBooked()
        listingsWithRestoredBookings.push listing
      else
        # We automatically add a booking for 'tomorrow'
        listing.addDate(listing.firstAvailableDate) if !listing.isBooked()

    @bindEvents()

    # Check whether this is a restored session from a peviously logged out user.
    if @options.returnedFromSession and listingsWithRestoredBookings.length > 0
      @reviewBooking(listingsWithRestoredBookings)

  bindEvents: ->
    # Show review booking for a single listing
    # On each of the listing views, watch for review triggering and trigger the review modal
    for listingView in @listingViews
      listingView.bind 'reviewTriggered', (listing, callback = ->) =>
        @reviewBooking([listing], callback)

  # Return the listing with the specified ID from the Listing bookings collection
  findListing: (listingId) ->
    return listing for listing in @listings when listing.id is parseInt(listingId, 10)

  reviewBooking: (forListings = @listings, callback = -> ) ->
    Modal.load({
      url: @options.review_url,
      type: 'POST',
      data: @bookingDataForReview(forListings)
    }, 'space-reservation-modal sign-up-modal', callback)

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

