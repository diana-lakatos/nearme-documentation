class @Bookings.Simple.Datepicker

  constructor: (@container) ->

    availability_manager = {
      monthLoaded: (month) -> true
      loadMonth: (month, callback) -> setTimeout(callback, 1000)
      isAvailable: (date) -> true
    }

    @datepicker = new window.Datepicker(
      trigger: @container,
      view: new DatepickerAvailabilityView(availability_manager),
      onDatesChanged: (dates) =>
        DNM.Event.notify this, 'datesChanged', [dates]
    )

  setDates: (dates) ->
    console.info "set dates on listing bookings datepicker"

  getDates: ->
    @datepicker.getDates()

  # A view wrapper for the Datepicker to show a loading indicator while we load the date availability
  class DatepickerAvailabilityView extends window.Datepicker.View
    constructor: (@availabilityManager) ->
      super()

    renderMonth: (month) ->
      unless @availabilityManager.monthLoaded(month)
        @setLoading(true)
        @availabilityManager.loadMonth month, =>
          # Will need to re-render for availability information
          @renderMonth(month)
      else
        @setLoading(false)

      super(month)

    classForDate: (date) ->
      klass = [super]
      klass.push 'unavailable' unless @availabilityManager.isAvailable(date)
      klass.join ' '


