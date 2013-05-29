class @Flash
  constructor: (@container) ->

  hide: (element) ->
    @container.addClass('timeout')

  @initialize: (scope = $('body')) ->
    scope.on 'click', 'div[data-flash-message] .close', (event) ->
      new Flash($(event.target).closest('div[data-flash-message]')).hide()
      event.preventDefault()

    $('div[data-flash-message]').css({"display":'none'}).delay(200).css({'display': 'block'}).addClass('appear')
    setTimeout ( ->
      $('div[data-flash-message]').addClass('timeout')
    ), 7000



