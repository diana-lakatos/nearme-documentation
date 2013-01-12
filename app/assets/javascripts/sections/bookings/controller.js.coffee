#= require_self
#= require ./advanced/controller
#= require ./simple/controller
#
# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialize with the bookings DOM container.
#
# The dom-container should have a data-view attribute with value of either "advanced" or "simple", for the
# two respective bookings view types.
#
# This class is a base controller, extended by the Advanced/Simple views. It provides common methods/logic.
class Bookings.Controller
  Bookings.Advanced = {}
  Bookings.Simple = {}

  # Initialize the relevant controller for the bookings container based on the type of view
  # (advanced or simple)
  #
  # Returns a Bookings controller
  @initialize: (@container, @options = {}) ->
    # Initialize the relevant view for the bookings
    view = switch container.attr('data-view')
      when "simple"   then Bookings.Simple.Controller
      when "advanced" then Bookings.Advanced.Controller
      else
        throw "No bookings view available."

    new view(container, options)

  # Initialize the Bookings controller
  #
  # protected
  constructor: (@container, @options = {}) ->
    @availabilityManager = new Bookings.AvailabilityManager(
      @options.availability_summary_url, @options.fetchCompleteCallback
    )

    # The Listings collection is the set of all Listings being managed for bookings on
    # the page. Each listing keeps track of the bookings made on it.
    requested_bookings =  _.toArray(@options.requested_bookings)
    @listings = $.map @options.listings, (listingData) =>
      requested_bookings_for_listing = []
      match_listing = _.find(requested_bookings, (bookings) ->  bookings.id == listingData.id.toString() )
      if match_listing != undefined
        requested_bookings_for_listing = match_listing.bookings
      listing = new Bookings.Listing(
        listingData,
        availability: new Bookings.AvailabilityManager.Listing(@availabilityManager, listingData.id),
        requested_bookings: @options.requested_bookings
      )


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

