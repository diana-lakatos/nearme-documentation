module.exports = class ProjectForm
  constructor: (@form) ->
    @transactableCollaboratorActions = @form.find("[data-transactable-collaborator]")
    @transactableCollaboratorEmail = @form.find("[data-transactable-collaborator-email]")
    @transactableCollaboratorsList = @form.find("table.collaborators-listing-a tbody")
    @bindEvents()

  bindEvents: ->
    @transactableCollaboratorActions.each (i, element) =>
      $(element).on "click", (e) =>
        @updateProjectCollaborator(e)

  updateProjectCollaborator: (event) ->
    event.preventDefault()
    request_method = $(event.target).attr("data-action")
    that = @

    if confirm("Are you sure you want to continue?")
      $.ajax
        type: request_method,
        url: @form.attr('action') + '/company/transactable_collaborators/' + $(event.target).attr("data-transactable-collaborator"),
        dataType: "json",
        data: { transactable_collaborator: { approved: 'true' } }
        success: (data) -> that.handle_success(data, request_method, event)
        complete: (data) -> that.handle_success(data, request_method, event)

  handle_success: (data, request_method, event) =>
    if request_method == "DELETE"
      $(event.target).parents("tr").hide("slow")
    else
      new_data = $(data.html)
      $(event.target).parents("tr").replaceWith(new_data)
      new_data.find("[data-transactable-collaborator]").on "click", (e) =>
        @updateProjectCollaborator(e)
