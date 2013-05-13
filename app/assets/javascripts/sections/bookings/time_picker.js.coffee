class @Bookings.TimePicker
  asEvented.call @prototype
  BOOKING_STEP = 15

  constructor: (@listing, @container) ->
    @allMinutes = []
    @disabledStartTimes = []
    @disabledEndTimes = []

    @view = new View(
      positionTarget: @container
    )
    @view.appendTo($('body'))
    @view.closeIfClickedOutside(@container)

    @startTime = @view.startTime
    @endTime = @view.endTime
    @loading = @view.loading

    @bindEvents()

  bindEvents: ->
    @container.on 'click', (event) =>
      @view.toggle()

    @startTime.on 'change', =>
      @disableEndTimesFromStartTime()
      @trigger 'change'

    @endTime.on 'change', =>
      @trigger 'change'

    @bind 'change', =>
      @container.find('.time-text').text(@formatMinute(@startTime.val()))

  # Return the selected start minute
  startMinute: ->
    val = @startTime.val()
    parseInt val, 10 if val

  # Return the selected end minute
  endMinute: ->
    val = @endTime.val()
    parseInt val, 10 if val

  # Set the selectable time range for potential valid opening hours for the listing.
  # Creates a set of <option> elements in the relevent <select> containers.
  setSelectableTimeRange: (start, end) ->
    return if end < start

    # Reset the allowed minute list
    @allMinutes = []

    # Build up a list of minutes and select option html elements
    options = []
    curr = start
    while curr <= end
      @allMinutes.push(curr)
      options.push "<option value='#{curr}'>#{@formatMinute(curr)}</option>"
      curr += BOOKING_STEP

    # Start time is all but the last end time
    @startTime.html(_.difference(options, [_.last(options)]).join("\n"))

    # End time is all but the first start time
    @endTime.html(_.difference(options, [options[0]]).join("\n"))

  # Update the selectable options  based on the hourly
  # availability schedule of the listing for the current date.
  updateOptions: ->
    date = @listing.bookedDates()[0]

    # Load schedule runs instantly if available, or fires an ajax
    # requests to load the hourly schedule for the date then returns.
    @loading.show()
    @listing.availability.loadSchedule date, =>
      # Ignore callback if no longer selected this date
      return unless date == @listing.bookedDates()[0]

      # Build up a new list of disabled start/end times
      @disabledStartTimes = []
      @disabledEndTimes = []

      for min in @allMinutes
        unless @listing.canBookDate(date, min)
          # If the minute is unbookable, can't start on that minute, and
          # therefore can't end STEP minutes after that.
          @disabledStartTimes.push(min)
          @disabledEndTimes.push(min+BOOKING_STEP)

      # Set the disabled start times
      @setDisabledTimesForSelect(@startTime, @disabledStartTimes)

      # Automatically pick the first available start-time
      if !@startMinute()
        if min = _.difference(@allMinutes, @disabledStartTimes)[0]
          @startTime.val(min)

      # Disable the relevant end-times based on the available end times
      # and also the current start time selected.
      @disableEndTimesFromStartTime()

      # Hide the loading state
      @loading.hide()

      # We trigger change, because the selected times could have potentially
      # changed.
      @trigger 'change'

  setDisabledTimesForSelect: (select, minutes) ->
    select.find("option").prop('disabled', false)

    for minute in minutes
      select.find("option[value=#{minute}]").prop('disabled', true)

  disableEndTimesFromStartTime: ->
    if start = @startMinute()
      before = (min for min in @allMinutes when min <= start)
      firstAfter = _.detect @disabledEndTimes, (min) -> min > start+BOOKING_STEP
      after = (min for min in @allMinutes when min >= firstAfter)
      disable = _.union(@disabledEndTimes, before, after)
    else
      disable = @allMinutes

    @setDisabledTimesForSelect(@endTime, disable)
    if !@endMinute()
      usable = @endTime.find("option:not(:disabled)")[0]
      @endTime.val(usable.value) if usable

  # Return a minute of the day formatted in h:mmpm
  formatMinute: (minute) ->
    h = parseInt(minute / 60, 10) % 12
    h = 12 if h == 0
    m = minute % 60
    ampm = if ((minute / 60) >= 12) then 'pm' else 'am'
    "#{h}:#{if m < 10 then '0' else ''}#{m}#{ampm}"

  class View extends PositionedView
    viewTemplate: """
      <div class="datepicker-header">
        Time
      </div>

      <div class="datepicker-text">
        <div class="datepicker-text-fadein">Select booking duration</div>
      </div>

      <div class="time-wrapper">
        <div class="time-start">
          <span></span>
          <select/>
        </div>
        <span class="ico-arrow-right">
        </span>
        <div class="time-end">
          <span></span>
          <select/>
        </div>

        <div class="datepicker-loading" style="display: none"></div>
      </div>
    """

    defaultOptions:
      containerClass: 'dnm-datepicker'

    constructor: (@options) ->
      @options = $.extend({}, @defaultOptions, @options)
      super(@options)

      @container.html(@viewTemplate)
      @startTime = @container.find('.time-start select')
      @endTime = @container.find('.time-end select')
      @loading = @container.find('.datepicker-loading')

