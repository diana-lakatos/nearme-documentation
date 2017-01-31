CHECKBOX_HTML = "<span class='checkbox-icon-outer'><span class='checkbox-icon-inner'></span></span>"
RADIO_HTML = "<span class='radio-icon-outer'><span class='radio-icon-inner'></span></span>"

module.exports = class CustomInputs
  constructor: (context = 'body') ->
    @context = $(context)
    @body = $('body')

    if !@body.data('custom-inputs-initialized')
      @initialize()

  initialize: ->
    @buildElements()
    @bindEvents()
    @updateControls()

    @body.data('custom-inputs-initialized', true);

  buildElements: ->
    @context.find('.checkbox').each (index, element) => $(element).prepend(CHECKBOX_HTML)
    @context.find('.radio').each (index, element) => $(element).prepend(RADIO_HTML)

  bindEvents: ->
    @body.on 'change.customInputs.nearme', '.checkbox, .radio, .checkbox input, .radio input', @updateControls

    @body.on 'click.customInputs.nearme', '.radio-icon-outer', (event) =>
      customInput = $(event.target).closest('.radio')
      input = customInput.find('input[type="radio"]:not(:disabled)')
      label = customInput.find('label')

      label.trigger('click')
      input.triggerHandler('change')

      @updateControls()

    @body.on 'click.customInputs.nearme', '.checkbox-icon-outer', (event) =>
      customInput = $(event.target).closest('.checkbox')
      input = customInput.find('input[type="checkbox"]:not(:disabled)')

      input.prop('checked', !input.prop('checked')).triggerHandler('change')

      @updateControls()

  updateControls: =>
    @context.find('.checkbox input[type="checkbox"], .radio input[type="radio"]').each (index, element) ->
      $this = $(element)

      $this.closest('.checkbox, .radio')
        .toggleClass('checked', $this.is(':checked'))
        .toggleClass('disabled', $this.is(':disabled'))
