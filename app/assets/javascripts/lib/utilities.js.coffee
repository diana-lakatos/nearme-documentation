DNM.util =
  Date:
    MONTHS: ['Janurary', 'Feburary', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    DAYS: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

    toClassName: (date) ->
      "d-#{date.getFullYear()}-#{date.getMonth()}-#{date.getDate()}"

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




