module.exports = class OptionType

  constructor: (@form) ->
    @bindEvents()

  bindEvents: ->
    $('form').on 'click', '.add_fields', (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'), 'g')
      $(this).before($(this).data('fields').replace(regexp, time))
      event.preventDefault()

    $('form').on 'click', '.remove_fields', (event) ->
      $(this).prev().attr('checked','checked');
      $(this).closest('.fieldset').hide()
      event.preventDefault()
