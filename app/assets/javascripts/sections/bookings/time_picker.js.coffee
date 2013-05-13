class @Bookings.TimePicker
  asEvented.call @prototype

  constructor: (@container) ->
    @view = new View(
      positionTarget: @container
    )
    @view.appendTo($('body'))
    @startTime = @view.startTime
    @endTime = @view.endTime

    @container.on 'click', (event) =>
      @view.toggle()

    @bindEvents()

  bindEvents: ->
    $('body').on 'click', (event) =>
      if @container[0] != event.target && @container.has(event.target).length == 0
        @view.hide()

    @startTime.on 'change', =>
      @container.find('.time-text').text(@formatMinute(@startTime.val()))
      @trigger 'change'

    @endTime.on 'change', =>
      @trigger 'change'

  startMinute: ->
    parseInt @startTime.val(), 10

  endMinute: ->
    parseInt @endTime.val(), 10

  # Set the selectable time range
  setSelectableTimeRange: (start, end) ->
    return if end < start
    options = []
    curr = start
    while curr <= end
      options.push "<option value='#{curr}'>#{@formatMinute(curr)}</option>"
      curr += 15
    options = options.join("\n")
    @startTime.html(options)
    @endTime.html(options)

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
      </div>

    """

    constructor: (options) ->
      options = $.extend({
        containerClass: 'dnm-datepicker',
        positionPadding: 10,
        windowRightPadding: 20
      }, options)
      super(options)
      @container.html(@viewTemplate)
      @startTime = @container.find('.time-start select')
      @endTime = @container.find('.time-end select')


