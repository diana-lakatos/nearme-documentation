class @SpaceWizardSpaceForm

  constructor: (@container) ->

    $('.custom-select').chosen()
    @container.find('.control-group').addClass('input-disabled').find(':input').attr("disabled", true)
    $(".custom-select").trigger("liszt:updated")
    @ignoreFirstErrorAfterIndustry = true

    @input_number = 0
    @input_length = @container.find('.control-group').length

    @bindEvents()
    @unlockInput()

  unlockInput: (with_focus = true) ->
    if @input_number < @input_length
      input = @container.find('.control-group').eq(@input_number).removeClass('input-disabled').find(':input').removeAttr("disabled").eq(0)
      if with_focus
       input.focus()
      # hack to ignore currency chosen - just unlock the next field after chosen
      if @container.find('.control-group').eq(@input_number).find('.custom-select').length > 0
        @container.find('.control-group').eq(@input_number).find('.custom-select').trigger("liszt:updated")
        # hack to focus industries chosen - show lists of available industries
        if @container.find('.control-group').eq(@input_number).find('#company_industry_ids').length > 0
          @container.find('.control-group').eq(@input_number).find('#company_industry_ids_chzn input').focus()
          @input_number = @input_number + 1 # this and the next one
          @unlockInput(false)
        else
          @input_number = @input_number + 1
          @unlockInput()

  bindEvents: =>

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
      if @ignoreFirstErrorAfterIndustry && @input_number==2
        @ignoreFirstErrorAfterIndustry = false
        $(element).disableClientSideValidations()
        $(element).enableClientSideValidations()
      else
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
