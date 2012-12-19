#= require_self
#= require ./calendar
#= require ./listing_view
#
# Contains all the view logic for the 'Advanced View' of the booking system
class @Bookings.Advanced.Controller extends Bookings.Controller

  # Template text for the summary area
  summaryTemplate: '''
    <strong>{{listings}} listings</strong> selected over a total of <strong>{{days}} days</strong> for <strong>{{currency_symbol}}{{subtotal_dollars}}</strong>
  '''

  constructor: (container, options = {}) ->
    super(container, options)

    # Set up the Calendar view component
    @setupCalendar()

    # Find the 'Summary' DOM component
    @summaryContainer = @container.find('.summary').hide()

    # Set up each of the 'listing' section views
    @listingViews = $.map @listings, (listing) =>
      new Bookings.Advanced.ListingView(listing, @container.find(".listing[data-listing-id=#{listing.id}]"))

    # Bind any relevant events
    @bindEvents()

  bindEvents: ->
    # Trigger the Booking Review modal when the review button is pressed
    @summaryContainer.find('[data-behavior=showReviewBooking]').click (event) =>
      event.preventDefault()
      @reviewBooking()

    # When a date is selected on the calendar, add it as a date available for bookings
    @calendar.onSelect (date) =>
      @addDateForBookings(date)

    # When a date is unselected on the calendar, remove it as a date available for bookings
    @calendar.onUnselect (date) =>
      @removeDateForBookings(date)

    # If any of the booking details change, we update the summary
    for listing in @listings
      listing.on 'bookingChanged', => @updateSummary()

  # Setup calendar for the advanced booking UI
  setupCalendar: ->
    return unless @container.find('#calendar').length > 0
    @calendar = new Bookings.Advanced.Calendar(@container.find('#calendar'))

  removeDateForBookings: (date) ->
    listing.removeDate(date) for listing in @listings

  addDateForBookings: (date) ->
    # Do we need availability info for days?
    needsLoading = !_.all @listings, (listing) =>
      listing.availabilityLoadedFor(date)

    # Callback to add date option to the listings
    addDateToListings = =>
      listing.addDate(date) for listing in @listings

    if needsLoading
      @calendar.setLoading(date)
      @availabilityManager.getAll date, =>
        @calendar.setLoading(date, false)
        addDateToListings()
    else
      addDateToListings()

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


