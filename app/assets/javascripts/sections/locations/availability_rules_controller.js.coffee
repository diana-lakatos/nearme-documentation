class @AvailabilityRulesController

  constructor: (@container) ->
    @selector = @container.find('select[name*=availability_template]')
    @customFields = @container.find('.custom-availability-rules')

    # Set up event listeners
    @bindEvents()

    # Update for initial state
    @updateCustomState()
    @updateDayStates()

  updateCustomState: ->
    if @selector.val() == ''
      @showCustom()
    else
      @hideCustom()

  updateDayStates: ->
    @customFields.find('input[name*=destroy]').each (i, element) =>
      @updateClosedState($(element))

  showCustom: ->
    @customFields.show()
    @customFields.find('input, select').prop('disabled', false)

  hideCustom: ->
    @customFields.hide()
    @customFields.find('input, select').prop('disabled', true)

  updateClosedState: (checkbox) ->
    times = checkbox.closest('.day').find('.open-time select, .close-time select')
    if checkbox.is(':checked')
      times.hide().prop('disabled', true)
    else
      times.show().prop('disabled', false)

  bindEvents: ->
    # Whenever the template selector changes we need to update the state of the UI
    @selector.change (event) =>
      @updateCustomState()

    # Whenever changing closed state we need to hide/show the time fields
    @customFields.on 'change', 'input[name*=destroy]', (event) =>
      @updateClosedState($(event.target))

