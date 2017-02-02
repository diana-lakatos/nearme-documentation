module.exports = class InstanceAdminRatingSystemsController
  constructor: (@container) ->
    @bindEvents()

  bindEvents: ->
    @toggleSlide('.rating-system', '.table-container', '> .header')
    @toggleSlide('.service', '.ratings-content-container', ' .service-name')
    @toggleSlide('.service', '.ratings-content-container', ' .only-if-both-completed')

    @container.find('.header input[type="checkbox"]').on 'click', ->
      checkedValue = $(@).prop('checked')
      $(@).prop('checked', !checkedValue)


    @removeQuestionEvents()
    @keyDownEvents()

  toggleSlide: (clickElement, container, selector) ->
    @container.find(clickElement + selector).on 'click', ->
      checkbox = $(@).children('input[type="checkbox"]')
      checkedValue = checkbox.prop('checked')
      checkbox.prop('checked', !checkedValue)
      tableContainer = $(@).parents(clickElement).find(container)

      if selector is ' .only-if-both-completed'
        params = { show_reviews_if_both_completed: checkbox.is(':checked') }
        if checkbox.is(':checked')
          systemsCheckboxes = $(@).parents(clickElement).find('.content-container .header input:checkbox')
          for ratingCheckbox in systemsCheckboxes
            if !$(ratingCheckbox).is(':checked') && $(ratingCheckbox).data('subject') != checkbox.data('service-name')
              $(ratingCheckbox).trigger('click')
      else
        if checkbox.is(':checked')
          tableContainer.hide().removeClass('hidden')
          tableContainer.slideDown()
        else
          tableContainer.slideUp()

        if selector is ' .service-name'
          params = { enable_reviews: checkbox.is(':checked') }
          systemsCheckboxes = $(@).parents(clickElement).find('.content-container .header input:checkbox')
          checkedCheckboxes = $(@).parents(clickElement).find('.content-container .header input:checkbox:checked')
          if checkedCheckboxes.length is 0 and !checkedValue
            for ratingCheckbox in systemsCheckboxes
              $(ratingCheckbox).trigger('click')

      if params?
        $.ajax
          url: checkbox.data('url')
          method: 'post'
          data:
            _method: 'put'
            transactable_type:
              params

  removeQuestionEvents: ->
    self = @

    @container.on 'click', '.remove-question.enabled', ->
      parent = $(@).parent()
      questions = $(@).parents('.questions')
      ratingSystem = $(@).parents('.rating-system')

      questionsCount = self.questionsCount(ratingSystem)

      if questionsCount == 2
        ratingSystem.find('.questions .remove-question').removeClass('enabled')

      if parent.find('.question-id').val().length
        parent.find('input[type="checkbox"]').prop('checked', true)
        parent.hide()
      else
        parent.remove()

      self.updateQuestionNumbers(questions)


  keyDownEvents: ->
    self = @

    @container.on 'input', '.question-input', ->
      parent = $(@).parent()
      questions = $(@).parents('.questions')
      ratingSystem = $(@).parents('.rating-system')

      questionsCount = self.questionsCount(ratingSystem)
      questions.find('.remove-question').addClass('enabled')

      if parent.next().length is 0 and questionsCount < 5
        newQuestion = $(@).parent().clone()
        newQuestion.appendTo(questions)

        newQuestion.find('input').each ->
          $(@).attr('id', $(@).attr('id').replace(/attributes\_\d+/, "attributes_#{questionsCount}"))
          $(@).attr('name', $(@).attr('name').replace(/attributes\]\[\d+/, "attributes][#{questionsCount}"))
          $(@).val('')

        self.updateQuestionNumbers(questions)

  questionsCount: (ratingSystem, event) ->
    ratingSystem.find('.question:visible').length

  updateQuestionNumbers: (questions) ->
    index = 1
    questions.find('.number:visible').each ->
      $(@).text("#{index}.")
      index += 1
