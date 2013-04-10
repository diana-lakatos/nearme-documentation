# This class essentially handles any display logic specific to the Listing row/element on the page.
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
    @initQuantity()

  initQuantity: ->
   if @listing.defaultQuantity != 1
      qty = @validateQuantityAndUpdatePlural(@listing.defaultQuantity)
      @quantityField.val(qty)
      @quantityField.find('option[value="' + qty + '"]').attr("selected",true)
      @container.find('.customSelect.quantity .customSelectInner').text(qty)

  bindModel: ->
    @listing.bind 'dateAdded', (date) =>
      @datepicker.addDate(date)

    @listing.bind 'dateRemoved', (date) =>
      @datepicker.removeDate(date)

  bindEvents: ->
    @bookButton.click (event) =>
      event.preventDefault()
      return if @listing.bookedDays().length is 0
      @disableBookButton()
      @trigger 'reviewTriggered', @listing, =>
        @enableBookButton()

    @quantityField.on 'change', (event) =>
      qty = parseInt($(event.target).val())
      qty = @validateQuantityAndUpdatePlural(qty)
      $(event.target).val(qty)
      @listing.setDefaultQuantity(qty)
      @listing.resetBookings()

    @datepicker.bind 'datesChanged', (dates) =>
      @listing.setDates(dates)

    @listing.bind 'bookingChanged', =>
      @updateSummary()
      if @listing.bookedDays().length == 0
        @bookButton.addClass('disabled')
        @bookButton.tooltip()
      else
        @bookButton.removeClass('disabled')
        @bookButton.tooltip('destroy')

  disableBookButton : () ->
      @bookButton.addClass('click-disabled').find('span').text('Booking...')

  enableBookButton : () ->
    $('.click-disabled').removeClass('click-disabled').find('span').text('Book')

  validateQuantityAndUpdatePlural: (qty) ->
    qty = 1 unless qty >= 0
    plural = if qty == 1 then '' else 's'
    @resourceElement.text("desk#{plural}")
    return qty

  updateSummary: ->
    @totalElement.text((@listing.bookingSubtotal()/100).toFixed(2))
    days = @listing.bookedDays().length
    plural = if days == 1 then '' else 's'
    @daysElement.text("#{days} day#{plural}")

  # Setup the datepicker for the simple booking UI
  setupMultiDatesPicker: ->
    @datepicker = new Bookings.Datepicker(
      listing: @listing
      startElement: @container.find(".calendar-wrapper.date-start")
      endElement: @container.find(".calendar-wrapper.date-end")
    )
