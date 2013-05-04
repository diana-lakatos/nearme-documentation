class @SigninForm extends @Form

  constructor: (@container) ->
    @form = @container.find('#new_user')
    super @container, @form

  bindEvents: ->
    super
