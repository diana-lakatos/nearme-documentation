CHECKBOX_HTML = "<span class='checkbox-icon-outer'><span class='checkbox-icon-inner'></span></span>"
RADIO_HTML = "<span class='radio-icon-outer'><span class='radio-icon-inner'></span></span>"

module.exports = class CustomInputs
  constructor: (context = 'body') ->
    @context = $(context)
    @body = $('body')

    if !@body.data('customInputsInitialized')
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

    @body.on 'click.customInputs.nearme', '.checkbox-icon-outer, .radio-icon-outer', (event) =>
      label = $(event.target).next('label')
      input = $(event.target).find('input[type="checkbox"]:not(:disabled), input[type="radio"]:not(:disabled)')

      label.trigger('click')
      input.prop('checked', !input.prop('checked')).triggerHandler('change')

      @updateControls()

  updateControls: =>
    @context.find('.checkbox input[type="checkbox"], .radio input[type="radio"]').each (index, el) ->
      el = $(el)
      el.parents('.checkbox, .radio')
        .toggleClass('checked', el.is(':checked'))
        .toggleClass('disabled', el.is(':disabled'))
