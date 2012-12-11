# Listing view for advanced booking. Handles the view elements.
class @Bookings.Advanced.ListingView
  asEvented.call(ListingView)

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

    # Setup dom event listeners for change
    @bindEvents()
    @bindModel()

  # Listen for changes on the model to update the view
  bindModel: ->
    # Whenever a date is added to the listing we need to update the booking slots
    # on the view.
    @listing.bind 'dateAdded', (date) =>
      dateEl = @_prepareBookedDayElement(date)

      after = null
      @daysContainer.find('.booked-day').each (i, el) =>
        after = el if $(el).data('date').getTime() < date.getTime()

      if after then $(after).after(dateEl)
      else @daysContainer.prepend(dateEl)

    # Whenever a date is removed from the calendar, we need to remove it from the list too
    @listing.bind 'dateRemoved', (date) =>
      @daysContainer.find(".#{DNM.util.Date.toClassName(date)}").remove()

    # Whenever the value of a booking is changed, ensure we update the view/form in the listing
    @listing.bind 'bookingChanged', (date, amount) =>
      dayBooking = @daysContainer.find(".#{DNM.util.Date.toClassName(date)}")
      dayBooking.find('.count').text(amount)
      dayBooking.toggleClass('empty', amount == 0)
      dayBooking.toggleClass('selected', amount > 0)
      dayBooking.removeClass('unavailable')

  # Listen for UI events and trigger relevant changes.
  bindEvents: ->
    @daysContainer.on 'click', '.booked-day', (event) =>
      el = $(event.target).closest('.booked-day')
      date = el.data('date')
      return unless @listing.hasAvailabilityOn(date)

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

    # Update a booking from the popover
    updateFromBookedDay = (event) =>
      el = $(event.target).closest('.booked-day-popover')
      listingId = el.attr('data-listing-id')
      return unless parseInt(listingId) is @listing.id

      dateId = el.attr('data-date-id')
      @listing.setBooking(dateId, el.find('input').val())

    $('body').on 'change', '.booked-day-popover input', (event) =>
      updateFromBookedDay(event)
    $('body').on 'keyup', '.booked-day-popover input', (event) =>
      updateFromBookedDay(event)

  # Prepare for insertion the dom object representing the ability to choose
  # bookings for the specified date for this Listing
  _prepareBookedDayElement: (date) ->
    el = $ Mustache.render(@bookedDayTemplate, {
      count: @listing.bookedFor(date),
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
      available: @listing.availabilityFor(date),
      total: @listing.totalFor(date),
      quantity: @listing.bookedFor(date),
      listingId: @listing.id,
      dateId: DNM.util.Date.toId(date)
    })

