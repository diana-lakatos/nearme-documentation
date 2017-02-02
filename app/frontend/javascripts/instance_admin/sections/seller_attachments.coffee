require('bootstrap-switch/src/coffee/bootstrap-switch')

module.exports = class InstanceAdminSellerAttachmentsController
  constructor: (@container) ->
    @initializeBootstrapSwitch()

  initializeBootstrapSwitch: ->
    @container.find('[data-activate-seller-attachments]').bootstrapSwitch(
      inverse: true
      size: 'mini'
    )

    @container.find('[data-activate-seller-attachments]').on 'switchChange.bootstrapSwitch', (event, state) =>
      optionsWrapper = @container.find('[data-options-wrapper]')
      descriptionForEnabled = @container.find('[data-description-for-enabled]')

      if event.type == 'switchChange'
        if @container.find('[data-activate-seller-attachments]').is(':checked')
          optionsWrapper.removeClass('hide')
          descriptionForEnabled.removeClass('hide')
        else
          optionsWrapper.addClass('hide')
          descriptionForEnabled.addClass('hide')
