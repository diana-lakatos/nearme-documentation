class @SpaceBookingCalendar

  constructor: (@container) ->
    @prevElement = @container.find('.prev')
    @nextElement = @container.find('.next')
    @window = @container.find('.slider-window')
    @daysContainer = @container.find('.days')

    @initializeDays()
    @bindEvents()

  bindEvents: ->
    @prevElement.on 'click', => @previous()
    @nextElement.on 'click', => @next()

  initializeDays: ->
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
    "d-#{date.getFullYear()}-#{date.getMonth()}-#{date.getDate()}"

  _dateSuffix: (date) ->
    switch date.getDate()
      when 1, 21, 31 then 'st'
      when 2, 22 then 'nd'
      when 3, 23 then 'rd'
      else 'th'

  _dateMonth: (date) ->
    months = ['Janurary', 'Feburary', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    months[date.getMonth()-1]

  _dateDayOfWeek: (date) ->
    days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    days[date.getDay()].substring(0, 3)


