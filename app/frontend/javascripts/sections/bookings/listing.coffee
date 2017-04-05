SubscriptionPriceCalculator = require('./price_calculator/subscription_price_calculator')
HourlyPriceCalculator = require('./price_calculator/hourly_price_calculator')
FixedPriceCalculator = require('./price_calculator/fixed_price_calculator')
PerUnitPriceCalculator = require('./price_calculator/per_unit_price_calculator')
PriceCalculator = require('./price_calculator')
Availability = require('./availability/availability')
ScheduleAvailability = require('./availability/schedule_availability')
HourlyAvailability = require('./availability/hourly_availability')
dateUtil = require('../../lib/utils/date')
asEvented = require('asevented')

# Each Listing has it's own object which keeps track of number booked, availability etc.
module.exports = class BookingListing
  asEvented.call @prototype

  defaultQuantity: 1

  constructor: (@data, @container) ->
    @id = parseInt(@data.id, 10)
    @bookedDatesArray = []
    @bookedDateAvailability = 0
    @maxQuantity = @data.quantity
    @initial_bookings = @data.initial_bookings || {}
    @possibleUnits = @data.possible_units
    @pricings = @data.pricings
    @no_action = @data.no_action

    if @withCalendars()
      if @canBeSubscribed()
        @firstAvailableDate = @minimumDate = dateUtil.idToDate(@data.minimum_date)
        @maximumDate = dateUtil.idToDate(@data.maximum_date)
        @availability = new ScheduleAvailability(@data.availability)
      else
        @firstAvailableDate = dateUtil.idToDate(@data.first_available_date)
        @secondAvailableDate = dateUtil.idToDate(@data.second_available_date)
        if @canReserveHourly()
          @availability = new HourlyAvailability(
            @data.availability,
            @data.hourly_availability_schedule,
            @data.hourly_availability_schedule_url
          )
        else
          @availability = new Availability(@data.availability)

        @minimumDate = dateUtil.idToDate(@data.minimum_date)
        @maximumDate = dateUtil.idToDate(@data.maximum_date)
        @favourablePricingRate = @data.favourable_pricing_rate
        @pricesByHours = @data.prices_by_hours
        @pricesByDays = @data.prices_by_days
        @pricesByNights = @data.prices_by_nights
        @hourlyPrice = @data.hourly_price_cents
        @minimumBookingMinutes = @data.minimum_booking_minutes
    else
      @fixedPrice = @data.fixed_price_cents
      @exclusivePrice = @data.exclusive_price_cents

  setDefaultQuantity: (qty) ->
    @trigger 'quantityChanged'
    @defaultQuantity = qty if qty >= 0

  setHourlyBooking: (hourlyBooking) ->
    if hourlyBooking
      @bookedDatesArray = @bookedDatesArray.slice(0,1)
    @data.action_hourly_booking = hourlyBooking

  getId: ->
    @id

  getQuantity: ->
    @defaultQuantity

  getMaxQuantity: ->
    @maxQuantity

  hasFavourablePricingRate: ->
    @favourablePricingRate

  # If the listing is an overnight booking we have to select +1 day in calendar
  minimumBookingDays: ->
    if @isOvernightBooking()
      @data.minimum_booking_days + 1
    else
      @data.minimum_booking_days

  onlyRfqAction: ->
    @possibleUnits.length == 0 && @data.action_rfq

  canReserveHourly: ->
    'hour' in @possibleUnits

  canReserveDaily: ->
    'day' in @possibleUnits || 'night' in @possibleUnits

  canBePurchased: ->
    'item' in @possibleUnits

  canBeSubscribed: ->
    'subscription_day' in @possibleUnits || 'subscription_month' in @possibleUnits

  isReservedHourly: ->
    @container.find('.pricing-tabs li.active').data('unit') == 'hour'

  isSubscriptionBooking: ->
    @container.find('.pricing-tabs li.active').data('unit') && @container.find('.pricing-tabs li.active').data('unit').indexOf('subscription') > -1

  isPurchaseAction: ->
    $('.pricing-tabs li.active').data('unit') == 'item'

  isOvernightBooking: ->
    @container.find('.pricing-tabs li.active').data('unit') == 'night'

  isFixedBooking: ->
    @data.booking_type == 'schedule'

  withCalendars: ->
    @canBeSubscribed() || ((@canReserveHourly() || @canReserveDaily()) && @data.first_available_date?)

  isReservedDaily: ->
    @container.find('.pricing-tabs li.active').data('unit') == 'day'

  isPerUnitBooking: ->
    @data.action_price_per_unit

  currentUnit: ->
    @container.find('.pricing-tabs li.active').data('unit')

  # Returns whether the date is within the bounds available for booking
  dateWithinBounds: (date) ->
    time = date.getTime()
    return false if time < @minimumDate.getTime()
    return false if time > @maximumDate.getTime()
    true

  canBookDate: (date, min) ->
    # clt = current location zone time
    clt = new Date()
    clt.setHours(clt.getHours() + @data.zone_offset)
    clt.setHours(clt.getHours() + (clt.getTimezoneOffset() / 60))

    period_starts = new Date(date)
    period_starts.setMinutes(min % 60)
    period_starts.setHours(parseInt(min / 60))

    if (period_starts.getTime() < clt.getTime())
      return false

    @availabilityFor(date, min) >= @defaultQuantity || (@isOvernightBooking() && @firstUnavailableDay(date, min))

  availabilityFor: (date, minute = null) ->
    @availability.availableFor(date, minute)

  firstUnavailableDay: (date, minute = null) ->
    @availability.firstUnavailableDay(date, minute)

  bookItOutMin: ->
    @data.book_it_out_minimum_qty

  bookItOutDiscount: ->
    @data.book_it_out_discount

  bookItOutAvailable: ->
    @isFixedBooking() && @data.book_it_out_discount > 0

  exclusivePriceAvailable: ->
    @data.exclusive_price_cents > 0

  bookItOutAvailableForDate: ->
    @bookItOutAvailable() && @fixedAvailability() >= @data.book_it_out_minimum_qty

  fixedAvailability: ->
    @bookedDateAvailability

  openFor: (date) ->
    @availability.openFor(date)

  isBooked: ->
    return true if @canBePurchased()
    hasDate = @bookedDates().length > 0
    hasTime = if @isReservedHourly() && @withCalendars()
      @minutesBooked() > 0
    else
      true
    hasDate and hasTime


  # Return the days where there exist bookings
  bookedDays: ->
    (dateUtil.toId(date) for date in @bookedDates())

  # Return the days where bookings exist as Date objects
  bookedDates: ->
    @bookedDatesArray

  # Return the subtotal for booking this listing
  bookingSubtotal: (book_it_out = false, exclusive_price = false) ->
    return if @no_action
    if book_it_out
      @priceCalculator().getPriceForBookItOut()
    else if exclusive_price
      @exclusivePrice
    else if @isSubscriptionBooking()
      @priceCalculator().getPrice()
    else if @canBePurchased()
      @fixedPrice * @getQuantity()
    else
      @priceCalculator().getPrice()

  bookItOutSubtotal: ->
    @priceCalculator().getPriceForBookItOut()

  priceCalculator: ->
    if @isReservedHourly()
      new HourlyPriceCalculator(this)
    else if @isPerUnitBooking()
      new PerUnitPriceCalculator(this)
    else if @isFixedBooking()
      new FixedPriceCalculator(this)
    else if @isSubscriptionBooking()
      new SubscriptionPriceCalculator(this)
    else
      new PriceCalculator(this)

  # Set the dates active on this listing for booking
  setDates: (dates) ->
    @bookedDatesArray = dates

  # Set the start/end minutes for an hourly listing reservation.
  setTimes: (start, end) ->
    @startMinute = start
    @endMinute = end

  setStartOn: (start) ->
    @startOn = start

  setEndOn: (end) ->
    @endOn = end

  minutesBooked: ->
    return 0 unless @startMinute? and @endMinute?
    @endMinute - @startMinute

  # Check the selected dates are valid with the quantity
  # and availability
  bookingValid: ->
    for date in @bookedDates()
      if @availabilityFor(date) < @getQuantity()
        return false
    true

  reservationOptions: ->
    options = {
      quantity: @initial_bookings.quantity || @getQuantity()
      book_it_out: @initial_bookings.book_it_out,
      exclusive_price: @initial_bookings.exclusive_price
      guest_notes: @initial_bookings.guest_notes
      dates: @initial_bookings.dates || @bookedDays()
    }
    if @withCalendars()
      # Hourly reserved listings send through the start/end minute of
      # the day with the booking request.
      if @isReservedHourly()
        options.start_minute = @initial_bookings.start_minute || @startMinute
        options.end_minute   = @initial_bookings.end_minute || @endMinute
      if @isSubscriptionBooking()
        options.start_on = @initial_bookings.start_on || @startOn
        options.end_on   = @initial_bookings.end_on || @endOn

    options
