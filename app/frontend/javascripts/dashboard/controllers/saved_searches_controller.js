var SavedSearchesController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

require('x-editable/dist/bootstrap3-editable/js/bootstrap-editable');

SavedSearchesController = function() {
  function SavedSearchesController(el) {
    this.bindTitle = bind(this.bindTitle, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.container = $(el);
    this.bindEvents();
  }

  SavedSearchesController.prototype.bindEvents = function() {
    this.bindAlertsFrequency();
    return this.bindTitle();
  };

  SavedSearchesController.prototype.bindAlertsFrequency = function() {
    return $('select[data-alerts-frequency]').on('change', function(event) {
      var container, input;
      input = $(event.target);
      container = input.closest('.form-group');
      return $.ajax({
        url: input.closest('form').attr('action'),
        type: 'PATCH',
        data: { alerts_frequency: input.val() },
        success: function() {
          container.addClass('field-updated');
          return setTimeout(
            function() {
              return container.removeClass('field-updated');
            },
            5000
          );
        }
      });
    });
  };

  SavedSearchesController.prototype.bindTitle = function() {
    $.fn.editableform.buttons = "<button type='submit' class='editable-submit btn btn-primary btn-sm' title='Save'><span class='fa fa-check'></span></button>\n<button type='button' class='btn btn-default btn-sm editable-cancel'><span class='fa fa-times'></span></button>";
    this.container.find('[data-pk]').editable({
      ajaxOptions: { type: 'PUT', dataType: 'json' },
      mode: 'inline',
      toggle: 'manual',
      validate: function(value) {
        if (!$.trim(value)) {
          return 'This field is required';
        }
      },
      params: function(params) {
        params.id = params.pk;
        params.saved_search = { title: params.value };
        return params;
      }
    });
    return this.container.on('click', '[data-edit-action]', function(e) {
      e.stopPropagation();
      return $(e.target).closest('tr').find('[data-pk]').editable('toggle');
    });
  };

  return SavedSearchesController;
}();

module.exports = SavedSearchesController;
