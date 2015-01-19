class @Limiter

  @initialize: (scope = $('body')) ->
    @bindEvents()

  @bindEvents: ->
    console.log 'hello'
    $('[data-counter-limit]').each (index, value) ->
      el = $(value)
      limit = parseInt(el.data('counter-limit'))
      target = $('[data-counter-for="' + el.attr('id') + '"]')
      el.limiter(limit, target)
