class @Bookings.TimePicker
  asEvented.call @prototype

  constructor: (@container) ->
    @startTime = @container.find('select[name*=start_minute]')
    @endTime = @container.find('select[name*=end_minute]')
    @bindEvents()

  bindEvents: ->
    @startTime.on 'change', =>
      @trigger 'change'

    @endTime.on 'change', =>
      @trigger 'change'

  startMinute: ->
    parseInt @startTime.val(), 10

  endMinute: ->
    parseInt @endTime.val(), 10

