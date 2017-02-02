require('../../vendor/jquery.limiter')

module.exports = class Limiter
  constructor: (el) ->
    @el = $(el)
    @intialize()

  intialize: ->
    @el.each ->
      el = $(@)
      limit = parseInt(el.data('counter-limit'))
      target = $('[data-counter-for="' + el.attr('id') + '"]')
      el.limiter(limit, target)
