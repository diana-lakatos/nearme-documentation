module.exports = class Collaborators
  constructor: (form) ->

    @form = $(form)
    @transactableCollaboratorActions = @form.find("[data-transactable-collaborator]")
    @transactableCollaboratorEmail = @form.find("[data-transactable-collaborator-email]")
    @transactableCollaboratorsList = @form.find("table.collaborators-listing-a tbody")
    @bindEvents()

  bindEvents: ->

    @transactableCollaboratorActions.each (i, element) =>
      $(element).on "click", (e) =>
        @updateProjectCollaborator(e)

  updateProjectCollaborator: (event) ->
    console.log(event)
    console.log('Gogogo')
    event.preventDefault()
    request_method = $(event.target).attr("data-action")
    that = @

    if confirm("Are you sure you want to continue?")
      $.ajax
        type: request_method,
        url: @form.attr('action') + '/transactable_collaborators/' + $(event.target).attr("data-transactable-collaborator"),
        dataType: "json",
        data: { transactable_collaborator: { approved: 'true' } }
        success: (data) -> that.handle_success(data, request_method, event)
        complete: (data) -> that.handle_success(data, request_method, event)

  handle_success: (data, request_method, event) ->
    if request_method == "DELETE"
      $(event.target).parents("tr").hide("slow")
    else
      $(event.target).parents("tr").replaceWith(data.html)
