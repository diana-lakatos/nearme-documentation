class @SpaceBookingCalendar

  # Default callbacks
  _onSelectCallback: (date) ->
    # Do nothing

  _onUnselectCallback: (date) ->
    # Do nothing

  constructor: (@container) ->
    @prevElement = @container.find('.prev')
    @nextElement = @container.find('.next')
    @window = @container.find('.slider-window')
    @daysContainer = @container.find('.days')

    @_initializeDays()
    @_bindEvents()

  onSelect: (callback) ->
    @_onSelectCallback = callback

  onUnselect: (callback) ->
    @_onUnselectCallback = callback

  _bindEvents: ->
    @prevElement.on 'click', => @previous()
    @nextElement.on 'click', => @next()
    @daysContainer.on 'click', 'li', (event) => @_clickDateElement(event)

  _clickDateElement: (event) ->
    li = $(event.target).closest('li')
    li.toggleClass('selected')

    if li.is('.selected')
      @_onSelectCallback(li.data('date')) if @_onSelectCallback
    else
      @_onUnselectCallback(li.data('date')) if @_onUnselectCallback

  _initializeDays: ->
    @today = new Date Date.parse(@container.attr('data-today'))
    @startDate = @today
    @endDate   = @startDate
    @addDays(@startDate, 30)
    @setDayElement(@daysContainer.find(':first-child'))

  setDayElement: (element, animate = false) ->
    @current = element
    @currentDate = element.data('date')

    # Slide window for current element
    left = @current.position().left

    if animate
      @daysContainer.animate({'margin-left': "#{left*-1}px"}, 'slow')
    else
      @daysContainer.css('margin-left', "#{left*-1}px")

  # Go backwards in time
  previous: ->
    @addDays(@startDate, 7, false, false)
    @setDayElement(@current)
    newDate = new Date(@currentDate.getTime())
    newDate.setDate(newDate.getDate() - 7)
    element = @daysContainer.find(".#{@_dateClassName(newDate)}")
    @setDayElement(element, true)

  # Go forwards in time
  next: ->
    @addDays(@endDate, 7, true, false)
    newDate = new Date(@currentDate.getTime())
    newDate.setDate(newDate.getDate() + 7)
    element = @daysContainer.find(".#{@_dateClassName(newDate)}")
    @setDayElement(element, true)


  addDays: (from, count, advance = true, including = true) ->
    added = if including
      0
    else
      1
    count += 1 unless including

    while added < count
      day = new Date(from.getTime())
      if advance
        day.setDate(from.getDate() + added)
      else
        day.setDate(from.getDate() - added)

      @addDay(day)
      added += 1

  addDay: (date) ->
    dayElement = $('<li />')
    dayElement.append("<span class='date'>#{date.getDate()}<sup>#{@_dateSuffix(date)}</sup></span>")
    dayElement.append("<span class='month'>#{@_dateDayOfWeek(date)}</span>")
    dayElement.data('date', date)
    dayElement.addClass(@_dateClassName(date))

    wday = date.getDay()
    if wday == 0 or wday == 6
      dayElement.addClass('weekend')

    if date.getTime() == @today.getTime()
      dayElement.addClass('today')

    if date.getTime() < @startDate.getTime()
      @daysContainer.prepend(dayElement)
    else
      @daysContainer.append(dayElement)

    if date.getTime() < @startDate.getTime()
      @startDate = date
    else if date.getTime() > @endDate.getTime()
      @endDate = date

  _dateClassName: (date) ->
    DNM.util.Date.toClassName(date)

  _dateSuffix: (date) ->
    DNM.util.Date.suffix(date)

  _dateMonth: (date) ->
    DNM.util.Date.monthName(date, 3)

  _dateDayOfWeek: (date) ->
    DNM.util.Date.dayName(date, 3)


