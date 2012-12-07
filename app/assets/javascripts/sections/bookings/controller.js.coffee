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
    # The Listings collection is the set of all Listings being managed for bookings on
    # the page. Each listing keeps track of the bookings made on it.
    @listings = $.map @options.listings, (listing) =>
      new Bookings.Listing(listing)

  # Return the listing with the specified ID from the Listing bookings collection
  findListing: (listingId) ->
    return listing for listing in @listings when listing.id is parseInt(listingId, 10)

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

