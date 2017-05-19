var Review,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('raty-js/lib/jquery.raty');

Review = function() {
  function Review(form) {
    this.showErrors = bind(this.showErrors, this);
    this.updateRatingData = bind(this.updateRatingData, this);
    this.createRatingData = bind(this.createRatingData, this);
    this.submitRating = bind(this.submitRating, this);
    this.toggleEdit = bind(this.toggleEdit, this);
    this.form = $(form);
    this.mode = this.form.data('review-form');
    this.ratings = this.form.find('.rating');
    this.commentField = this.form.find('textarea');
    this.commentContent = this.form.find('blockquote');
    this.reviewId = this.form.data('review-id');
    this.reviewableId = this.form.data('reviewable-id');
    this.reviewableType = this.form.data('reviewable-type');
    this.ratingSystemId = this.form.data('rating-system-id');
    this.transactableTypeId = this.form.find('input[name="transactable_type_id"]').val();
    this.isEditable = this.mode === 'create';
    if (this.mode === 'create') {
      this.formMethod = 'POST';
      this.formAction = this.form.attr('action');
    } else {
      this.formMethod = 'PUT';
      this.formAction = this.form.attr('action') + '/' + this.reviewId;
    }
    this.bindEvents();
    this.initialize();
  }

  Review.prototype.bindEvents = function() {
    this.form.on(
      'click',
      '[data-edit-toggle]',
      function(_this) {
        return function(e) {
          e.preventDefault();
          return _this.toggleEdit(!_this.isEditable);
        };
      }(this)
    );
    return this.form.on('submit', this.submitRating);
  };

  Review.prototype.initialize = function() {
    this.ratingsInit();
    return this.toggleEdit(this.isEditable);
  };

  Review.prototype.ratingsInit = function() {
    return this.ratings.each(
      function(_this) {
        return function(index) {
          var element;
          element = $(_this.ratings[index]);
          if (element.attr('data-images') === '1') {
            return element.raty({
              hints: function() {
                return $(this).data('hints');
              },
              score: function() {
                return $(this).data('score');
              },
              starOff: element.attr('data-star-off'),
              starOn: element.attr('data-star-on')
            });
          } else {
            return element.raty({
              starType: 'i',
              hints: function() {
                return $(this).data('hints');
              },
              score: function() {
                return $(this).data('score');
              }
            });
          }
        };
      }(this)
    );
  };

  Review.prototype.toggleEdit = function(state, persist) {
    if (persist == null) {
      persist = false;
    }
    this.isEditable = state;
    this.form.toggleClass('is-editable', state);
    this.ratings.each(function() {
      var data;
      data = { readOnly: !state };
      if (persist) {
        data.score = $(this).raty('score');
      }
      return $(this).raty('set', data);
    });
    if (state) {
      this.updateCommentFieldFromContent();
    }
    if (persist && !state) {
      return this.updateCommentContentFromField();
    }
  };

  Review.prototype.updateCommentContentFromField = function() {
    return this.commentContent.html(this.commentField.val());
  };

  Review.prototype.updateCommentFieldFromContent = function() {
    return this.commentField.val(this.commentContent.html());
  };

  Review.prototype.submitRating = function(e) {
    var formData;
    e.preventDefault();
    this.form.find('.thanks').remove();
    this.removeErrors();
    formData = this.mode === 'create' ? this.createRatingData() : this.updateRatingData();
    return $.ajax({
      url: this.formAction,
      method: this.formMethod,
      data: formData,
      success: function(_this) {
        return function(response) {
          _this.toggleEdit(false, true);
          _this.removeErrors();
          return _this.form.prepend(response);
        };
      }(this),
      error: function(_this) {
        return function(response) {
          _this.showErrors(response);
          return $.rails.enableFormElements($('form.review-form'));
        };
      }(this)
    });
  };

  Review.prototype.createRatingData = function() {
    var questionRating;
    return {
      rating_system_id: this.ratingSystemId,
      review: {
        rating: this.ratings.first().raty('score'),
        comment: this.commentField.val(),
        reviewable_id: this.reviewableId,
        reviewable_type: this.reviewableType,
        transactable_type_id: this.transactableTypeId
      },
      rating_answers: function() {
        var i, len, ref, results;
        ref = this.form.find('.rating-questions .rating');
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          questionRating = ref[i];
          results.push({
            rating_question_id: $(questionRating).data('question-id'),
            rating: $(questionRating).raty('score') || ''
          });
        }
        return results;
      }.call(this)
    };
  };

  Review.prototype.updateRatingData = function() {
    var questionRating;
    return {
      review: {
        rating: this.ratings.eq(0).raty('score') || 0,
        comment: this.commentField.val(),
        reviewable_id: this.reviewableId,
        reviewable_type: this.reviewableType
      },
      rating_answers: function() {
        var i, len, ref, results;
        ref = this.form.find('.rating-questions .rating');
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          questionRating = ref[i];
          results.push({
            id: $(questionRating).data('answerId'),
            rating_question_id: $(questionRating).data('questionId'),
            rating: $(questionRating).raty('score') || ''
          });
        }
        return results;
      }.call(this)
    };
  };

  Review.prototype.showErrors = function(response) {
    var errors;
    this.removeErrors();
    errors = response.responseJSON;
    if (errors.rating_error && this.form.find('.rating-error').length === 0) {
      this.ratings.eq(0).after(errors.rating_error);
    }
    if (errors.comment_error) {
      return this.commentField.after(errors.comment_error);
    }
  };

  Review.prototype.removeErrors = function() {
    return this.form.find('.comment-error, .rating-error').remove();
  };

  return Review;
}();

module.exports = Review;
