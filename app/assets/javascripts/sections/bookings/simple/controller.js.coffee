# Contains all the view logic of the 'simple' view of the booking system
class @Bookings.Simple.Controller extends Bookings.Controller

  constructor: (container, options = {}) ->
    super(container, options)

    # On this view, we automatically add a booking for 'tomorrow'
    tomorrow = new Date(new Date().getTime() + 24 * 60 * 60 * 1000)
    for listing in @listings
      listing.addDate(tomorrow)

    # Initialize each of the listing views
    @listingViews = $.map @listings, (listing) =>
      new ListingView(listing, @container.find(".listing[data-listing-id=#{listing.id}]"))

    @bindEvents()

  bindEvents: ->
    # Show review booking for a single listing
    # On each of the listing views, watch for review triggering and trigger the review modal
    for listingView in @listingViews
      DNM.Event.observe listingView, 'reviewTriggered', (listing) =>
        @reviewBooking([listing])

  class ListingView

    constructor: (@listing, @container) ->
      @setupMultiDatesPicker()
      @quantityField = @container.find('input.quantity')
      @bindModel()
      @bindEvents()

    bindModel: ->
      DNM.Event.observe @listing, 'dateAdded', =>
        if @listing.bookedDates().length > 0
          @calendarContainer.multiDatesPicker('addDates', @listing.bookedDates())

    bindEvents: ->
      @container.find('[data-behavior=showReviewBookingListing]').click (event) =>
        event.preventDefault()
        DNM.Event.notify this, 'reviewTriggered', [@listing]

      quantityChanged = (event) =>
        qty = parseInt($(event.target).val())
        @listing.setDefaultQuantity(qty, true)
        $(event.target).val(qty)

      @quantityField.on 'change', quantityChanged
      @quantityField.on 'keyup', quantityChanged

    # Setup the datepicker for the simple booking UI
    setupMultiDatesPicker: ->
      @calendarContainer = @container.find(".calendar input")
      return unless @calendarContainer.length > 0

      # Automatically add tomorrow as a date to book
      @calendarContainer.multiDatesPicker(
        onSelect: (d, inst) =>
          inst.inline = true
          setTimeout((-> inst.inline = false), 500)

          dates = inst.input.multiDatesPicker('getDates', 'object')
          @listing.setDates(dates)
      )

      if @listing.bookedDates().length > 0
        @calendarContainer.multiDatesPicker('addDates', @listing.bookedDates())

      $('#ui-datepicker-div').wrap('<div class="jquery-ui-theme" />')


