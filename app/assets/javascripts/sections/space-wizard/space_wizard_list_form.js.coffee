class @SpaceWizardSpaceForm

  constructor: (@container) ->

    #THIS CODE IS COMMENTED BECAUSE CLIENT_SIDE_VALIDATION 3.2.5 GEM IS NOT STABLE AT THE TIME BEING.
    # 3.2.5 version does not validate nested inputs [ listing fields ], version 3.2.1 validates listing fields,
    # but does not validate company name. 
    
    #$('.custom-select').chosen()
    #@container.find('.control-group').addClass('input-disabled').find(':input').attr("disabled", true)
    #$(".custom-select").trigger("liszt:updated")

    #@input_number = 0
    #@input_length = @container.find('.control-group').length

    #@bindEvents()
    #@unlockInput()
    #comment the next line to disable control group disable

  unlockInput: (with_focus = true) ->
    if @input_number < @input_length
      input = @container.find('> .control-group').eq(@input_number).removeClass('input-disabled').find(':input').removeAttr("disabled").eq(0)
      if with_focus
       input.focus()
      # hack to ignore currency chosen - just unlock the next field after chosen
      if @container.find('> .control-group').eq(@input_number).find('.custom-select').length > 0
        @container.find('> .control-group').eq(@input_number).find('.custom-select').trigger("liszt:updated")
        # hack to focus industries chosen - show lists of available industries
        if @container.find('> .control-group').eq(@input_number).find('#company_industry_ids').length > 0
          @container.find('> .control-group').eq(@input_number).find('#company_industry_ids_chzn input').focus()
        else
          @input_number = @input_number + 1
          @unlockInput()

  bindEvents: =>

    $('#company_industry_ids').change (event) =>
      callback = => @validateIndustries event
      # yes I hate it too. Chosen has a bug - it triggers change before removing element from dom...
      setTimeout callback, 100

    # Progress to the next form field when a selection is made from select elements
    @container.on 'change', 'select', (event) =>
      if $(event.target).closest('#company_industry_ids').length == 0
        $(event.target).closest('.control-group').next().removeClass('input-disabled').find(':input').removeAttr('disabled').focus()

    ClientSideValidations.callbacks.element.pass = (element, callback, eventData) =>
      callback()
      @successfulValidationHandler(element)

    ClientSideValidations.callbacks.element.fail = (element, message, callback, eventData) =>
      callback()
      element.focus()
      element.parent().effect('shake', { easing: 'linear' })

    ClientSideValidations.callbacks.form.fail = (form, eventData) ->
      form.closest('.error-block').parent().ScrollTo()

    ClientSideValidations.callbacks.form.before = (form, eventData) =>
      if @container.find('> .control-group :input:disabled').length > 0
        if @container.find('> .control-group').eq(@input_number).find(':input').eq(0).val() != ''
          @container.find('> .control-group').eq(@input_number+1).removeClass('input-disabled').find(':input').removeAttr('disabled')

  successfulValidationHandler: (element) =>
    index = element.closest('.control-group').index()
    if @allValid()
      if index > @input_number
        @input_number = index
      else
        @input_number = @input_number + 1
      @unlockInput()

  validateIndustries: (event) =>
    # there is always one element - search input
    if $(event.target).parent().find('ul .search-choice').length > 0
      $(event.target).closest('.control-group').removeClass('error')
      @successfulValidationHandler($(event.target))
    else
      $(event.target).closest('.control-group').addClass('error')
      $(event.target).closest('.control-group').find('ul').effect('shake', { easing: 'linear' })
      $(event.target).closest('.control-group').find('#company_industry_ids_chzn input').focus()

  allValid: ->
    @container.find('.error-block').length == 0
