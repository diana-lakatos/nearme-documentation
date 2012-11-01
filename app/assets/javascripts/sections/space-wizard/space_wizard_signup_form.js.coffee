class @SpaceWizardSignupForm

  constructor: (@container) ->
    @bindEvents()

  bindEvents: ->
    @container.on 'click', '.signup-provider .close-button', (event) =>
      event.preventDefault()
      @container.find('.signup-provider').hide()
      @container.find('.signup-no-provider').fadeIn()
      false
