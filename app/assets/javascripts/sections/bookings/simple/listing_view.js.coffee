class @Bookings.Simple.ListingView
  asEvented.call(ListingView.prototype)

  constructor: (@listing, @container) ->
    @setupMultiDatesPicker()
    @quantityField = @container.find('input.quantity')
    @bindModel()
    @bindEvents()

  bindModel: ->
    @listing.bind 'dateAdded', (date) =>
      @datepicker.addDate(date)

    @listing.bind 'dateRemoved', (date) =>
      @datepicker.removeDate(date)

  bindEvents: ->
    @container.find('[data-behavior=showReviewBookingListing]').click (event) =>
      event.preventDefault()
      @trigger 'reviewTriggered', @listing

    quantityChanged = (event) =>
      qty = parseInt($(event.target).val())
      @listing.setDefaultQuantity(qty, true)
      $(event.target).val(qty)

    @quantityField.on 'change', quantityChanged
    @quantityField.on 'keyup', quantityChanged

    @datepicker.bind 'datesChanged', (dates) =>
      @listing.setDates(dates)

    @listing.bind 'dateAdded', =>


  # Setup the datepicker for the simple booking UI
  setupMultiDatesPicker: ->
    @datepicker = new Bookings.Simple.Datepicker(@container.find(".calendar input"), @listing.getAvailabilityManager())



