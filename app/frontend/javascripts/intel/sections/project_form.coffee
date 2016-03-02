module.exports = class ProjectForm
  constructor: (@form) ->
    @projectCollaboratorActions = @form.find("[data-project-collaborator]")
    @projectCollaboratorEmail = @form.find("[data-project-collaborator-email]")
    @projectCollaboratorsList = @form.find("table.collaborators-listing-a tbody")
    @bindEvents()

  bindEvents: ->
    @projectCollaboratorActions.each (i, element) =>
      $(element).on "click", (e) =>
        @updateProjectCollaborator(e)

  updateProjectCollaborator: (event) ->
    event.preventDefault()
    request_method = $(event.target).attr("data-action")
    that = @

    if confirm("Are you sure you want to continue?")
      $.ajax
        type: request_method,
        url: @form.attr('action') + '/project_collaborators/' + $(event.target).attr("data-project-collaborator"),
        dataType: "json",
        data: { project_collaborator: { approved: 'true' } }
        success: (data) -> that.handle_success(data, request_method, event)
        complete: (data) -> that.handle_success(data, request_method, event)

  handle_success: (data, request_method, event) =>
    if request_method == "DELETE"
      $(event.target).parents("tr").hide("slow")
    else
      $(event.target).parents("tr").replaceWith(data.html)
