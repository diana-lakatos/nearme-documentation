class @Bookings.TimePicker
  asEvented.call @prototype

  constructor: (@container) ->
    @view = new View(
      positionTarget: @container
    )
    @view.appendTo($('body'))

    @container.on 'click', (event) =>
      @view.toggle()

    @startTime = @container.find('select[name*=start_minute]')
    @endTime = @container.find('select[name*=end_minute]')
    @bindEvents()

  bindEvents: ->
    $('body').on 'click', (event) =>
      if @container[0] != event.target && @container.has(event.target).length == 0
        @view.hide()

    @startTime.on 'change', =>
      @trigger 'change'

    @endTime.on 'change', =>
      @trigger 'change'

  startMinute: ->
    parseInt @startTime.val(), 10

  endMinute: ->
    parseInt @endTime.val(), 10

  class View extends PositionedView
    viewTemplate: """
      <div class="datepicker-header">
        Time
      </div>

      <div class="datepicker-text">
        Select booking duration
      </div>

      <div class="time-wrapper">
        <div class="time-start">
          <span></span>
          <select/>
        </div>
        <span class="ico-arrow">
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
        positionPadding: 20
      }, options)
      super(options)
      @container.html(@viewTemplate)

