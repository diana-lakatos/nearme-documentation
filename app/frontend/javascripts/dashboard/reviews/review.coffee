require 'raty-js/lib/jquery.raty'

module.exports = class Review
  constructor: (form)->
    @form = $(form)
    @mode = @form.data('review-form')
    @ratings = @form.find('.rating')
    @commentField = @form.find('textarea')
    @commentContent = @form.find('blockquote')

    @reviewId = @form.data('review-id')
    @reviewableId = @form.data('reviewable-id')
    @reviewableType = @form.data('reviewable-type')
    @ratingSystemId = @form.data('rating-system-id')
    @transactableTypeId = @form.find('input[name="transactable_type_id"]').val()

    @isEditable = (@mode == 'create')

    if @mode == 'create'
      @formMethod = 'POST'
      @formAction = @form.attr('action')
    else
      @formMethod = 'PUT'
      @formAction = "#{@form.attr('action')}/#{@reviewId}"

    @bindEvents()
    @initialize()

  bindEvents: ->
    @form.on 'click', '[data-edit-toggle]', (e)=>
      e.preventDefault()
      @toggleEdit(!@isEditable)

    @form.on 'submit', @submitRating

  initialize: ->
    @ratingsInit()
    @toggleEdit(@isEditable)

  ratingsInit: ->
    @ratings.each (index) =>
      element = $(@ratings[index])

      if element.attr('data-images') == '1'
        element.raty
          hints: ->
            $(@).data("hints")
          score: ->
            return $(@).data('score')
          starOff: element.attr('data-star-off')
          starOn: element.attr('data-star-on')
      else
        element.raty
          starType: 'i'
          hints: ->
            $(@).data("hints")
          score: ->
            return $(@).data('score')

  toggleEdit: (state, persist = false) =>
    @isEditable = state
    @form.toggleClass('is-editable', state)
    @ratings.each ->
      data = { readOnly: !state }
      if persist
        data.score = $(this).raty('score')

      $(this).raty('set', data)

    if state
      @updateCommentFieldFromContent()

    if persist and !state
      @updateCommentContentFromField()

  updateCommentContentFromField: ->
    @commentContent.html(@commentField.val())

  updateCommentFieldFromContent: ->
    @commentField.val(@commentContent.html())

  submitRating: (e)=>
    e.preventDefault()

    @form.find('.thanks').remove()
    @removeErrors()

    formData = if (@mode == 'create') then @createRatingData() else @updateRatingData()

    $.ajax
      url: @formAction
      method: @formMethod
      data: formData
      success: (response) =>
        @toggleEdit(false, true)
        @removeErrors()
        @form.prepend( response )

      error: (response) =>
        @showErrors(response)
        $.rails.enableFormElements($('form.review-form'))

  createRatingData: =>
    return {
      rating_system_id: @ratingSystemId
      review:
        rating: @ratings.first().raty('score')
        comment: @commentField.val()
        reviewable_id: @reviewableId
        reviewable_type: @reviewableType
        transactable_type_id: @transactableTypeId
      rating_answers:
        for questionRating in @form.find('.rating-questions .rating')
          {rating_question_id: $(questionRating).data('question-id'), rating: $(questionRating).raty('score') || ''}
    }

  updateRatingData: (e)=>
    return {
      review:
        rating: @ratings.eq(0).raty('score') || 0
        comment: @commentField.val()
        reviewable_id: @reviewableId
        reviewable_type: @reviewableType
      rating_answers:
        for questionRating in @form.find('.rating-questions .rating')
          {id: $(questionRating).data('answerId'), rating_question_id: $(questionRating).data('questionId'), rating: $(questionRating).raty('score') || ''}
    }

  showErrors: (response) =>
    @removeErrors()
    errors = response.responseJSON
    if errors.rating_error && @form.find('.rating-error').length is 0
      @ratings.eq(0).after(errors.rating_error)
    if errors.comment_error
      @commentField.after(errors.comment_error)

  removeErrors: ->
    @form.find('.comment-error, .rating-error').remove()
