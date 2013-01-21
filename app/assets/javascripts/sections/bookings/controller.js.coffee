# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialize with the bookings DOM container.
#
# The dom-container should have a data-view attribute with value of either "advanced" or "simple", for the
# two respective bookings view types.
#
# This class is a base controller, extended by the Advanced/Simple views. It provides common methods/logic.
class Bookings.Controller
  # Initialize the Bookings controller
  #
  # protected
  constructor: (@container, @options = {}) ->
    @availabilityManager = new Bookings.AvailabilityManager(
      @options.availability_summary_url
    )

    # The Listings collection is the set of all Listings being managed for bookings on
    # the page. Each listing keeps track of the bookings made on it.
    @listings = $.map @options.listings, (listingData) =>
      listing = new Bookings.Listing(
        listingData,
        availability: new Bookings.AvailabilityManager.Listing(@availabilityManager, listingData.id)
      )

    # We automatically add a booking for 'tomorrow'
    tomorrow = new Date(new Date().getTime() + 24 * 60 * 60 * 1000)
    for listing in @listings
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

