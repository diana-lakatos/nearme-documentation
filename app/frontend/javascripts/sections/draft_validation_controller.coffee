module.exports = class DraftValidationController

  constructor: (form) ->
    @form = $(form)
    @bindEvents()
    @formMethod = @form.find('input[name="_method"]').val()
    @formAction = @form.attr('action')


  bindEvents: =>
    @submitDraftOnChange()

  submitDraftOnChange: =>
    if @form.find('[data-autosave-draft]').length == 0
      return false

    if @form.find('input[type="submit"]:disabled').length > 0
      return false

    @form.find('input, textarea').change (event) =>
      field = $(event.target)
      if @formMethod == "PATCH"
        method = 'PUT'
      else
        method = 'POST'

      $.ajax
        type: method
        url: @formAction
        data: @form.serialize() + "&save_draft=true&save_as_draft=true"
        dataType: 'JSON'
        cache: false
        error: @handleAjaxError
        success: @handleAjaxSuccess(field)

      true


  handleAjaxSuccess: (field) ->
    icon = $('<span class="fa fa-check" style="color:green; position:absolute; right: 1px" aria-hidden="true"></span>')
    field.parents('.control-group, .form-group').append(icon).css('position', 'relative')
    icon.delay(1000).fadeOut()
