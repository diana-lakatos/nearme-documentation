DNM.util =
  Date:
    MONTHS: ['Janurary', 'Feburary', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    DAYS: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

    toClassName: (date) ->
      "d-#{@toId(date)}"

    toId: (date) ->
      f = (i) -> if i < 10 then "0#{i}" else i
      "#{date.getFullYear()}-#{f(date.getMonth()+1)}-#{f(date.getDate())}"

    idToDate: (dateId) ->
      return dateId if dateId instanceof Date
      if matches = dateId.match(/^([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})$/)
        new Date(parseInt(matches[1], 10), parseInt(matches[2], 10)-1, parseInt(matches[3], 10), 0, 0, 0, 0)

    suffix: (date) ->
      switch date.getDate()
        when 1, 21, 31 then 'st'
        when 2, 22 then 'nd'
        when 3, 23 then 'rd'
        else 'th'

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

