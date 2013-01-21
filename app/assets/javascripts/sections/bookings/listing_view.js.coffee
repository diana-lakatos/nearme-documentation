class @Bookings.ListingView
  asEvented.call(ListingView.prototype)

  constructor: (@listing, @container) ->
    @setupMultiDatesPicker()
    @quantityField = @container.find('select.quantity')
    @totalElement = @container.find('.total')
    @resourceElement = @container.find('.resource')
    @daysElement = @container.find('.total-days')
    @bookButton = @container.find('[data-behavior=showReviewBookingListing]')
    @bindModel()
    @bindEvents()

  bindModel: ->
    @listing.bind 'dateAdded', (date) =>
      @datepicker.addDate(date)

    @listing.bind 'dateRemoved', (date) =>
      @datepicker.removeDate(date)

  bindEvents: ->
    @bookButton.click (event) =>
      event.preventDefault()
      return if @listing.bookedDays().length is 0
      @trigger 'reviewTriggered', @listing

    @quantityField.on 'change', (event) =>
      qty = parseInt($(event.target).val())
      qty = 1 unless qty >= 0
      @listing.setDefaultQuantity(qty, true)
      $(event.target).val(qty)
      plural = if qty == 1 then '' else 's'
      @resourceElement.text("desk#{plural}")

    @datepicker.bind 'datesChanged', (dates) =>
      @listing.setDates(dates)

    @listing.bind 'bookingChanged', =>
      @updateSummary()
      @bookButton.toggleClass('disabled', @listing.bookedDays().length is 0)

  updateSummary: ->
    @totalElement.text((@listing.bookingSubtotal()/100).toFixed(2))
    days = @listing.bookedDays().length
    plural = if days == 1 then '' else 's'
    @daysElement.text("#{days} day#{plural}")

  # Setup the datepicker for the simple booking UI
  setupMultiDatesPicker: ->
    @datepicker = new Bookings.Datepicker(@container.find(".calendar-wrapper"), @listing)



