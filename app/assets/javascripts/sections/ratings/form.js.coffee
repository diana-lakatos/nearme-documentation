class @RatingForm

  constructor: () ->
    @bindEvents()

  bindEvents: ->
    $('.arrows span').click (event) =>
      event.preventDefault()
      $clicked_arrow = $(event.target)
      $hidden_field = $clicked_arrow.parent().find('input[type=hidden]')

      $hidden_field.val($clicked_arrow.data('value'))
      $hidden_field.closest('form').submit()
