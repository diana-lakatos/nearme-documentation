class @DNM.Limiter
  constructor: (el)->
    @input = $(el)
    @limit = @input.data('counter-limit')
    @info = @input.next('[data-counter-for]')
    @labels = {
      few: @info.data('label-few')
      one: @info.data('label-one')
      zero: @info.data('label-zero')
    }

    @bindEvents()

    # initialize
    @updateLimiter()

  bindEvents: ->
    @input.on 'keyup focus', @updateLimiter

  updateLimiter: =>
    text = @input.val()
    chars = text.replace(/\n/g, "aa").length

    if chars > @limit
      @input.val text.substr(0, limit)
      chars = limit

    leftChars = @limit - chars

    switch leftChars
      when 0 then message = @labels.zero
      when 1 then message = @labels.one
      else message = @labels.few.replace('%{count}', leftChars)

    @info.html(message)

$('[data-counter-limit]').each (index, item)=>
  new DNM.Limiter(item)
