# Each Listing has it's own object which keeps track of number booked, availability etc.
class @Bookings.Listing

  defaultQuantity: 1

  constructor: (@data) ->
    @id = parseInt(@data.id, 10)
    @firstAvailableDate = DNM.util.Date.idToDate(@data.first_available_date)
    @availability = new Availability(@data.availability)
    @bookedDatesArray = []

    @minimumBookingDays = @data.minimum_booking_days
    @minimumDate = DNM.util.Date.idToDate(@data.minimum_date)
    @maximumDate = DNM.util.Date.idToDate(@data.maximum_date)
    @pricesByDays = @data.prices_by_days

  setDefaultQuantity: (qty) ->
    @defaultQuantity = qty if qty >= 0

  getQuantity: ->
    @defaultQuantity

  # Returns whether the date is within the bounds available for booking
  dateWithinBounds: (date) ->
    time = date.getTime()
    return false if time < @minimumDate.getTime()
    return false if time > @maximumDate.getTime()
    true

  canBookDate: (date) ->
    @availabilityFor(date) >= @defaultQuantity

  availabilityFor: (date) ->
    @availability.availableFor(date)

  openFor: (date) ->
    @availability.openFor(date)

  isBooked: ->
    @bookedDates().length > 0

  # Return the days where there exist bookings
  bookedDays: ->
    (DNM.util.Date.toId(date) for date in @bookedDates())

  # Return the days where bookings exist as Date objects
  bookedDates: ->
    @bookedDatesArray

  # Return the subtotal for booking this listing
  bookingSubtotal: ->
    new Bookings.PriceCalculator(this).getPrice()

  # Set the dates active on this listing for booking
  setDates: (dates) ->
    @bookedDatesArray = dates

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

