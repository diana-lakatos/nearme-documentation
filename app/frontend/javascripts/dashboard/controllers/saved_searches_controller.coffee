require 'x-editable/dist/bootstrap3-editable/js/bootstrap-editable'

module.exports = class SavedSearchesController
  constructor: (el) ->
    @container = $(el)
    @bindEvents()

  bindEvents: =>
    @bindAlertsFrequency()
    @bindTitle()

  bindAlertsFrequency: ->
    $('select[data-alerts-frequency]').on 'change', (event) ->
      input = $(event.target)
      container = input.closest('.form-group')
      $.ajax
        url: input.closest('form').attr('action')
        type: 'PATCH'
        data: {alerts_frequency: input.val()}
        success: ->
          container.addClass('field-updated')
          setTimeout(->
            container.removeClass('field-updated')
          , 5000)

  bindTitle: =>
    $.fn.editableform.buttons = """
      <button type='submit' class='editable-submit btn btn-primary btn-sm' title='Save'><span class='fa fa-check'></span></button>
      <button type='button' class='btn btn-default btn-sm editable-cancel'><span class='fa fa-times'></span></button>
    """

    @container.find('[data-pk]').editable({
      ajaxOptions: { type: "PUT", dataType: 'json' },
      mode: 'inline',
      toggle: 'manual'
      validate: (value) ->
        'This field is required' unless $.trim(value)
      params: (params) ->
        params.id = params.pk
        params.saved_search = { title: params.value }
        return params
    })

    @container.on 'click', '[data-edit-action]', (e) ->
      e.stopPropagation()
      $(e.target).closest('tr').find('[data-pk]').editable('toggle')
