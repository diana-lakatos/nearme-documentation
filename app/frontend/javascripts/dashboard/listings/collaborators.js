var Collaborators;

Collaborators = function() {
  function Collaborators(form) {
    this.form = $(form);
    this.transactableCollaboratorActions = this.form.find('[data-transactable-collaborator]');
    this.transactableCollaboratorEmail = this.form.find('[data-transactable-collaborator-email]');
    this.transactableCollaboratorsList = this.form.find('table.collaborators-listing-a tbody');
    this.bindEvents();
  }

  Collaborators.prototype.bindEvents = function() {
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

  Collaborators.prototype.updateProjectCollaborator = function(event) {
    var request_method, that;
    console.log(event);
    console.log('Gogogo');
    event.preventDefault();
    request_method = $(event.target).attr('data-action');
    that = this;
    if (confirm('Are you sure you want to continue?')) {
      return $.ajax({
        type: request_method,
        url: this.form.attr('action') + '/transactable_collaborators/' +
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

  Collaborators.prototype.handle_success = function(data, request_method, event) {
    if (request_method === 'DELETE') {
      return $(event.target).parents('tr').hide('slow');
    } else {
      return $(event.target).parents('tr').replaceWith(data.html);
    }
  };

  return Collaborators;
}();

module.exports = Collaborators;
