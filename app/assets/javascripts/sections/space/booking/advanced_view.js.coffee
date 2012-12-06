# Contains all the view logic for the 'Advanced View' of the booking system
class @Space.Booking.AdvancedView

  # Template text for the summary area
  summaryTemplate: '''
    <strong>{{listings}} listings</strong> selected over a total of <strong>{{days}} days</strong> for <strong>{{currency_symbol}}{{subtotal_dollars}}</strong>
  '''

  constructor: ->

  # Setup calendar for the advanced booking UI
  _setupCalendar: ->
    return unless @container.find('#calendar').length > 0

    @calendar = new Booking.Advanced.Calendar(@container.find('#calendar'))

    # Bind to date selection events
    @calendar.onSelect (date) => @addDateForBookings(date, @calendar)
    @calendar.onUnselect (date) => @removeDateForBookings(date, @calendar)

  # Listing view for advanced booking
  class Listing
    # Template for booked day selection elements
    bookedDayTemplate: '''
      <span class="booked-day selected">
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

    # Initialize a listing view.
    #
    # listing - The Listing booking model object
    constructor: (@listing, @container) ->
      @daysContainer = @container.find('.book .booked-days')
      @_bindEvents()

    bookingUpdated: (date) ->
      dayBooking = @daysContainer.find(".#{DNM.util.Date.toClassName(date)}")
      dayBooking.find('.count').text(amount)
      dayBooking.toggleClass('empty', amount == 0)
      dayBooking.toggleClass('selected', amount > 0)
      dayBooking.removeClass('unavailable')

    dateAdded: (date) ->
      dateEl = @_prepareBookedDayElement(date)

      after = null
      @daysContainer.find('.booked-day').each (i, el) =>
        if $(el).data('date').getTime() < date.getTime()
          after = el

      if after
        $(after).after(dateEl)
      else
        @daysContainer.prepend(dateEl)

    dateRemoved: (date) ->
      @daysContainer.find(".#{DNM.util.Date.toClassName(date)}").remove()

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

      unless @listing.hasAvailabilityOn(date)
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
        available: @listing.availability[DNM.util.Date.toId(date)].available,
        total: @listing.availability[DNM.util.Date.toId(date)].total,
        quantity: 1,
        listingId: @id,
        dateId: DNM.util.Date.toId(date)
      })

