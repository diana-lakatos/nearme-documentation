class @Flash
  constructor: (@container) ->

  hide: ->
    @container.fadeOutSlideUp()

  @initialize: (scope = $('body')) ->
    scope.on 'click', '.flash .close', (event) ->
      new Flash($(event.target).closest('.flash')).hide()
      event.preventDefault()

