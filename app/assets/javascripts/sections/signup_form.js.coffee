class @SignupForm extends @Form

  constructor: (@container) ->
    @form = @container.find('#new_user')
    super @container, @form

  bindEvents: ->
    @container.on 'click', '.signup-provider .close-button', (event) =>
      @container.find('.signup-provider').hide()
      @container.find('.signup-no-provider').fadeIn()
