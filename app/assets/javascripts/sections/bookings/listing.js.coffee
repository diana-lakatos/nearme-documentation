# Each Listing has it's own object which keeps track of number booked, availability etc.
class @Bookings.Listing
  defaultQuantity: 1

  constructor: (@options, @availabilityManager) ->
    @id = parseInt(@options.id, 10)
    @bookings = {}

  setDefaultQuantity: (qty, updateBookings = false) ->
    @defaultQuantity = qty if qty >= 0

    if updateBookings
      @setBooking(day, @defaultQuantity) for day in @bookedDays()

  availabilityLoadedFor: (date) ->
    @availabilityManager.isLoaded(@id, date)

  totalFor: (date) ->
    @availabilityManager.totalFor(@id, date)

  availabilityFor: (date) ->
    @availabilityManager.availableFor(@id, date)

  hasAvailabilityOn: (date) ->
    @availabilityFor(date) > 0

  bookedFor: (date) ->
    @bookings[DNM.util.Date.toId(date)] || 0

  isBooked: ->
    @bookedDays().length > 0

  # Return the days where there exist bookings
  bookedDays: ->
    _.chain(@bookings).keys().reject((k) => @bookings[k] <= 0).value()

  # Return the days where bookings exist as Date objects
  bookedDates: ->
    $.map @bookedDays(), (dateId) -> DNM.util.Date.idToDate(dateId)

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

    DNM.Event.notify(this, 'bookingChanged', [date, amount])

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
    @withAvailabilityLoaded date, =>
      qty = if @hasAvailabilityOn(date) then @defaultQuantity else 0
      @setBooking(date, qty)
      DNM.Event.notify(this, 'dateAdded', [date, qty])

  removeDate: (date) ->
    if _.include @bookedDays(), DNM.util.Date.toId(date)
      @setBooking(date, 0)
      DNM.Event.notify(this, 'dateRemoved', [date])

  # Set the dates active on this listing for booking
  setDates: (dates) ->
    dateIds = _.map dates, (date) -> DNM.util.Date.toId(date)

    # Remove dates that aren't included
    for dateId in @bookedDays() when !_.include(dateIds, dateId)
      @removeDate(DNM.util.Date.idToDate(dateId))

    # Add new dates
    for dateId in dateIds when !_.include(@bookedDays(), dateId)
      @addDate(DNM.util.Date.idToDate(dateId))

  # Execute a callback if or once availability has been loaded for a date
  #
  # date     - The date to enforce availability loading of
  # callback - A function to call when availability is loaded
  withAvailabilityLoaded: (date, callback) ->
    @availabilityManager.get @id, date, -> callback()

  getAvailabilityManager: ->
    new Bookings.AvailabilityManager.Listing(@availabilityManager, @id)


