# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialized with the bookings DOM container, and an options hash including
# JS objects representing each Listing on the Location.
class Bookings.Controller

  constructor: (@container, @listingData, @options = {}) ->
    @setupDelayedMethods()

    @listing = new Bookings.Listing(@listingData)

    @bindDomElements()
    @initializeDatepicker()

    if @listing.isReservedHourly()
      @initializeTimePicker()

    @bindEvents()

    @assignInitialDates()
    @updateQuantityField()

    if @listingData.initial_bookings and @options.submitFormImmediately
      if @options.submitFormImmediately == 'RFQ'
        @rfqBooking()
      else
        @reviewBooking()

    if @listing.isRecurringBooking()
      new Bookings.RecurringBookingController(@container.find('form[data-recurring-booking-form]'))


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
    @quantityResourceElement = @container.find('.quantity .resource')
    @totalElement = @container.find('.total')
    @daysElement = @container.find('.total-days')
    @bookButton = @container.find('[data-behavior=reviewBooking]')
    @rfqButton = @container.find('[data-behavior=RFQ]')
    @bookForm = @bookButton.closest('form')
    @registrationUrl = @bookButton.data('registration-url')
    @securedDomain = @bookButton.data('secured')
    @storeReservationRequestUrl = @bookButton.data('store-reservation-request-url')
    @userSignedIn = @bookButton.data('user-signed-in')

  bindEvents: ->
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

    @datepicker.bind 'datesChanged', (dates) =>
      @listing.setDates(dates)
      @delayedUpdateBookingStatus()
      @timePicker.updateSelectableTimes() if @timePicker

  # Setup the datepicker for the simple booking UI
  initializeDatepicker: ->
    startElement = @container.find(".calendar-wrapper.date-start")
    endElement = @container.find(".calendar-wrapper.date-end")

    if @listing.isReservedHourly()
      @datepicker = new window.Datepicker(
        trigger: startElement,

        # Custom view to handle bookings availability display
        view: new Bookings.Datepicker.AvailabilityView(@listing,
          trigger: startElement,
          text: '<div class="datepicker-text-fadein">Select date</div>'
        ),

        # Limit to a single date selected at a time
        model: new window.Datepicker.Model.Single(
          allowDeselection: false
        )
      )

      @datepicker.bind 'datesChanged', (dates) =>
        date = dates[0]
        startElement.find('.calendar-text').text("#{DNM.util.Date.monthName(date, 3)} #{date.getDate()}")

        if @datepicker.getView().isVisible()
          @datepicker.hide()
          @timePicker.show()
    else
      # Special datepicker wrapper that handles the start/end date semantics,
      # ranges, pick/choose, etc.
      @datepicker = new Bookings.Datepicker(
        listing: @listing
        startElement: startElement
        endElement: endElement
      )

  # Sets up the time picker view controller which handles the user selecting the
  # start/end times for the reservation.
  initializeTimePicker: ->
    options = {
      openMinute: @listing.data.earliest_open_minute,
      closeMinute: @listing.data.latest_close_minute
    }

    if @listingData.initial_bookings && @listingData.initial_bookings.start_minute && @listingData.initial_bookings.end_minute
      options.startMinute = @listingData.initial_bookings.start_minute
      options.endMinute = @listingData.initial_bookings.end_minute
    @timePicker = new Bookings.TimePicker(
      @listing,
      @container.find('.time-picker'),
      options
    )


    @timePicker.on 'change', =>
      @updateTimesFromTimePicker()

  # Assign initial dates from a restored session or the default
  # start date.
  assignInitialDates: ->
    initialDates = if @listingData.initial_bookings
      # Format is:
      # {quantity: 1, dates: ['2013-11-04', ...] }
      @listing.setDefaultQuantity(@listingData.initial_bookings.quantity)

      # Map bookings to JS dates
      (DNM.util.Date.idToDate(date) for date in @listingData.initial_bookings.dates)
    else if @listing.isOvernightBooking()
      [@listing.firstAvailableDate, DNM.util.Date.next(@listing.firstAvailableDate), new Date()]
    else
      [@listing.firstAvailableDate]

    @datepicker.trigger 'datesChanged', initialDates
    @datepicker.setDates(initialDates)

  updateTimesFromTimePicker: ->
    @listing.setTimes(@timePicker.startMinute(), @timePicker.endMinute())
    @updateSummary()
    @updateBookingStatus()

  # Update the view to display pricing, date selections, etc. based on
  # current selected dates.
  updateBookingStatus: ->
    @updateSummary()
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

  quantityWasChanged: ->
    @listing.setDefaultQuantity(parseInt(@quantityField.val(), 10))
    @updateQuantityField()

    # Reset the datepicker if the booking is no longer available
    # with the new quantity.
    @datepicker.reset() unless @listing.bookingValid()
    @timePicker.updateSelectableTimes() if @timePicker
    @updateSummary()

  updateQuantityField: (qty = @listing.defaultQuantity) ->
    @container.find('.customSelect.quantity .customSelectInner').text(qty)
    @quantityField.val(qty)
    if qty > 1
      @quantityResourceElement.text(@quantityResourceElement.data('plural'))
    else
      @quantityResourceElement.text(@quantityResourceElement.data('singular'))

  updateSummary: ->
    @totalElement.text((@listing.bookingSubtotal()/100).toFixed(2))

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

