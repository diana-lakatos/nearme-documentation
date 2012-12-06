# Each Listing has it's own object which keeps track of number booked, availability etc.
class @Space.Booking.Listing
  constructor: (@manager, @options) ->
    @id = @options.id
    @bookings = {}
    @availability = {}
    @_bindEvents()

  addAvailability: (availabilityHash) ->
    _.extend(@availability, availabilityHash)

  availabilityLoadedFor: (date) ->
    dateId = DNM.util.Date.toId(date)
    _.has(@availability, dateId)

  availabilityFor: (date) ->
    dateId = DNM.util.Date.toId(date)
    @availability[dateId].available

  hasAvailabilityOn: (date) ->
    @availabilityFor(date) > 0

  isBooked: ->
    @bookedDays().length > 0

  # Return the days where there exist bookings
  bookedDays: ->
    _.chain(@bookings).keys().reject((k) => @bookings[k] <= 0).value()

  # Total 'desk days' booked. i.e. number of desks summed across each day
  bookedDeskDays: ->
    _.reduce(_.values(@bookings), ((memo, bookings) -> memo + bookings), 0)

  # Return the bookings data in an array of date & quantity objects
  getBookings: ->
    _.map @bookedDays(), (dateId) =>
      { date: dateId, quantity: @bookings[dateId] }

  # Set booking for specified date
  #
  # dateId - Date ID string or Date object
  # amount - Amount to book on this date
  setBooking: (dateId, amount) ->
    amount = parseInt(amount, 10)
    amount = 0 unless amount > 0
    date = DNM.util.Date.idToDate(dateId)
    @bookings[DNM.util.Date.toId(date)] = amount

    # TODO: notify observers of updated booking (views)

    # Notify manager bookings updated
    # FIXME: Remove this and bind as observer
    @manager.bookingsChanged(this)

  # Return the subtotal for booking this listing
  bookingSubtotal: ->
    # Pricing is based on minute periods.
    # 1 day = 1440 minutes
    # 1 week = 10080 (7 days)
    # 1 month = 43200 minutes (30 days)
    periodPerDay = 24*60
    totalPeriodBooked = periodPerDay * @bookedDeskDays()

    # Sort the prices by period, largest first
    prices = _(@options.prices).sortBy((price) -> price.period).reverse()

    periodRemaining = totalPeriodBooked
    subtotalCents = 0
    for price in prices
      includes = Math.floor(periodRemaining / price.period)
      subtotalCents += includes * price.price_cents
      periodRemaining -= includes*price.period

    # Return the subtotal
    subtotalCents

  addDate: (date) ->
    @setBooking(date, 0)

    # TODO: Notify observers date added (i.e. views)
    if @hasAvailabilityOn(date)
      @setBooking(date, 1)

  removeDate: (date) ->
    @setBooking(date, 0) if _.include @bookedDays(), DNM.util.Date.toId(date)

    # TODO: Notify observers date removed

  # Set the dates active on this listing for booking
  setDates: (dates) ->
    dateIds = _.map dates, (date) -> DNM.util.Date.toId(date)

    # Remove dates that aren't included
    for dateId in @bookedDays()
      if !_.include(dateIds, dateId)
        @setBooking(dateId, 0)

    # Add new dates
    for dateId in dateIds
      if !_.include(@bookedDays(), dateId)
        @setBooking(dateId, 1)


