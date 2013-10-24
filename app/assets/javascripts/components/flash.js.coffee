class @Flash
  constructor: (@container) ->

  hide: =>
    if $.browser.msie
      @container.remove()
    else
      @container.addClass('timeout')

  @initialize: (scope = $('body')) ->
    scope.on 'click', 'div[data-flash-message]', (event) ->
      new Flash($(event.target).closest('div[data-flash-message]')).hide()
      event.preventDefault()

    $('div[data-flash-message]').css({"display":'none'}).delay(200).css({'display': 'block'}).addClass('appear')

