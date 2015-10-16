# Each Listing has it's own object which keeps track of number booked, availability etc.
class @Bookings.Listing

  defaultQuantity: 1

  constructor: (@data) ->
    @id = parseInt(@data.id, 10)
    @bookedDatesArray = []
    @bookedDateAvailability = 0
    @maxQuantity = @data.quantity
    @initial_bookings = @data.initial_bookings || {}

    if @data.subscription_prices
      @subscriptionPeriod = Object.keys(@data.subscription_prices)[0]
    else
      @subscriptionPeriod = {}

    if @withCalendars()
      @firstAvailableDate = DNM.util.Date.idToDate(@data.first_available_date)
      @secondAvailableDate = DNM.util.Date.idToDate(@data.second_available_date)
      if @isReservedHourly()
        @availability = new HourlyAvailability(
          @data.availability,
          @data.hourly_availability_schedule,
          @data.hourly_availability_schedule_url
        )
      else
        @availability = new Availability(@data.availability)

      @minimumBookingDays = @data.minimum_booking_days
      @minimumDate = DNM.util.Date.idToDate(@data.minimum_date)
      @maximumDate = DNM.util.Date.idToDate(@data.maximum_date)
      @favourablePricingRate = @data.favourable_pricing_rate
      @pricesByDays = @data.prices_by_days
      @hourlyPrice = @data.hourly_price_cents
      @minimumBookingMinutes = @data.minimum_booking_minutes
    else
      @fixedPrice = @data.fixed_price_cents
      @exclusivePrice = @data.exclusive_price_cents

  setDefaultQuantity: (qty) ->
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

  isReservedHourly: ->
    @data.action_hourly_booking

  isRecurringBooking: ->
    @data.booking_type == 'subscription'

  isOvernightBooking: ->
    @data.booking_type == 'overnight'

  isFixedBooking: ->
    @data.booking_type == 'schedule'

  withCalendars: ->
    !@isFixedBooking()

  isReservedDaily: ->
    @data.action_daily_booking

  isPerUnitBooking: ->
    @data.action_price_per_unit

  # Returns whether the date is within the bounds available for booking
  dateWithinBounds: (date) ->
    time = date.getTime()
    return false if time < @minimumDate.getTime()
    return false if time > @maximumDate.getTime()
    true

  canBookDate: (date, min) ->
    @availabilityFor(date, min) >= @defaultQuantity

  availabilityFor: (date, minute = null) ->
    @availability.availableFor(date, minute)

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
      hasDate = @bookedDates().length > 0
      hasTime = if @isReservedHourly() && @withCalendars()
        @minutesBooked() > 0
      else
        true
      hasDate and hasTime


  # Return the days where there exist bookings
  bookedDays: ->
    (DNM.util.Date.toId(date) for date in @bookedDates())

  # Return the days where bookings exist as Date objects
  bookedDates: ->
    @bookedDatesArray

  # Return the subtotal for booking this listing
  bookingSubtotal: (book_it_out = false, exclusive_price = false) ->
    if book_it_out
      @priceCalculator().getPriceForBookItOut()
    else if exclusive_price
      @exclusivePrice
    else if @isRecurringBooking()
      @subscriptionPeriodPrice() * @getQuantity()
    else
      @priceCalculator().getPrice()

  subscriptionPeriodPrice: ->
    @data.subscription_prices[@subscriptionPeriod]

  setSubscriptionPeriod: (period) ->
    @subscriptionPeriod = period

  bookItOutSubtotal: ->
    @priceCalculator().getPriceForBookItOut()

  priceCalculator: ->
    if @isReservedHourly()
      new Bookings.PriceCalculator.HourlyPriceCalculator(this)
    else if @isPerUnitBooking()
      new Bookings.PriceCalculator.PerUnitPriceCalculator(this)
    else if @isFixedBooking()
      new Bookings.PriceCalculator.FixedPriceCalculator(this)
    else
      new Bookings.PriceCalculator(this)

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
      if @isRecurringBooking()
        options.start_on = @initial_bookings.start_on || @startOn
        options.end_on   = @initial_bookings.end_on || @endOn

    options

  # Wrap queries on the availability data
  class Availability
    constructor: (@data) ->

    openFor: (date) ->
      @_value(date) != null

    availableFor: (date) ->
      @_value(date) or 0

    _value: (date) ->
      if month = @data["#{date.getFullYear()}-#{date.getMonth()+1}"]
        month[date.getDate()-1]
      else
        null

  # Extends the simple daily availability wrapper to provide quantity
  # down to the hourly level for specific days. Provides the same semantics
  # if called without a provided minute, or provides hourly semantics if called
  # with a minute as an additional parameter.
  # Encapsulates deferred loading of the hourly availability.
  class HourlyAvailability extends Availability
    constructor: (@data, @schedule, @scheduleUrl) ->
      super(@data)

    openFor: (date, minute) ->
      @_value(date, minute) != null

    availableFor: (date, minute) ->
      @_value(date, minute) or 0

    hasSchedule: (date) ->
      !!@_schedule(date)

    # Fire off a remote request (if required) to load the hourly availability
    # schedule for a given date. Execute the provided callback when ready
    # to use.
    loadSchedule: (date, callback) ->
      if !@hasSchedule(date)
        dateId = DNM.util.Date.toId(date)
        $.get(@scheduleUrl + "?date=#{dateId}").success (data) =>
          @schedule[dateId] = data
          callback(date)
      else
        callback(date)

    _schedule: (date) ->
      @schedule[DNM.util.Date.toId(date)]

    _value: (date, minute) ->
      if minute
        if hours = @_schedule(date)
          hours[minute.toString()] or null
        else
          super(date)
      else
        super(date)

