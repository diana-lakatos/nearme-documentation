require('bootstrap-switch/src/coffee/bootstrap-switch')

module.exports = class InstanceAdminDocumentsUploadController
  constructor: (@container) ->
    @initializeBootstrapSwitch()

  initializeBootstrapSwitch: ->
    @container.find('[data-activate-upload-files]').bootstrapSwitch(
      inverse: true
      size: 'mini'
    )

    @container.find('[data-activate-upload-files]').on 'switchChange.bootstrapSwitch', (event, state) =>
      optionsWrapper = @container.find('[data-options-wrapper]')
      descriptionForEnabled = @container.find('[data-description-for-enabled]')
      descriptionForDisabled = @container.find('[data-description-for-disabled]')

      if event.type == 'switchChange'
        if @container.find('[data-activate-upload-files]').is(':checked')
          optionsWrapper.removeClass('hide')
          descriptionForDisabled.addClass('hide')
          descriptionForEnabled.removeClass('hide')
        else
          optionsWrapper.addClass('hide')
          descriptionForDisabled.removeClass('hide')
          descriptionForEnabled.addClass('hide')
