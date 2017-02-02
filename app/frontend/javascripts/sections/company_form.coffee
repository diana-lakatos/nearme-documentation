DahboardAddressController = require('./dashboard/address_controller')

module.exports = class CompanyForm

  constructor: (@form) ->
    @whiteLabelSettingsEnabler = @form.find('input[data-white-label-enabler]')
    @whiteLabelCheckboxes = @form.find('input[data-white-label-settings]')
    @whiteLabelSettingsContainer = @form.find('[data-white-label-settings-container]')
    @resetLinks = @form.find('a[data-reset]')
    @bindEvents()
    @defSynchronizeCheckboxes()
    @setDisabled()
    new DahboardAddressController(@form)

  bindEvents: ->
    @whiteLabelSettingsEnabler.on 'change', =>
      @defSynchronizeCheckboxes()
      @setDisabled()
    @resetLinks.on 'click', (event) =>
      input = @form.find("input[data-color=#{$(event.target).data('reset')}]")
      if !input.prop('disabled')
        input.val(input.data('default'))
      false

  setDisabled: (checkbox) ->
    @whiteLabelSettingsContainer.find('input[type=text], input[type=tel], input[type=email], input[type=url], input[type=color], input[type=file]').prop('disabled', !@whiteLabelSettingsEnabler.is(':checked'))

  defSynchronizeCheckboxes: ->
    @whiteLabelCheckboxes.prop('checked', @whiteLabelSettingsEnabler.is(':checked'))


