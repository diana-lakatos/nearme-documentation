module.exports = class InstanceAdminWorkflowFormController

  constructor: (@form) ->
    @alertTypeSelect = @form.find('select[data-alert-type]')
    @optionalSettingWrappers = @form.find('[data-optional-settings]')
    @bindEvents()
    @showRecipientSelectOptions(@alertTypeSelect.val())

  bindEvents: ->
    @alertTypeSelect.on 'change', (event) =>
      @showRecipientSelectOptions($(event.target).val())

  showRecipientSelectOptions: (val) ->
    @optionalSettingWrappers.find('input, select, textarea').prop('disabled', true)
    @optionalSettingWrappers.hide()
    optionalSettings = @form.find("[data-optional-settings-#{val}]")
    optionalSettings.find('input, select, textarea').prop('disabled', false)
    optionalSettings.show()


