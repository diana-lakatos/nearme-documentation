
class @SignupForm

  constructor: (@container) ->
    @form = @container.find('#new_user')
    @focusInput()
    @bindEvents()

  focusInput: =>
    if !$.browser.msie
      if @form.find('.error-block').length > 0
        @form.find('.error-block').eq(0).siblings('input:visible').focus()
      else
        @form.find('input:visible').eq(0).focus()
      

  bindEvents: ->
    @container.on 'click', '.signup-provider .close-button', (event) =>
      @container.find('.signup-provider').hide()
      @container.find('.signup-no-provider').fadeIn()
