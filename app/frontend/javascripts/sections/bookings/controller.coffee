# Controller for handling all of the booking selection logic on a Space page
#
# The controller is initialized with the bookings DOM container, and an options hash including
# JS objects representing each Listing on the Location.

BookingsListing = require('./listing')
BookingsDatepicker = require('./datepicker')
require('jquery.customSelect/jquery.customSelect')
require('select2/select2')
Modal = require('../../components/modal')
UtilUrl = require('../../lib/utils/url')

module.exports = class BookingsController

  constructor: (@container, @options = {}) ->
    @container = $(@container)
    @activateFirstAvailableTab()

    @listingData = @container.data('listing')
    if $.isEmptyObject(@listingData.initial_bookings)
      @listingData.initial_bookings = null
    @submitFormImmediately = @container.data('returned-from-session')
    @setupDelayedMethods()

    @listing = new BookingsListing(@listingData, @container)
    @bindDomElements()
    if @listing.withCalendars()
      @initializeDatepicker()
      @listing.setDates(@datepicker.getDates())

    @bindEvents()
    @listing.currentPricingId = @transactablePricing.val()
    if !@listing.withCalendars() && @fixedPriceSelect.length > 0
      @initializeInfiniScroll()
    @updateQuantityField()
    @initializeCtaButton()

    if @listingData.initial_bookings and @submitFormImmediately
      if @submitFormImmediately == 'RFQ'
        @rfqBooking()
      else
        @reviewBooking()
    return if @listing.onlyRfqAction()
    @updateSummary()
    @delayedUpdateBookingStatus()
    if !@listing.isPerUnitBooking()
      @quantityField.customSelect()

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
    @transactablePricing = @container.find('input[name="order[transactable_pricing_id]"]')
    @quantityField = @container.find('[name=quantity].quantity')
    @bookItOutContainer = @container.find('.book-it-out')
    @bookItOutCheck = @container.find('input[name="order[book_it_out]"]')
    @exclusivePriceContainer = @container.find('.exclusive-price')
    @exclusivePriceCheck = @exclusivePriceContainer.find('input')
    @exclusivePriceContent = @container.find('div[data-exclusive-price-content]')
    @bookItOutTotal = @bookItOutContainer.find('.discount_price span')
    @quantityResourceElement = @container.find('.quantity .resource')
    @totalElement = @container.find('.book .price .total')
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
      @fixedPriceSelectInit = @fixedPriceSelect.data('init-value')
      @fixedPriceSelect.on 'change', (e) =>
        @updateBookingStatus()
        @updateBookItOut() if @listing.bookItOutAvailable()
        @exclusivePrice() if @listing.exclusivePriceAvailable()

    @setReservationType()

  bindEvents: ->

    @bookingTabs.on 'shown.bs.tab', (event) =>
      @listing.currentPricingId = $(event.target).parents('li').data('pricing-id')
      @listing.setHourlyBooking(@hourlyBookingSelected())
      @datepicker.setDates(@listing.bookedDatesArray)
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

    @quantityField.on 'change paste keyup', (event) =>
      @quantityWasChanged()

    @additionalCharges.on 'change', (event) =>
      @delayedUpdateBookingStatus()
      @updateCharges()

    @bookItOutContainer.on 'change','input', (event) =>
      @bookItOut(event.target)

    @exclusivePriceCheck.on 'change', (event) =>
      @exclusivePrice()

    if @listing.withCalendars()
      @datepicker.bind 'datesChanged', (dates) =>
        @listing.setDates(dates)
        @delayedUpdateBookingStatus()

      @datepicker.bind 'timesChanged', (dates) =>
        @updateTimesFromTimePicker()

    if @exclusivePriceCheck.data('force-check') == 1
      @exclusivePriceCheck.on 'change', ->
        # do not allow to uncheck
        $(@).prop('checked', true)
      @exclusivePriceCheck.trigger('change')

  activateFirstAvailableTab: ->
    @container.find(".pricing-tabs a.possible:first").tab('show')

  setReservationType: ->
    if @hourlyBookingSelected()
      @bookForm.find('.reservation_type').val('hourly')
    else
      @bookForm.find('.reservation_type').val('daily')

  hourlyBookingSelected: ->
    @container.find("li[data-unit='hour']").hasClass('active')

  # Setup the datepicker for the simple booking UI
  initializeDatepicker: ->
    @datepicker = new BookingsDatepicker({
      listing: @listing,
      container: @container,
      listingData: @listingData
    })

  updateTimesFromTimePicker: ->
    @updateBookingStatus()

  # Update the view to display pricing, date selections, etc. based on
  # current selected dates.
  updateBookingStatus: ->
    @transactablePricing.val(@listing.currentPricingId)
    if @fixedPriceSelect
      if @fixedPriceSelect.val()
        @listing.bookedDatesArray = [@fixedPriceSelect.val()]
        @listing.bookedDateAvailability = (@fixedPriceSelect.select2('data') || @fixedPriceSelectInit).availability
        if !@listing.isPerUnitBooking()
          for option in @quantityField.find('option')
            if parseInt(option.value) > @listing.fixedAvailability()
              $(option).prop('disabled', true)
            else
              $(option).prop('disabled', false)
          if parseInt(@quantityField.find('option:selected').val(), 10) > @listing.fixedAvailability()
            @quantityField.val("#{@listing.fixedAvailability()}")
            @quantityField.trigger('change')
      else
        @listing.bookedDatesArray = []
    else
      @updateSummary()

    if !@listing.isBooked()
      @bookButton.addClass('disabled')
      @bookButton.removeAttr("data-disable-with")
      @bookButton.tooltip()
    else
      @bookButton.removeClass('disabled')
      @bookButton.attr("data-disable-with", "Processing ...")
      @bookButton.tooltip('destroy')


  quantityWasChanged: (quantity = @quantityField.val()) ->
    quantity = quantity.replace(',', '.') if quantity.replace
    @listing.setDefaultQuantity(parseFloat(quantity, 10))
    @updateQuantityField() unless @listing.isPerUnitBooking()

    # Reset the datepicker if the booking is no longer available
    # with the new quantity.
    if @listing.withCalendars()
      @datepicker.reset() unless @listing.bookingValid()
    @updateSummary()

  updateQuantityField: (qty = @listing.defaultQuantity) ->
    if !@listing.isPerUnitBooking()
      @container.find('.customSelect.quantity .customSelectInner').text(qty)

    @quantityField.val(qty)
    if qty > 1
      @quantityResourceElement.text(@quantityResourceElement.data('plural'))
    else
      @quantityResourceElement.text(@quantityResourceElement.data('singular'))

  updateCharges: ->
    additionalChargeFields = @container.find("[data-additional-charges] input[name='order[additional_charge_ids][]']")
    reservationRequestForm = @container.find('[data-reservation-charges]')
    reservationRequestForm.empty()
    additionalChargeFields.clone().prependTo(reservationRequestForm)

  updateSummary: ->
    price = @listing.bookingSubtotal(@bookItOutSelected(), @exclusivePriceSelected())
    @totalElement.text(
      (price/@listing.data.subunit_to_unit_rate).toFixed(2)
    )

  reviewBooking: ->
    return unless @listing.isBooked()
    @setFormFields()

    if @userSignedIn
      @bookForm.unbind('submit').submit()
    else
      @storeFormFields()

  rfqBooking: ->
    @setFormFields()

    if @userSignedIn
      Modal.load { type: @rfqButton.data('modal-method'), url: @rfqButton.data('modal-url'), data: @bookForm.serialize()}, null, false, =>
        $.rails.enableFormElement(@bookButton)
        $.rails.enableFormElement(@rfqButton)
    else
      @storeFormFields()

  setFormFields: ->
    options = @listing.reservationOptions()
    @bookForm.find('[name="order[quantity]"]').val(options.quantity)
    @bookForm.find('[name="order[book_it_out]"]').val(options.book_it_out || @bookItOutSelected())
    @bookForm.find('[name="order[exclusive_price]"]').val(options.exclusive_price || @exclusivePriceSelected())
    data_guest_notes = @container.find('[data-guest-notes]')
    @bookForm.find('[name="order[dates]"]').val(options.dates)
    if data_guest_notes && data_guest_notes.is(':visible')
      @bookForm.find('[name="order[guest_notes]"]').val(options.guest_notes || data_guest_notes.val())
    if @listing.withCalendars()
      @bookForm.find('[name="order[start_on]"]').val(options.start_on)
      @bookForm.find('[name="order[end_on]"]').val(options.end_on)
      if @listing.isReservedHourly()
        @bookForm.find('[name="order[start_minute]"]').val(options.start_minute)
        @bookForm.find('[name="order[end_minute]"]').val(options.end_minute)

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
      @bookItOutTotal.text('-' + @listing.bookItOutDiscount() + ' %')
    else
      @bookItOutContainer.hide()

  bookItOut: (element) ->
    if $(element).is(':checked')
      @exclusivePriceCheck.prop('checked', false).trigger('change')
      # @bookItOutTotal.parents('.discount_price').hide()
      @totalElement.text (@listing.bookItOutSubtotal()/@listing.data.subunit_to_unit_rate).toFixed(2)
      @quantityWasChanged @listing.bookItOutMin()
      for option in @quantityField.find('option')
        if parseInt(option.value) < @listing.bookItOutMin()
          $(option).prop('disabled', true)
        else
          $(option).prop('disabled', false)
      @updateQuantityField()
      # @quantityField.prop('disabled', true)
    else
      # @bookItOutTotal.parents('.discount_price').show()
      @quantityField.find('option').prop('disabled', false)
      # @quantityField.prop('disabled', false)
      @quantityWasChanged 1

  exclusivePriceSelected: ->
    @listing.exclusivePriceAvailable() && (@exclusivePriceCheck.is(':checked') || @exclusivePriceCheck.data('force-check') == 1)

  exclusivePrice: ->
    if @exclusivePriceSelected()
      @bookItOutCheck.prop('checked', false).trigger('change')
      @exclusivePriceContainer.find('.discount_price').hide()
      @quantityField.prop('disabled', true)
      @container.find('div.quantity').hide()
      @exclusivePriceContent.show() if @exclusivePriceContent
      @updateSummary()
    else
      @container.find('div.quantity').show()
      @exclusivePriceContainer.find('.discount_price').show()
      @quantityField.prop('disabled', false)
      @exclusivePriceContent.hide() if @exclusivePriceContent
      @updateSummary()

  initializeInfiniScroll: ->
    startDate = UtilUrl.getParameterByName('start_date')
    endDate = UtilUrl.getParameterByName('end_date')
    @fixedPriceSelect.select2
      placeholder: 'Select date'
      ajax:
        url: "/listings/#{@listing.getId()}/occurrences"
        dataType: 'json'
        data: (term, page) ->
          {
            q: term
            page: page
            last_occurrence: $(this).data('last_occurrence')
            start_date: new Date(startDate).toDateString() unless startDate == ''
            end_date: new Date(endDate).toDateString() unless endDate == ''
          }
        results: (data, page) =>
          more = (data.length == 10)
          @fixedPriceSelect.data('last_occurrence', data[-1..][0].id) if data.length > 0
          {
            results: data
            more: more
          }
        cache: true
      minimumResultsForSearch: -1
      formatLoadMore: 'Loading...'
      formatNoMatches: 'No dates found'
      escapeMarkup: (m) ->
        m
    @container.find(".select2-chosen").text(@fixedPriceSelectInit.text)
    @fixedPriceSelect.val(@fixedPriceSelectInit.id)
    @fixedPriceSelect.trigger('change')

  initializeCtaButton: ->
    @bookButton.add(@rfqButton).attr('disabled', false)
