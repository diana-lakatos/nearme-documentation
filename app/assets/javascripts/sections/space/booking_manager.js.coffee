class @Space.BookingManager

  summaryTemplate: '''
    <strong>{{listings}} listings</strong> selected over a total of <strong>{{days}} days</strong> for <strong>{{currency_symbol}}{{subtotal_dollars}}</strong>
  '''

  constructor: (@container, @options = {}) ->
    @listings = $.map @options.listings, (listing) =>
      new Listing(this, listing)

    @summaryContainer = @container.find('.summary').hide()
    @_setupCalendar()
    @_bindEvents()

  _setupCalendar: ->
    @calendar = new Space.BookingCalendar(@container.find('.calendar'))

    # Bind to date selection events
    @calendar.onSelect (date) =>
      @addDateForBookings(date)

    @calendar.onUnselect (date) =>

  addDateForBookings: (date) ->
    # Do we need availability info for days?
    needsLoading = !_.all @listings, (listing) =>
      listing.availabilityLoadedFor(date)

    # Callback to add date option to the listings
    addDateToListings = =>
      listing.addDate(date) for listing in @listings

    if needsLoading
      $.ajax(@options.availability_summary_url, {
        dataType: 'json',
        data: { dates: [DNM.util.Date.toId(date)] },
        success: (data) =>
          # Go through each response and add date info
          _.each data, (listingData) =>
            @findListing(listingData.id).addAvailability(listingData.availability)

          addDateToListings()
      })
    else
      addDateToListings()

  removeDateForBookings: (date) ->
    listing.removeDate(date) for listing in @listings

  _bindEvents: ->

  findListing: (listingId) ->
    return listing for listing in @listings when listing.id is parseInt(listingId, 10)

  # Update the summary of the bookings so far
  updateSummary: ->
    listings = 0
    days = []
    subtotal = 0
    for listing in @listings when listing.isBooked()
      listings += 1
      days = _.union(days, listing.bookedDays())
      subtotal += listing.bookingSubtotal()

    if listings > 0
      summaryText = Mustache.render(@summaryTemplate, {
        listings: listings,
        days: days.length,
        currency_symbol: @options.currencySymbol || '$',
        subtotal_dollars: (subtotal / 100).toFixed(2)
      })
      @summaryContainer.show().find('span').html(summaryText)
    else
      @summaryContainer.hide()

  # Notifiction received when bookings changed for a listing
  bookingsChanged: (listing) ->
    @updateSummary()

  # Each Listing has it's own object which keeps track of number booked, availability etc.
  class Listing

    # Template for booked day selection elements
    bookedDayTemplate: '''
      <span class="booked-day empty">
        <span class="count">{{count}}</span>
        <span class="date">{{date}}<sup>{{suffix}}</sup></span>
        <span class="month">{{month}}</span>
      </span>
    '''

    # Template for booked day selection popover modals
    popoverTemplate: '''
      <div class="booked-day-popover" data-listing-id="{{listingId}}" data-date-id="{{dateId}}">
        <div class="date">{{day}} {{date}}<sup>{{suffix}}</sup></div>
        <div class="month">{{month}} {{year}}</div>
        <div class="availability">
          <span class="available">{{available}}</span><span class="total">/{{total}}</span> available
        </div>
        <hr />
        <label>
          Qty. to book:
        </label>
        <input type="number" name="booked-day-qty" value="{{quantity}}" />
      </div>
    '''

    constructor: (@manager, @options) ->
      @container = @manager.container.find(".listings .listing[data-listing-id=#{@options.id}]")
      @daysContainer = @container.find('.book .booked-days')
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

    # Set booking for specified date
    #
    # dateId - Date ID string or Date object
    # amount - Amount to book on this date
    setBooking: (dateId, amount) ->
      amount = parseInt(amount, 10)
      amount = 0 unless amount > 0
      date = DNM.util.Date.idToDate(dateId)
      @bookings[DNM.util.Date.toId(date)] = amount
      dayBooking = @daysContainer.find(".#{DNM.util.Date.toClassName(date)}")
      dayBooking.find('.count').text(amount)
      dayBooking.toggleClass('empty', amount == 0)
      dayBooking.toggleClass('selected', amount > 0)
      dayBooking.removeClass('unavailable')

      # Notify manager bookings updated
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

    _bindEvents: ->
      @daysContainer.on 'click', '.booked-day', (event) =>
        el = $(event.target).closest('.booked-day')
        date = el.data('date')
        return unless @hasAvailabilityOn(date)

        el.popover(
          trigger: 'none',
          content: @_popoverContent(el.data('date')),
          position: 'bottom',
          verticalOffset: 2
        )
        el.popover('hideAll')
        el.popover('show')

        event.preventDefault()
        event.stopPropagation()

      updateFromBookedDay = (event) =>
        el = $(event.target).closest('.booked-day-popover')
        listingId = el.attr('data-listing-id')
        return unless parseInt(listingId) is @id

        dateId = el.attr('data-date-id')
        @setBooking(dateId, el.find('input').val())

      $('body').on 'change', '.booked-day-popover input', (event) => updateFromBookedDay(event)
      $('body').on 'keyup', '.booked-day-popover input', (event) => updateFromBookedDay(event)

    addDate: (date) ->
      dateEl = @_prepareBookedDayElement(date)

      after = null
      @daysContainer.find('.booked-day').each (i, el) =>
        if $(el).data('date').getTime() < date.getTime()
          after = el

      if after
        $(after).after(dateEl)
      else
        @daysContainer.prepend(dateEl)

    removeDate: (date) ->
      @daysContainer.find(".#{DNM.util.Date.toClassName(date)}").remove()
      @setBooking(date, 0) if _.include @bookedDays(), DNM.util.Date.toId(date)

    # Prepare for insertion the dom object representing the ability to choose
    # bookings for the specified date for this Listing
    _prepareBookedDayElement: (date) ->
      el = $ Mustache.render(@bookedDayTemplate, {
        count: 0,
        date: date.getDate(),
        suffix: DNM.util.Date.suffix(date),
        month: DNM.util.Date.monthName(date, 3)
      })
      el.addClass(DNM.util.Date.toClassName(date))
      el.data('date', date)

      unless @hasAvailabilityOn(date)
        el.addClass('unavailable')
      el

    # Prepare the content for the Popover to modify the bookings for this day
    _popoverContent: (date) ->
      Mustache.render(@popoverTemplate, {
        day: DNM.util.Date.dayName(date),
        date: date.getDate(),
        suffix: DNM.util.Date.suffix(date),
        month: DNM.util.Date.monthName(date),
        year: date.getFullYear(),
        available: @availability[DNM.util.Date.toId(date)].available,
        total: @availability[DNM.util.Date.toId(date)].total,
        quantity: 0,
        listingId: @id,
        dateId: DNM.util.Date.toId(date)
      })



