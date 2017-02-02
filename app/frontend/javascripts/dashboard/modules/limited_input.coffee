module.exports = class Limiter
  constructor: (el) ->
    @input = $(el)
    @limit = @input.data('counter-limit')
    @info = @input.next('[data-counter-for]')
    @info = $('<p class="help-block limiter"/>').insertAfter(@input) if @info.length == 0
    @labels = {
      few: @info.data('label-few') || "%{count} characters left"
      one: @info.data('label-one') || "1 character left"
      zero: @info.data('label-zero') || "0 characters left"
    }

    @bindEvents()

    # initialize
    @updateLimiter()

  bindEvents: ->
    @input.on 'keyup focus', @updateLimiter

  updateLimiter: =>
    text = @input.val()
    # new line character is treated as a 2 characters in textarea, that's why we use 'aa'
    chars = text.replace(/\n/g, "aa").length

    if chars > @limit
      @input.val text.substr(0, @limit)
      chars = @limit

    leftChars = @limit - chars

    switch leftChars
      when 0 then message = @labels.zero
      when 1 then message = @labels.one
      else message = @labels.few.replace('%{count}', leftChars)

    @info.html(message)
