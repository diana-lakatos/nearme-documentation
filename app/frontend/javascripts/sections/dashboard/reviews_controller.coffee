urlUtil = require('../../lib/utils/url')
require('raty-js/lib/jquery.raty')

module.exports = class DashboardReviewsController
  constructor: (@container) ->
    @bindEvents()
    @container.find('#products-tabs li:first').addClass('active')
    @container.find('.reviews .tab-pane:first').addClass('active')

  bindEvents: ->
    @editableRatingInit()
    @nonEditableRatingInit()

    $(@container).find("select.reviews-select").on 'change', (e) ->
      periodSearchString = "period=#{$(@).val()}"
      searchString = window.location.search
      if searchString
        if searchString.match /period=\w+/
          window.location.search = searchString.replace /period=\w+/, periodSearchString
        else
          window.location.search += "&#{periodSearchString}"
      else
        window.location.search = periodSearchString

    $(@container).find("select.reviews-select").customSelect({customClass: "reviewsSelect"})

    @container.on 'click', '.edit', (e) =>
      e.preventDefault()
      parentForm = $(e.currentTarget).parents('form')
      comment = parentForm.find('.comment')
      commentValue = comment.text()
      parentForm.find('.rating').toggleClass('non-editable editable')
      @editableRatingInit()
      if parentForm.find('.comments-title').length
        comment.replaceWith _.template($('#edit-comment-template').html())({ commentValue: commentValue, newComment: false })
      else
        parentForm.find('.reviews-additional-content').append( _.template($('#edit-comment-template').html())({ commentValue: commentValue, newComment: true }) )
      if parentForm.find('input[type="submit"]').length is 0
        parentForm.find('.reviews-additional-content').append( _.template($('#submit-review-button-template').html())() )
      parentForm.find(".show-details").trigger "click" unless parentForm.find(".reviews-additional-content").hasClass("in")
      parentForm.find('input[type="submit"]').show()
      parentForm.find('div.thanks').remove()

    @container.on 'submit', 'form.create-form', (e) =>
      e.preventDefault()
      form = $(e.currentTarget)
      submitBtn = form.find('input[type="submit"]')
      ratingSystemId = form.find('.review').data('rating-system-id')
      reviewableId = form.find('.review').data('reviewable-id')
      reviewableType = form.find('.review').data('reviewable-type')
      transactableTypeId = form.find('.review input[name=transactable_type_id]').val()
      commentArea = form.find('.comment-wrapper textarea')
      createReviewPath = form.attr('action')
      $.ajax
        url: createReviewPath
        method: 'POST'
        data:
          rating_system_id: ratingSystemId
          review:
            rating: form.find('.rating').first().raty('score')
            comment: commentArea.val()
            reviewable_id: reviewableId
            reviewable_type: reviewableType
            transactable_type_id: transactableTypeId
          rating_answers:
            for questionRating in form.find('.additional-ratings')
              {rating_question_id: $(questionRating).data('questionId'), rating: $(questionRating).find('.rating').raty('score') || ''}
        success: (response) =>
          submitBtn.hide()
          @removeErrorsFrom(form)
          commentArea.replaceWith( _.template($('#show-comment-template').html())({ commentArea: commentArea.val() }) )
          form.find('.reviews-additional-content').prepend( response )
        error: (response) =>
          @showErrors(response, form)


    @container.on 'submit', 'form.update-form', (e) =>
      e.preventDefault()
      form = $(e.currentTarget)
      submitBtn = form.find('input[type="submit"]')
      reviewId = form.find('a.edit').data('review-id')
      reviewableId = form.find('.review').data('reviewable-id')
      reviewableType = form.find('.review').data('reviewable-type')
      commentArea = form.find('textarea')
      updateReviewPath = form.attr('action') + "/#{reviewId}"
      $.ajax
        url: updateReviewPath
        method: 'PUT'
        data:
          review:
            rating: form.find('.rating').first().raty('score') || 0
            comment: commentArea.val()
            reviewable_id: reviewableId
            reviewable_type: reviewableType
          rating_answers:
            for questionRating in form.find('.additional-ratings')
              {id: $(questionRating).data('answerId'), rating_question_id: $(questionRating).data('questionId'), rating: $(questionRating).find('.rating').raty('score') || ''}
        success: (response) =>
          submitBtn.hide()
          wrapper = submitBtn.closest('.review')
          showDetails = wrapper.find('.show-details')
          reviewsAdditionalContent = wrapper.find('.reviews-additional-content')
          @removeErrorsFrom(form)
          form.find('.reviews-additional-content').prepend( response )
          form.find('.rating').toggleClass('editable non-editable')
        error: (response) =>
          @showErrors(response, form)

  showErrors: (response, form) =>
    @removeErrorsFrom(form)
    errors = response.responseJSON
    if errors.rating_error && form.find('.rating-error').length is 0
      if form.hasClass('update-form')
        form.find('.rating').closest('.wrapper').after(errors.rating_error)
      else
        form.find('.review-actions .rating').after(errors.rating_error)
    if errors.comment_error
      form.find('#comment').after(errors.comment_error)

  removeErrorsFrom: (form) ->
    form.find('span.comment-error').remove()
    form.find('span.rating-error').remove()

  editableRatingInit: ->
    for rating in $(@container).find(".rating.editable")
      $(rating).raty
        path: ''
        starOff: urlUtil.assetUrl('raty/star-off-big.png')
        starOn: urlUtil.assetUrl('raty/star-on-big.png')
        hints: $(rating).data("hints")
        click: (score) ->
          form = $(@).parents('form')
          form.find(".show-details").trigger "click"  unless form.find(".reviews-additional-content").hasClass("in")

  nonEditableRatingInit: ->
    for rating in $(@container).find(".rating.non-editable")
      $(rating).raty
        path: ''
        starOff: urlUtil.assetUrl('raty/star-off-big.png')
        starOn: urlUtil.assetUrl('raty/star-on-big.png')
        readOnly: true
        score: ->
          return $(@).data('score')

  disableRatingStarts: (form) =>
    score = form.find('input[name=score]').val()
    form.find('.rating').data('score', score)
    form.find('.rating').toggleClass('editable non-editable')
    @nonEditableRatingInit()
