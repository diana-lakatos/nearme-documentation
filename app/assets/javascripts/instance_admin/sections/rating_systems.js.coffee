class @InstanceAdmin.RatingSystemsController
  constructor: (@container) ->
    @bindEvents()
    
  bindEvents: ->
    @toggleSlide('.rating-system', '.table-container')
    @toggleSlide('.service', '.content-container')

    @container.find('.header input[type="checkbox"]').on 'click', ->
      checkedValue = $(@).prop('checked')
      $(@).prop('checked', !checkedValue)
        
    @container.on 'click', '.remove-question.enabled', ->
      parent = $(@).parent()
      questions = $(@).parents('.questions')
      if parent.find('.question-id').val().length
        parent.find('input[type="checkbox"]').prop('checked', true)
        parent.hide()
      else
        parent.remove()
      index = 1
      questions.find('.number:visible').each ()->
        $(@).text("#{index}.")
        index += 1

    @container.on 'keydown', '.question-input', ->
      parent = $(@).parent()
      questions = $(@).parents('.questions')
      questionsCount = $(@).parents('.rating-system').find('.question:visible').length
      if $(@).val().length is 0 and parent.next().length is 0 and questionsCount < 5
        newQuestion = $(@).parent().clone()
        newQuestion.appendTo(questions)
        parent.find('.remove-question').addClass('enabled')
        parent.next().find('.number').text("#{questionsCount + 1}.")
        newQuestion.find('input').each ()->
          $(@).attr('id', $(@).attr('id').replace(/attributes\_\d+/, "attributes_#{questionsCount}"))
          $(@).attr('name', $(@).attr('name').replace(/attributes\]\[\d+/, "attributes][#{questionsCount}"))
  
  toggleSlide: (clickElement, container) ->
    @container.find(clickElement + '> .header').on 'click', ->
      checkbox = $(@).children('input[type="checkbox"]')
      checkedValue = checkbox.prop('checked')
      checkbox.prop('checked', !checkedValue)
      tableContainer = $(@).parents(clickElement).find(container)

      if checkbox.is(':checked')
        tableContainer.hide().removeClass('hidden')
        tableContainer.slideDown()   
      else 
        tableContainer.slideUp()

      if clickElement is '.service'
        systemsCheckboxes = $(@).parents(clickElement).find('.content-container .header input:checkbox')
        checkedCheckboxes = $(@).parents(clickElement).find('.content-container .header input:checkbox:checked')
        if checkedCheckboxes.length is 0 and !checkedValue
          for ratingCheckbox in systemsCheckboxes
            $(ratingCheckbox).trigger('click')

        $.ajax
          url: checkbox.data('url')
          method: 'post'
          data:
            _method: 'put'
            transactable_type:
              enable_reviews: checkbox.is(':checked')
