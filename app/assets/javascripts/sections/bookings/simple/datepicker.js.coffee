class @Bookings.Simple.Datepicker
  asEvented.call(Datepicker.prototype)

  constructor: (@container, @availability_manager) ->

    availability_manager = {
      monthLoaded: (month) -> true
      loadMonth: (month, callback) -> setTimeout(callback, 1000)
      isAvailable: (date) -> true
    }

    @datepicker = new window.Datepicker(
      trigger: @container,
      view: new DatepickerAvailabilityView(@availability_manager, { trigger: @container }),
      onDatesChanged: (dates) =>
        @trigger 'datesChanged', dates
    )

  setDates: (dates) ->
    @datepicker.setDates(dates)

  addDate: (date) -> @datepicker.addDate(date)
  removeDate: (date) -> @datepicker.removeDate(date)

  getDates: ->
    @datepicker.getDates()

  # A view wrapper for the Datepicker to show a loading indicator while we load the date availability
  class DatepickerAvailabilityView extends window.Datepicker.View
    constructor: (@availabilityManager, options = {}) ->
      super(options)

    renderMonth: (month) ->
      dates = @datesForMonth(month)
      unless @availabilityManager.isLoaded(dates)
        @setLoading(true)
        @availabilityManager.getDates dates, =>
          # Will need to re-render for availability information
          @renderMonth(month)
      else
        @setLoading(false)

      super(month)

    classForDate: (date, monthDate) ->
      klass = [super]
      klass.push 'disabled' unless @availabilityManager.availableFor(date) > 0
      klass.join ' '


