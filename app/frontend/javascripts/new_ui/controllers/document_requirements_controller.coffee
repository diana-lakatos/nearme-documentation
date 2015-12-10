module.exports = class DocumentRequirementsController
  constructor: (el) ->
    @container = $(el)
    @removeLinks = @container.find(".remove-document-requirement:not(:first)")
    @hiddenFields = @container.find(".document-hidden")
    @removeFields = @container.find(".remove-document")
    @requirementFields = @container.find('[data-requirement]')

    @newLink = @container.find('[data-new-requirement]')

    @bindEvents()
    @initialize()

  bindEvents: ->

    @hiddenFields.on 'change', (e)=>
      $(e.target).closest('[data-requirement]').toggle( !$(e.target).is(':checked') )
      @toggleAddLink()

    @removeFields.on 'change', (e)=>
      $(e.target).closest('[data-requirement]').hide() if $(e.target).is(':checked')
      @toggleAddLink()

    @newLink.on 'click', =>
      @hiddenFields.filter(':checked').eq(0).prop('checked', false).trigger("change")
      @toggleAddLink()


    @container.on 'change','.radio_buttons [type=radio]', (e) =>
      if $(e.currentTarget).val() is 'Not Required'
        @hideRequirementFields()
      else
        @showRequirementFields()

  toggleAddLink: ->
    @newLink.toggle(@hiddenFields.filter(':checked').length > 0)

  hideRequirementFields: ->
    @hiddenFields.each (index, item)->
      return unless $(item).closest('[data-requirement]').is(':visible')
      $(item).data('hide', true)
      $(item).prop("checked", true)

    @container.find('.document-requirements-fields').addClass('hidden')

  showRequirementFields: ->
    @hiddenFields.each (index, item)->
      return unless $(item).data('hide')
      $(item).removeData('hide')
      $(item).prop("checked",false)

    @container.find('.document-requirements-fields').removeClass('hidden')
    @container.find('.document-requirements-fields input, textarea').prop("disabled",false)

  initialize: ->
    @removeLinks.removeClass('hidden');

    @hiddenFields.filter(':checked').each ->
      $(@).closest('[data-requirement]').hide()

    @removeFields.filter(':checked').each ->
      $(@).closest('[data-requirement]').hide()

    unless @container.find('.radio_buttons [type=radio]:checked').val() is 'Not Required'
      @container.find('.document-requirements-fields input, textarea').prop("disabled",false)
