module.exports = class DocumentRequirementsController
  constructor: (el) ->
    @container = $(el)
    @selector = @container.find('input[type=radio][name*=upload_obligation_attributes]')
    @documentFields = @container.find('.document-requirements-fields')

    @bindEvents()
    @updateState()

  bindEvents: ->
    @selector.on 'change', =>
      @updateState()

    @documentFields.on 'cocoon:before-remove', (e,fields) ->
      parent = $(fields).closest('.nested-container')
      parent.find('input[data-destroy-input]').val('true')
      parent.hide()
      parent.prependTo(parent.closest('form'))

  updateState: ->
    if @selector.filter(':checked').val() == "Not Required"
      @hideFields()
    else
      @showFields()

  showFields: ->
    @documentFields.find('input, textarea').prop('disabled', false)
    @documentFields.find('.disabled').removeClass('disabled')
    @documentFields.show()

  hideFields: ->
    @documentFields.hide()
    @documentFields.find('input, textarea').prop('disabled', true)
