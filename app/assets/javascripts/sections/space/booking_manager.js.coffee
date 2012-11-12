class @Space.BookingManager
  constructor: (@container) ->
    @listings = $.map @container.find('.listings .listing'), (el) =>
      new Listing(this, $(el))

    @_setupCalendar()
    @_bindEvents()

  _setupCalendar: ->
    @calendar = new Space.BookingCalendar(@container.find('.calendar'))

    # Bind to date selection events
    @calendar.onSelect (date) =>
      listing.addDate(date) for listing in @listings

    @calendar.onUnselect (date) =>
      listing.removeDate(date) for listing in @listings

  _bindEvents: ->
    $('body').on 'change', '.booked-day-popover input', =>
      el = $(event.target).closest('.booked-day-popover')
      listingId = el.attr('data-listing-id')
      dateId = el.attr('data-date-id')

      #alert "Changed for #{listingId} - #{dateId} to #{el.find('input').val()}"
      @findListing(listingId).setBooking(dateId, el.find('input').val())

  findListing: (listingId) ->
    return listing for listing in @listings when listing.id is listingId

  # Each Listing has it's own object which keeps track of number booked, availability etc.
  class Listing

    bookedDayTemplate: '''
      <span class="booked-day empty">
        <span class="count">{{count}}</span>
        <span class="date">{{date}}<sup>{{suffix}}</sup></span>
        <span class="month">{{month}}</span>
      </span>
    '''

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

    constructor: (@manager, @container) ->
      @daysContainer = @container.find('.book .booked-days')
      @id = @container.attr('data-listing-id')
      @bookings = {}
      @_bindEvents()

    # Set booking for specified date
    #
    # dateId - Date ID string or Date object
    # amount - Amount to book on this date
    setBooking: (dateId, amount) ->
      amount = parseInt(amount, 10)
      amount = 0 if amount < 0
      date = DNM.util.Date.idToDate(dateId)
      @bookings[DNM.util.Date.toId(date)] = amount
      dayBooking = @daysContainer.find(".#{DNM.util.Date.toClassName(date)}")
      dayBooking.find('.count').text(amount)
      dayBooking.toggleClass('empty', amount == 0)
      dayBooking.toggleClass('selected', amount > 0)
      dayBooking.removeClass('unavailable')


    _bindEvents: ->
      @daysContainer.on 'click', '.booked-day', (event) =>
        el = $(event.target).closest('.booked-day')
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

    _prepareBookedDayElement: (date) ->
      el = $ Mustache.render(@bookedDayTemplate, {
        count: 0,
        date: date.getDate(),
        suffix: DNM.util.Date.suffix(date),
        month: DNM.util.Date.monthName(date, 3)
      })
      el.addClass(DNM.util.Date.toClassName(date))
      el.data('date', date)
      el

    _popoverContent: (date) ->
      Mustache.render(@popoverTemplate, {
        day: DNM.util.Date.dayName(date),
        date: date.getDate(),
        suffix: DNM.util.Date.suffix(date),
        month: DNM.util.Date.monthName(date),
        year: date.getFullYear(),
        available: 8,
        total: 10,
        quantity: 0,
        listingId: @id,
        dateId: DNM.util.Date.toId(date)
      })



