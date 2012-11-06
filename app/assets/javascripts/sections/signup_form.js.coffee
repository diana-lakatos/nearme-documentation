class @SignupForm

  constructor: (@container) ->
    @bindEvents()

  bindEvents: ->
    @container.on 'click', '.signup-provider .close-button', (event) =>
      @container.find('.signup-provider').hide()
      @container.find('.signup-no-provider').fadeIn()
