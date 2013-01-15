# Contains all the view logic of the 'simple' view of the booking system
class @Bookings.Simple.Controller extends Bookings.Controller

  constructor: (container, options = {}) ->
    super(container, options)
    # On this view, we automatically add a booking for 'tomorrow' if there is no other preset dates
    tomorrow = new Date(new Date().getTime() + 24 * 60 * 60 * 1000)
    for listing in @listings
      if !_.isEmpty(listing.bookings)
        listing.addDate(tomorrow)

    # Initialize each of the listing views
    @listingViews = $.map @listings, (listing) =>
      new Bookings.Simple.ListingView(listing, @container.find(".listing[data-listing-id=#{listing.id}]"))

    @bindEvents()
 
  bindEvents: ->
    # Show review booking for a single listing
    # On each of the listing views, watch for review triggering and trigger the review modal
    for listingView in @listingViews
      listingView.bind 'reviewTriggered', (listing) =>
        @reviewBooking([listing])
