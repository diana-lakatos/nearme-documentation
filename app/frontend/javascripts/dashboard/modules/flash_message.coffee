module.exports = class FlashMessage
  constructor: ->
    @bindEvents()

  bindEvents: ->
    $('body').on 'click', '[data-flash-message] [data-close]', (e) ->
      e.preventDefault()
      $(e.target).closest('[data-flash-message]').remove()
