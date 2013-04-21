class @SpaceWizardSpaceForm

  constructor: (@container) ->

    @container.find('.control-group').addClass('input-disabled').find(':input').attr("disabled", true)
    @input_number = 0
    @input_length = @container.find('.control-group').length

    @bindEvents()
    @unlockInput()

  unlockInput: ->
    if @input_number < @input_length
      @container.find('.control-group').eq(@input_number).removeClass('input-disabled').find(':input').removeAttr("disabled").eq(0).focus()
      # hack to ignore chosen - just unlock the next field after chosen
      if @container.find('.control-group').eq(@input_number).find('.custom-select').length > 0
        @input_number = @input_number + 1
        @unlockInput()

  bindEvents: =>
    $('#currency-select').trigger('change')

    # Progress to the next form field when a selection is made from select elements
    @container.on 'change', 'select', (event) =>
      $(event.target).closest('.control-group').next().removeClass('input-disabled').find(':input').removeAttr('disabled').focus()

    ClientSideValidations.callbacks.element.pass = (element, callback, eventData) =>
      callback()
      index = element.closest('.control-group').index()
      if @allValid()
        if index > @input_number
          @input_number = index
        else
          @input_number = @input_number + 1
        @unlockInput()

    ClientSideValidations.callbacks.element.fail = (element, message, callback, eventData) =>
      callback()
      element.focus()
      element.parent().effect('shake', { easing: 'linear' })

    ClientSideValidations.callbacks.form.fail = (form, eventData) ->
      form.closest('.error-block').parent().ScrollTo()

    ClientSideValidations.callbacks.form.before = (form, eventData) =>
      if @container.find('.control-group :input:disabled').length > 0
        if @container.find('.control-group').eq(@input_number).find(':input').eq(0).val() != ''
          @container.find('.control-group').eq(@input_number+1).removeClass('input-disabled').find(':input').removeAttr('disabled')

  allValid: ->
    @container.find('.error-block').length == 0
