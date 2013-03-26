DNM.util =
  Date:
    MONTHS: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    DAYS: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

    toClassName: (date) ->
      "d-#{@toId(date)}"

    toId: (date) ->
      return date if typeof date == "string" or date instanceof String
      f = (i) -> if i < 10 then "0#{i}" else i
      "#{date.getFullYear()}-#{f(date.getMonth()+1)}-#{f(date.getDate())}"

    idToDate: (dateId) ->
      return dateId if dateId instanceof Date
      if matches = dateId.match(/^([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})$/)
        new Date(parseInt(matches[1], 10), parseInt(matches[2], 10)-1, parseInt(matches[3], 10), 0, 0, 0, 0)

    inPast: (date) ->
      now = new Date()
      past = now.getFullYear() > date.getFullYear()
      past ||= now.getFullYear() == now.getFullYear() and now.getMonth() > date.getMonth()
      past ||= now.getFullYear() == now.getFullYear() and now.getMonth() == date.getMonth() and now.getDate() > date.getDate()
      past

    suffix: (date) ->
      switch date.getDate()
        when 1, 21, 31 then 'st'
        when 2, 22 then 'nd'
        when 3, 23 then 'rd'
        else 'th'

    advance: (date, options = {}) ->
      months = options.months || 0
      days = options.days || 0
      years = options.years || 0
      new Date(date.getFullYear()+years, date.getMonth()+months, date.getDate()+days, 0, 0, 0)

    next: (date) ->
      @advance(date, days: 1)

    previous: (date) ->
      @advance(date, days: -1)

    nextMonth: (date) ->
      @advance(date, months: 1)

    previousMonth: (date) ->
      @advance(date, months: -1)

    datesInMonth: (dateMonth) ->
      dates = []
      current = dateMonth
      while current.getMonth() == monthDate.getMonth()
        dates.push(current)
        current = @next(date)
      dates

    monthName: (date, sub = null) ->
      name = @MONTHS[date.getMonth()]
      if sub
        name.substring(0, sub)
      else
        name

    dayName: (date, sub = null) ->
      name = @DAYS[date.getDay()]
      if sub
        name.substring(0, sub)
      else
        name

