asEvented = require('asevented')
require('../../../vendor/gf3-strftime')
PositionedView = require('../../components/lib/positioned_view')

module.exports = class TimePicker
  asEvented.call @prototype
  BOOKING_STEP = 15
  DEFAULT_STEPS = 4

  constructor: (@listing, @container, options = {}) ->
    @allMinutes = []
    @disabledStartTimes = []
    @disabledEndTimes = []
    @openMinute = if options.openMinute? then options.openMinute else 9*60
    @closeMinute = options.closeMinute or 18*60
    @minimumBookingMinutes = options.minimumBookingMinutes
    @initialStartMinute = options.startMinute if options.startMinute?
    @initialStartMinute ||= @openMinute
    @initialEndMinute = options.endMinute if options.endMinute?
    @initialEndMinute ||= @openMinute + @minimumBookingMinutes

    @view = new View(positionTarget: @container, @listing)
    @view.appendTo($('body'))
    @view.closeIfClickedOutside(@container)

    @startTime = @view.startTime
    @endTime = @view.endTime
    @loading = @view.loading
    @changeDisplayedHour()


    # Populate the time selects based on the open hours
    @populateTimeOptions()
    @bindEvents()
    if @initialStartMinute
      @startTime.val("#{@initialStartMinute}")
      @startTime.trigger('change')
    if @initialEndMinute
      @endTime.val("#{@initialEndMinute}")
      @endTime.trigger('change')
    @disableEndTimesFromStartTime()

  bindEvents: ->
    @container.on 'click', (event) =>
      @view.toggle()
      @loading.hide()

    @startTime.on 'change', =>
      @disableEndTimesFromStartTime()
      @trigger 'change'

    @endTime.on 'change', =>
      @trigger 'change'

    @bind 'change', =>
      @changeDisplayedHour()

  show: ->
    @view.show()

  hide: ->
    @view.hide()

  changeDisplayedHour: ->
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
  populateTimeOptions: ->
    return if @closeMinute <= @openMinute

    # Reset the allowed minute list
    @allMinutes = []

    # Build up a list of minutes and select option html elements
    options = []
    curr = @openMinute
    while curr <= @closeMinute
      @allMinutes.push(curr)

      options.push "<option value='#{curr}'>#{@formatMinute(curr)}</option>"
      curr += BOOKING_STEP

    # Start time is all but the last end time
    @startTime.html(_.difference(options, [_.last(options)]).join("\n"))

    # End time is all but the first start time
    steps = _.difference(options, [options[0]])
    # Add the selected attribute to the nth element in the array
    steps[DEFAULT_STEPS-1] = $('<div>').append($(steps[DEFAULT_STEPS-1]).attr('selected', 'selected')).html()
    @endTime.html(steps.join("\n"))

    @view.startTimeDidChange()
    @view.endTimeDidChange()

  # Update the selectable options  based on the hourly
  # availability schedule of the listing for the current date.
  updateSelectableTimes: ->
    date = @listing.bookedDates()[0]

    # Load schedule runs instantly if available, or fires an ajax
    # requests to load the hourly schedule for the date then returns.
    @loading.show()
    @listing.availability.loadSchedule date, =>
      # Ignore callback if no longer selected this date
      return unless date.getTime() == @listing.bookedDates()[0].getTime()

      # Build up a new list of disabled start/end times
      @disabledStartTimes = []
      @disabledEndTimes = []

      for min in @allMinutes
        unless @listing.canBookDate(date, min)
          # If the minute is unbookable, can't start on that minute, and
          # therefore can't end STEP minutes after that.
          @disabledStartTimes.push(min)
          @disabledEndTimes.push(min+BOOKING_STEP)
          @disabledEndTimes.push(min)

      @minutesWhichCantBeBooked = @closeMinute - @minimumBookingMinutes + BOOKING_STEP
      while @minutesWhichCantBeBooked <= @closeMinute
        @disabledStartTimes.push(@minutesWhichCantBeBooked)
        @minutesWhichCantBeBooked += BOOKING_STEP


      # Set the disabled start times
      @setDisabledTimesForSelect(@startTime, @disabledStartTimes)

      # Automatically pick the first available start-time
      if !@startMinute()
        if min = _.difference(@allMinutes, @disabledStartTimes)[0]
          @startTime.val(min).trigger 'change'

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
    start = @startMinute()
    if start?
      # We disable all times before or at the current start time + minimumBookingMinutes
      before = (min for min in @allMinutes when min <= start + @minimumBookingMinutes - BOOKING_STEP)

      # We disable any time after the first unavailable end-time,
      # as a time booking needs to be contiguous.
      firstAfter = _.detect @disabledEndTimes, (min) -> min > start+BOOKING_STEP
      after = (min for min in @allMinutes when min >= firstAfter)

      # Combine the two sets for the times to disable
      disable = _.union(@disabledEndTimes, before, after)
    else
      disable = @allMinutes

    # Disable the minute options in the array for the end time picker
    @setDisabledTimesForSelect(@endTime, disable)

    # If we don't have a valid end time now, assign a default based on the next
    # available end time.
    if !@endMinute()
      usable = @endTime.find("option:not(:disabled)")[0]
      @endTime.val(usable.value).trigger 'change' if usable

  # Return a minute of the day formatted in h:mmpm
  formatMinute: (minute) ->
    hours = parseInt(minute / 60, 10)
    minutes = minute % 60
    date = new Date()
    date.setHours(hours, minutes)

    date.strftime(I18n.timeFormats["short"].replace("-", ""))

  class View extends PositionedView
    viewTemplate: """
      <div class="datepicker-header">
        Time
      </div>


      <div class="datepicker-text">
        <div class="datepicker-text-fadein">Select booking duration</div>
      </div>
      <div class="datepicker-text">
        <div class="datepicker-text-fadein timezone"></div>
      </div>

      <div class="time-wrapper">
        <div class="time-start">
          <span><label></label><i class="ico-chevron-down"></i></span>
          <select />
        </div>
        <span class="ico-arrow-right">
        </span>
        <div class="time-end">
          <span><label></label><i class="ico-chevron-down"></i></span>
          <select />
        </div>

        <div class="datepicker-loading" style="display: none"></div>
      </div>
    """

    defaultOptions:
      containerClass: 'dnm-datepicker'

    constructor: (@options, @listing) ->
      @options = $.extend({}, @defaultOptions, @options)
      super(@options)

      @container.html(@viewTemplate)
      @startTime = @container.find('.time-start select')
      @startTimeSpan = @container.find('.time-start span label')
      @endTime = @container.find('.time-end select')
      @endTimeSpan = @container.find('.time-end span label')
      @loading = @container.find('.datepicker-loading')
      @timezone = @container.find('.timezone')

      @bindEvents()

    bindEvents: ->
      @startTime.on 'change', =>
        @startTimeDidChange()

      @endTime.on 'change', =>
        @endTimeDidChange()

      @addTimezoneInfo()

    startTimeDidChange: ->
      @startTimeSpan.text(@startTime.find('option:selected').text())

    endTimeDidChange: ->
      @endTimeSpan.text(@endTime.find('option:selected').text())

    addTimezoneInfo: ->
      if @listing.data.timezone_info?
        @timezone.text(@listing.data.timezone_info)
