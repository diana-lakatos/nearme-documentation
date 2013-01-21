class @Bookings.Datepicker
  asEvented.call(Datepicker.prototype)

  constructor: (@container, @listing) ->
    @datepicker = new window.Datepicker(
      trigger: @container,
      view: new DatepickerAvailabilityView(@listing, trigger: @container),

      # Whenever the date selection changes, we need to fire an event. The relevant controller will be
      # listening to update the selected dates on local listing booking object.
      onDatesChanged: (dates) =>
        @trigger 'datesChanged', dates
    )

  setDates: (dates) -> @datepicker.setDates(dates)
  addDate: (date) -> @datepicker.addDate(date)
  removeDate: (date) -> @datepicker.removeDate(date)
  getDates: -> @datepicker.getDates()

  # A view wrapper for the Datepicker to show a loading indicator while we load the date availability
  class DatepickerAvailabilityView extends window.Datepicker.View
    constructor: (@listing, options = {}) ->
      super(options)

    show: ->
      # Refresh if listing quantity has changed since last display
      # We do this to update the display of available vs unavailable dates
      if @lastDefaultQuantity && @listing.defaultQuantity != @lastDefaultQuantity
        @refresh()

      @lastDefaultQuantity = @listing.defaultQuantity
      super

    # Extend the rendering method to trigger a "loading" indicator/overlay.
    # We need to load the date availability for the listing for all of the dates
    # that display, so that we can render whether or not there is availability on
    # the calendar.
    renderMonth: (month) ->
      dates = @datesForMonth(month)
      unless @listing.availabilityLoadedFor(dates)
        @setLoading(true)
        @listing.withAvailabilityLoaded dates, =>
          # Will need to re-render for availability information
          @renderMonth(month)
      else
        @setLoading(false)

      super(month)

    # Extend the class generation method to add disabled state if the listing quantity selection
    # exceeds the availability for a given date.
    classForDate: (date, monthDate) ->
      klass = [super]
      qty = @listing.defaultQuantity
      qty = 1 if qty < 1

      klass.push 'disabled' unless @listing.availabilityFor(date) >= qty
      klass.join ' '


