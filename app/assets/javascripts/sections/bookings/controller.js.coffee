# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialized with the bookings DOM container, and an options hash including
# JS objects representing each Listing on the Location.
class Bookings.Controller

  constructor: (@container, @listingData, @options = {}) ->
    @setupDelayedMethods()
    @listing = new Bookings.Listing(@listingData)
    @bindDomElements()
    if @listing.withCalendars()
      @initializeDatepicker()
      @listing.setDates(@datepicker.getDates())
    @bindEvents()
    @updateQuantityField()

    if @listingData.initial_bookings and @options.submitFormImmediately
      if @options.submitFormImmediately == 'RFQ'
        @rfqBooking()
      else
        @reviewBooking()

    if @listing.isRecurringBooking()
      new Bookings.RecurringBookingController(@container.find('form[data-recurring-booking-form]'))
    @updateSummary()
    @delayedUpdateBookingStatus()

  # We need to set up delayed methods per each instance, not the prototype.
  # Otherwise, it will debounce for any instance calling the method.
  setupDelayedMethods: ->
    # A deferred version of the booking status view updating, so we don't
    # execute it multiple times in a short span of time.
    @delayedUpdateBookingStatus = _.debounce(->
      @updateBookingStatus()
    , 5)

  # Bind to the various DOM elements managed by this controller.
  bindDomElements: ->
    @quantityField = @container.find('select.quantity')
    @bookItOutContainer = @container.find('.book-it-out')
    @bookItOutCheck = @container.find('input#book_it_out')
    @bookItOutTotal = @bookItOutContainer.find('.total')
    @quantityResourceElement = @container.find('.quantity .resource')
    @totalElement = @container.find('.booking-body > .price .total')
    @daysElement = @container.find('.total-days')
    @additionalCharges = @container.find('[data-optional-charge-select]')
    @bookButton = @container.find('[data-behavior=reviewBooking]')
    @rfqButton = @container.find('[data-behavior=RFQ]')
    @bookForm = @bookButton.closest('form')
    @registrationUrl = @bookButton.data('registration-url')
    @securedDomain = @bookButton.data('secured')
    @storeReservationRequestUrl = @bookButton.data('store-reservation-request-url')
    @userSignedIn = @bookButton.data('user-signed-in')
    @bookingTabs = @container.find("[data-pricing-tabs] li a")
    if !@listing.withCalendars()
      @fixedPriceSelect = @container.find("[data-fixed-date-select]")
      @fixedPriceSelect.on 'change', (e) =>
        @updateBookingStatus()
        @updateBookItOut() if @listing.bookItOutAvailable()

    @setReservationType()


  bindEvents: ->
    @bookingTabs.on 'click', (event) =>
      @listing.setHourlyBooking(@hourlyBookingSelected())
      @setReservationType()
      @updateBookingStatus()

    @bookButton.on 'click', (event) =>
      @formTrigger = @bookButton

    @rfqButton.on 'click', (event) =>
      @formTrigger = @rfqButton

    @bookForm.on 'submit', (event) =>
      event.preventDefault()
      if @formTrigger == @bookButton
        @reviewBooking()
      else
        @rfqBooking()

    @quantityField.on 'change', (event) =>
      @quantityWasChanged()

    @additionalCharges.on 'change', (event) =>
      @delayedUpdateBookingStatus()
      @updateCharges()

    if @listing.bookItOutAvailable()
      @bookItOutContainer.on 'change','input', (event) =>
        @bookItOut(event.target)

    if @listing.withCalendars()
      @datepicker.bind 'datesChanged', (dates) =>
        @listing.setDates(dates)
        @delayedUpdateBookingStatus()

      @datepicker.bind 'timesChanged', (dates) =>
        @updateTimesFromTimePicker()

  setReservationType: ->
    if @hourlyBookingSelected()
      @bookForm.find('.reservation_type').val('hourly')
    else
      @bookForm.find('.reservation_type').val('daily')

  hourlyBookingSelected: ->
    @container.find("li[data-hourly]").hasClass('active')

  # Setup the datepicker for the simple booking UI
  initializeDatepicker: ->
    @datepicker = new Bookings.Datepicker({
      listing: @listing,
      container: @container,
      listingData: @listingData
    })

  updateTimesFromTimePicker: ->
    @updateBookingStatus()

  # Update the view to display pricing, date selections, etc. based on
  # current selected dates.
  updateBookingStatus: ->
    @updateSummary()
    if @fixedPriceSelect
      if @fixedPriceSelect.val()
        @listing.bookedDatesArray = [@fixedPriceSelect.val()]
        @listing.bookedDateAvailability = @fixedPriceSelect.find(':selected').data('availability')
        for option in @quantityField.find('option')
          if parseInt(option.value) > @listing.fixedAvailability()
            $(option).prop('disabled', true)
          else
            $(option).prop('disabled', false)
      else
        @listing.bookedDatesArray = []

    if !@listing.isBooked()
      @bookButton.addClass('disabled')
      @bookButton.tooltip()
    else
      @bookButton.removeClass('disabled')
      @bookButton.tooltip('destroy')

  disableBookButton: ->
    @bookButton.addClass('click-disabled').find('span.text').text('Booking...')

  disableRFQButton: ->
    @rfqButton.addClass('click-disabled').find('span.text').text('Requesting...')

  quantityWasChanged: (quantity = @quantityField.val())->
    @listing.setDefaultQuantity(parseInt(quantity, 10))
    @updateQuantityField()

    # Reset the datepicker if the booking is no longer available
    # with the new quantity.
    if @listing.withCalendars()
      @datepicker.reset() unless @listing.bookingValid()
    @updateSummary()

  updateQuantityField: (qty = @listing.defaultQuantity) ->
    @container.find('.customSelect.quantity .customSelectInner').text(qty)
    @quantityField.val(qty)
    if qty > 1
      @quantityResourceElement.text(@quantityResourceElement.data('plural'))
    else
      @quantityResourceElement.text(@quantityResourceElement.data('singular'))

  updateCharges: ->
    additionalChargeFields = @container.find("[data-additional-charges] input[name='reservation_request[additional_charge_ids][]']")
    reservationRequestForm = @container.find('[data-reservation-charges]')
    reservationRequestForm.empty()
    additionalChargeFields.clone().prependTo(reservationRequestForm)

  updateSummary: ->
    @totalElement.text((@listing.bookingSubtotal(@bookItOutSelected())/100).toFixed(2))

  reviewBooking: ->
    return unless @listing.isBooked()
    @disableBookButton()
    @setFormFields()

    if @userSignedIn
       @bookForm.unbind('submit').submit()
    else
      @storeFormFields()

  rfqBooking: ->
    return unless @listing.isBooked()
    @setFormFields()

    if @userSignedIn
      Modal.load({ type: @rfqButton.data('modal-method'), url: @rfqButton.data('modal-url'), data: @bookForm.serialize()})
    else
      @storeFormFields()

  setFormFields: ->
    @bookForm.find('[name="reservation_request[quantity]"]').val(@listing.reservationOptions().quantity)
    @bookForm.find('[name="reservation_request[book_it_out]"]').val(@bookItOutSelected())
    if @listing.withCalendars()
      @bookForm.find('[name="reservation_request[dates]"]').val(@listing.reservationOptions().dates)
      @bookForm.find('[name="reservation_request[start_on]"]').val(@listing.reservationOptions().start_on)
      @bookForm.find('[name="reservation_request[end_on]"]').val(@listing.reservationOptions().end_on)
      if @listing.isReservedHourly()
        @bookForm.find('[name="reservation_request[start_minute]"]').val(@listing.reservationOptions().start_minute)
        @bookForm.find('[name="reservation_request[end_minute]"]').val(@listing.reservationOptions().end_minute)

  storeFormFields: ->
    $.post @storeReservationRequestUrl, @bookForm.serialize() + "&commit=#{@formTrigger.data('behavior')}", (data) =>
      if @securedDomain
        Modal.load(@registrationUrl)
      else
        window.location.replace(@registrationUrl)

  bookItOutSelected: ->
    @listing.bookItOutAvailable() && @bookItOutCheck.is(':checked')

  updateBookItOut: ->
    if @listing.bookItOutAvailableForDate()
      @bookItOutContainer.show()
      @bookItOutTotal.text((@listing.bookItOutSubtotal()/100).toFixed(0))
    else
      @bookItOutContainer.hide()

  bookItOut: (element) ->
    if $(element).is(':checked')
      @bookItOutTotal.parents('.price').hide()
      @totalElement.text (@listing.bookItOutSubtotal()/100).toFixed(2)
      @listing.setDefaultQuantity @listing.fixedAvailability()
      @updateQuantityField()
      @quantityField.prop('disabled', true)
    else
      @bookItOutTotal.parents('.price').show()
      @quantityField.prop('disabled', false)
      @quantityWasChanged 1

