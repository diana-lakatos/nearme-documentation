module.exports = class Flash
  constructor: (scope = 'body') ->
    @scope = $(scope)

    @bindEvents()
    @initialize()

  initialize: ->
    @scope.find('div[data-flash-message]').css({"display":'none'}).delay(200).css({'display': 'block'})

  bindEvents: (scope = $('body')) ->
    @scope.on 'click', 'div[data-flash-message]', (event) ->
      if !$(event.target).attr('href') || $(event.target).hasClass('close')
        $(event.target).closest('div[data-flash-message]').remove()
        event.preventDefault()

