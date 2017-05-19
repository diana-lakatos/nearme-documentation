var InstanceAdminRatingSystemsController;

InstanceAdminRatingSystemsController = function() {
  function InstanceAdminRatingSystemsController(container1) {
    this.container = container1;
    this.bindEvents();
  }

  InstanceAdminRatingSystemsController.prototype.bindEvents = function() {
    this.toggleSlide('.rating-system', '.table-container', '> .header');
    this.toggleSlide('.service', '.ratings-content-container', ' .service-name');
    this.toggleSlide('.service', '.ratings-content-container', ' .only-if-both-completed');
    this.container.find('.header input[type="checkbox"]').on('click', function() {
      var checkedValue;
      checkedValue = $(this).prop('checked');
      return $(this).prop('checked', !checkedValue);
    });
    this.removeQuestionEvents();
    return this.keyDownEvents();
  };

  InstanceAdminRatingSystemsController.prototype.toggleSlide = function(
    clickElement,
    container,
    selector
  ) {
    return this.container.find(clickElement + selector).on('click', function() {
      var checkbox,
        checkedCheckboxes,
        checkedValue,
        i,
        j,
        len,
        len1,
        params,
        ratingCheckbox,
        systemsCheckboxes,
        tableContainer;
      checkbox = $(this).children('input[type="checkbox"]');
      checkedValue = checkbox.prop('checked');
      checkbox.prop('checked', !checkedValue);
      tableContainer = $(this).parents(clickElement).find(container);
      if (selector === ' .only-if-both-completed') {
        params = { show_reviews_if_both_completed: checkbox.is(':checked') };
        if (checkbox.is(':checked')) {
          systemsCheckboxes = $(this)
            .parents(clickElement)
            .find('.content-container .header input:checkbox');
          for (i = 0, len = systemsCheckboxes.length; i < len; i++) {
            ratingCheckbox = systemsCheckboxes[i];
            if (
              !$(ratingCheckbox).is(':checked') &&
                $(ratingCheckbox).data('subject') !== checkbox.data('service-name')
            ) {
              $(ratingCheckbox).trigger('click');
            }
          }
        }
      } else {
        if (checkbox.is(':checked')) {
          tableContainer.hide().removeClass('hidden');
          tableContainer.slideDown();
        } else {
          tableContainer.slideUp();
        }
        if (selector === ' .service-name') {
          params = { enable_reviews: checkbox.is(':checked') };
          systemsCheckboxes = $(this)
            .parents(clickElement)
            .find('.content-container .header input:checkbox');
          checkedCheckboxes = $(this)
            .parents(clickElement)
            .find('.content-container .header input:checkbox:checked');
          if (checkedCheckboxes.length === 0 && !checkedValue) {
            for (j = 0, len1 = systemsCheckboxes.length; j < len1; j++) {
              ratingCheckbox = systemsCheckboxes[j];
              $(ratingCheckbox).trigger('click');
            }
          }
        }
      }
      if (params != null) {
        return $.ajax({
          url: checkbox.data('url'),
          method: 'post',
          data: { _method: 'put', transactable_type: params }
        });
      }
    });
  };

  InstanceAdminRatingSystemsController.prototype.removeQuestionEvents = function() {
    var self;
    self = this;
    return this.container.on('click', '.remove-question.enabled', function() {
      var parent, questions, questionsCount, ratingSystem;
      parent = $(this).parent();
      questions = $(this).parents('.questions');
      ratingSystem = $(this).parents('.rating-system');
      questionsCount = self.questionsCount(ratingSystem);
      if (questionsCount === 2) {
        ratingSystem.find('.questions .remove-question').removeClass('enabled');
      }
      if (parent.find('.question-id').val().length) {
        parent.find('input[type="checkbox"]').prop('checked', true);
        parent.hide();
      } else {
        parent.remove();
      }
      return self.updateQuestionNumbers(questions);
    });
  };

  InstanceAdminRatingSystemsController.prototype.keyDownEvents = function() {
    var self;
    self = this;
    return this.container.on('input', '.question-input', function() {
      var newQuestion, parent, questions, questionsCount, ratingSystem;
      parent = $(this).parent();
      questions = $(this).parents('.questions');
      ratingSystem = $(this).parents('.rating-system');
      questionsCount = self.questionsCount(ratingSystem);
      questions.find('.remove-question').addClass('enabled');
      if (parent.next().length === 0 && questionsCount < 5) {
        newQuestion = $(this).parent().clone();
        newQuestion.appendTo(questions);
        newQuestion.find('input').each(function() {
          $(
            this
          ).attr('id', $(this).attr('id').replace(/attributes\_\d+/, 'attributes_' + questionsCount));
          $(
            this
          ).attr('name', $(this).attr('name').replace(/attributes\]\[\d+/, 'attributes][' + questionsCount));
          return $(this).val('');
        });
        return self.updateQuestionNumbers(questions);
      }
    });
  };

  InstanceAdminRatingSystemsController.prototype.questionsCount = function(ratingSystem) {
    return ratingSystem.find('.question:visible').length;
  };

  InstanceAdminRatingSystemsController.prototype.updateQuestionNumbers = function(questions) {
    var index;
    index = 1;
    return questions.find('.number:visible').each(function() {
      $(this).text(index + '.');
      return index += 1;
    });
  };

  return InstanceAdminRatingSystemsController;
}();

module.exports = InstanceAdminRatingSystemsController;
