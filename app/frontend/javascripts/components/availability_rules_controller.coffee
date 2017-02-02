module.exports = class AvailabilityRulesController

  constructor: (@container) ->
    if @container.find('input[type=radio][name*=availability_template]').length > 0
      @selector = @container.find('input[type=radio][name*=availability_template]')
      @customFields = @container.find('.custom-availability-rules')

      # Set up event listeners
      @bindEvents()

      # Update for initial state
      @updateCustomState()

  updateCustomState: ->
    if @selector.filter(':checked').attr('data-custom-rules')?
      @showCustom()
    else
      @hideCustom()

  showCustom: ->
    @customFields.find('input, select').prop('disabled', false)
    @customFields.find('.disabled').removeClass('disabled')
    @customFields.show()

  hideCustom: ->
    @customFields.hide()
    @customFields.find('input, select').prop('disabled', true)

  bindEvents: ->
    # Whenever the template selector changes we need to update the state of the UI
    @selector.change (event) =>
      @updateCustomState()

    @customFields.on 'cocoon:before-remove', (e,fields) ->
      $(fields).closest('.nested-container').find('.transactable_availability_template_availability_rules__destroy input').val('true')
