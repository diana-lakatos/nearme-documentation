var ProjectForm,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

ProjectForm = function() {
  function ProjectForm(form) {
    this.form = form;
    this.handle_success = bind(this.handle_success, this);
    this.transactableCollaboratorActions = this.form.find('[data-transactable-collaborator]');
    this.transactableCollaboratorEmail = this.form.find('[data-transactable-collaborator-email]');
    this.transactableCollaboratorsList = this.form.find('table.collaborators-listing-a tbody');
    this.bindEvents();
  }

  ProjectForm.prototype.bindEvents = function() {
    return this.transactableCollaboratorActions.each(
      function(_this) {
        return function(i, element) {
          return $(element).on('click', function(e) {
            return _this.updateProjectCollaborator(e);
          });
        };
      }(this)
    );
  };

  ProjectForm.prototype.updateProjectCollaborator = function(event) {
    var request_method, that;
    event.preventDefault();
    request_method = $(event.target).attr('data-action');
    that = this;
    if (confirm('Are you sure you want to continue?')) {
      return $.ajax({
        type: request_method,
        url: this.form.attr('action') + '/company/transactable_collaborators/' +
          $(event.target).attr('data-transactable-collaborator'),
        dataType: 'json',
        data: { transactable_collaborator: { approved: 'true' } },
        success: function(data) {
          return that.handle_success(data, request_method, event);
        },
        complete: function(data) {
          return that.handle_success(data, request_method, event);
        }
      });
    }
  };

  ProjectForm.prototype.handle_success = function(data, request_method, event) {
    var new_data;
    if (request_method === 'DELETE') {
      return $(event.target).parents('tr').hide('slow');
    } else {
      new_data = $(data.html);
      $(event.target).parents('tr').replaceWith(new_data);
      return new_data.find('[data-transactable-collaborator]').on(
        'click',
        function(_this) {
          return function(e) {
            return _this.updateProjectCollaborator(e);
          };
        }(this)
      );
    }
  };

  return ProjectForm;
}();

module.exports = ProjectForm;
