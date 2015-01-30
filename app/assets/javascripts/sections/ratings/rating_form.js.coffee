class @RatingForm extends @ModalForm

  constructor: (@container) ->
    super @container

  bindEvents: ->
    @container.find('button').click (event) =>
      event.preventDefault()
      $clicked_button = $(event.target).closest('button')
      $hidden_field = @container.find('input[type=hidden]')

      $hidden_field.val($clicked_button.data('value'))
      @container.submit()
