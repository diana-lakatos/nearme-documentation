class @Bookings.Simple.Datepicker
  asEvented.call(Datepicker.prototype)

  constructor: (@container, @listing) ->
    @datepicker = new window.Datepicker(
      trigger: @container,
      view: new DatepickerAvailabilityView(@listing, trigger: @container),
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
      if @lastDefaultQuantity && @listing.defaultQuantity != @lastDefaultQuantity
        @refresh()

      @lastDefaultQuantity = @listing.defaultQuantity
      super

    renderMonth: (month) ->
      dates = @datesForMonth(month)
      unless @listing.getAvailabilityManager().isLoaded(dates)
        @setLoading(true)
        @listing.getAvailabilityManager().getDates dates, =>
          # Will need to re-render for availability information
          @renderMonth(month)
      else
        @setLoading(false)

      super(month)

    classForDate: (date, monthDate) ->
      klass = [super]
      qty = @listing.defaultQuantity
      qty = 1 if qty < 1

      klass.push 'disabled' unless @listing.getAvailabilityManager().availableFor(date) >= qty
      klass.join ' '


