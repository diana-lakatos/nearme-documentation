class @Bookings.Simple.ListingView
  asEvented.call(ListingView.prototype)

  constructor: (@listing, @container) ->
    @setupMultiDatesPicker()
    @quantityField = @container.find('input.quantity')
    @totalElement = @container.find('.total')
    @daysElement = @container.find('.total-days')
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

    @quantityField.on 'change', (event) =>
      qty = parseInt($(event.target).val())
      qty = 1 unless qty >= 0
      @listing.setDefaultQuantity(qty, true)
      $(event.target).val(qty)

    @datepicker.bind 'datesChanged', (dates) =>
      @listing.setDates(dates)

    @listing.bind 'bookingChanged', =>
      @updateSummary()

  updateSummary: ->
    @totalElement.text((@listing.bookingSubtotal()/100).toFixed(2))
    days = @listing.bookedDays().length
    plural = if days == 1 then '' else 's'
    @daysElement.text("#{days} day#{plural}")

  # Setup the datepicker for the simple booking UI
  setupMultiDatesPicker: ->
    @datepicker = new Bookings.Simple.Datepicker(@container.find(".calendar input"), @listing)



