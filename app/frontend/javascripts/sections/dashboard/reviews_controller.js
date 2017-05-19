var DashboardReviewsController,
  urlUtil,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

urlUtil = require('../../lib/utils/url');

require('raty-js/lib/jquery.raty');

DashboardReviewsController = function() {
  function DashboardReviewsController(container) {
    this.container = container;
    this.disableRatingStarts = bind(this.disableRatingStarts, this);
    this.showErrors = bind(this.showErrors, this);
    this.bindEvents();
    this.container.find('#products-tabs li:first').addClass('active');
    this.container.find('.reviews .tab-pane:first').addClass('active');
  }

  DashboardReviewsController.prototype.bindEvents = function() {
    this.editableRatingInit();
    this.nonEditableRatingInit();
    $(this.container).find('select.reviews-select').on('change', function() {
      var periodSearchString, searchString;
      periodSearchString = 'period=' + $(this).val();
      searchString = window.location.search;
      if (searchString) {
        if (searchString.match(/period=\w+/)) {
          return window.location.search = searchString.replace(/period=\w+/, periodSearchString);
        } else {
          return window.location.search += '&' + periodSearchString;
        }
      } else {
        return window.location.search = periodSearchString;
      }
    });
    $(this.container).find('select.reviews-select').customSelect({ customClass: 'reviewsSelect' });
    this.container.on(
      'click',
      '.edit',
      function(_this) {
        return function(e) {
          var comment, commentValue, parentForm;
          e.preventDefault();
          parentForm = $(e.currentTarget).parents('form');
          comment = parentForm.find('.comment');
          commentValue = comment.text();
          parentForm.find('.rating').toggleClass('non-editable editable');
          _this.editableRatingInit();
          if (parentForm.find('.comments-title').length) {
            comment.replaceWith(
              _.template($('#edit-comment-template').html())({
                commentValue: commentValue,
                newComment: false
              })
            );
          } else {
            parentForm
              .find('.reviews-additional-content')
              .append(
                _.template($('#edit-comment-template').html())({
                  commentValue: commentValue,
                  newComment: true
                })
              );
          }
          if (parentForm.find('input[type="submit"]').length === 0) {
            parentForm
              .find('.reviews-additional-content')
              .append(_.template($('#submit-review-button-template').html())());
          }
          if (!parentForm.find('.reviews-additional-content').hasClass('in')) {
            parentForm.find('.show-details').trigger('click');
          }
          parentForm.find('input[type="submit"]').show();
          return parentForm.find('div.thanks').remove();
        };
      }(this)
    );
    this.container.on(
      'submit',
      'form.create-form',
      function(_this) {
        return function(e) {
          var commentArea,
            createReviewPath,
            form,
            questionRating,
            ratingSystemId,
            reviewableId,
            reviewableType,
            submitBtn,
            transactableTypeId;
          e.preventDefault();
          form = $(e.currentTarget);
          submitBtn = form.find('input[type="submit"]');
          ratingSystemId = form.find('.review').data('rating-system-id');
          reviewableId = form.find('.review').data('reviewable-id');
          reviewableType = form.find('.review').data('reviewable-type');
          transactableTypeId = form.find('.review input[name=transactable_type_id]').val();
          commentArea = form.find('.comment-wrapper textarea');
          createReviewPath = form.attr('action');
          return $.ajax({
            url: createReviewPath,
            method: 'POST',
            data: {
              rating_system_id: ratingSystemId,
              review: {
                rating: form.find('.rating').first().raty('score'),
                comment: commentArea.val(),
                reviewable_id: reviewableId,
                reviewable_type: reviewableType,
                transactable_type_id: transactableTypeId
              },
              rating_answers: function() {
                var i, len, ref, results;
                ref = form.find('.additional-ratings');
                results = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  questionRating = ref[i];
                  results.push({
                    rating_question_id: $(questionRating).data('questionId'),
                    rating: $(questionRating).find('.rating').raty('score') || ''
                  });
                }
                return results;
              }()
            },
            success: function(response) {
              submitBtn.hide();
              _this.removeErrorsFrom(form);
              commentArea.replaceWith(
                _.template($('#show-comment-template').html())({ commentArea: commentArea.val() })
              );
              return form.find('.reviews-additional-content').prepend(response);
            },
            error: function(response) {
              return _this.showErrors(response, form);
            }
          });
        };
      }(this)
    );
    return this.container.on(
      'submit',
      'form.update-form',
      function(_this) {
        return function(e) {
          var commentArea,
            form,
            questionRating,
            reviewId,
            reviewableId,
            reviewableType,
            submitBtn,
            updateReviewPath;
          e.preventDefault();
          form = $(e.currentTarget);
          submitBtn = form.find('input[type="submit"]');
          reviewId = form.find('a.edit').data('review-id');
          reviewableId = form.find('.review').data('reviewable-id');
          reviewableType = form.find('.review').data('reviewable-type');
          commentArea = form.find('textarea');
          updateReviewPath = form.attr('action') + ('/' + reviewId);
          return $.ajax({
            url: updateReviewPath,
            method: 'PUT',
            data: {
              review: {
                rating: form.find('.rating').first().raty('score') || 0,
                comment: commentArea.val(),
                reviewable_id: reviewableId,
                reviewable_type: reviewableType
              },
              rating_answers: function() {
                var i, len, ref, results;
                ref = form.find('.additional-ratings');
                results = [];
                for (i = 0, len = ref.length; i < len; i++) {
                  questionRating = ref[i];
                  results.push({
                    id: $(questionRating).data('answerId'),
                    rating_question_id: $(questionRating).data('questionId'),
                    rating: $(questionRating).find('.rating').raty('score') || ''
                  });
                }
                return results;
              }()
            },
            success: function(response) {
              submitBtn.hide();
              _this.removeErrorsFrom(form);
              form.find('.reviews-additional-content').prepend(response);
              return form.find('.rating').toggleClass('editable non-editable');
            },
            error: function(response) {
              return _this.showErrors(response, form);
            }
          });
        };
      }(this)
    );
  };

  DashboardReviewsController.prototype.showErrors = function(response, form) {
    var errors;
    this.removeErrorsFrom(form);
    errors = response.responseJSON;
    if (errors.rating_error && form.find('.rating-error').length === 0) {
      if (form.hasClass('update-form')) {
        form.find('.rating').closest('.wrapper').after(errors.rating_error);
      } else {
        form.find('.review-actions .rating').after(errors.rating_error);
      }
    }
    if (errors.comment_error) {
      return form.find('#comment').after(errors.comment_error);
    }
  };

  DashboardReviewsController.prototype.removeErrorsFrom = function(form) {
    form.find('span.comment-error').remove();
    return form.find('span.rating-error').remove();
  };

  DashboardReviewsController.prototype.editableRatingInit = function() {
    var i, len, rating, ref, results;
    ref = $(this.container).find('.rating.editable');
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      rating = ref[i];
      results.push(
        $(rating).raty({
          path: '',
          starOff: urlUtil.assetUrl('raty/star-off-big.png'),
          starOn: urlUtil.assetUrl('raty/star-on-big.png'),
          hints: $(rating).data('hints'),
          click: function() {
            var form;
            form = $(this).parents('form');
            if (!form.find('.reviews-additional-content').hasClass('in')) {
              return form.find('.show-details').trigger('click');
            }
          }
        })
      );
    }
    return results;
  };

  DashboardReviewsController.prototype.nonEditableRatingInit = function() {
    var i, len, rating, ref, results;
    ref = $(this.container).find('.rating.non-editable');
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      rating = ref[i];
      results.push(
        $(rating).raty({
          path: '',
          starOff: urlUtil.assetUrl('raty/star-off-big.png'),
          starOn: urlUtil.assetUrl('raty/star-on-big.png'),
          readOnly: true,
          score: function() {
            return $(this).data('score');
          }
        })
      );
    }
    return results;
  };

  DashboardReviewsController.prototype.disableRatingStarts = function(form) {
    var score;
    score = form.find('input[name=score]').val();
    form.find('.rating').data('score', score);
    form.find('.rating').toggleClass('editable non-editable');
    return this.nonEditableRatingInit();
  };

  return DashboardReviewsController;
}();

module.exports = DashboardReviewsController;
