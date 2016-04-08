module.exports = class CustomInputs

  constructor: (context = 'body') ->
    @context = $(context)

    @buildElements()
    @bindEvents()
    @updateControls()

  buildElements: ->
    @context.find(".checkbox").each (index, element) =>
      try
        $(element).prepend("<span class='checkbox-icon-outer'><span class='checkbox-icon-inner'></span></span>")
      catch error

    @context.find(".radio").each (index, element) =>
      $(element).prepend("<span class='radio-icon-outer'><span class='radio-icon-inner'></span></span>")

  bindEvents: ->
    body = $(document.body);

    return if body.data('customInputsInitialized')

    body.data('customInputsInitialized', true)
    body.on 'change.customInputs.nearme', ".checkbox, .radio, .checkbox input, .radio input", @updateControls

    body.on 'click.customInputs.nearme', '.checkbox-icon-outer, .radio-icon-outer', (e)=>
      input = $(e.target).closest('.checkbox, .radio').find('input[type="checkbox"], input[type="radio"]')
      input.prop('checked', !input.prop('checked'))
      input.triggerHandler('change')
      @updateControls()

  updateControls: =>
    @context.find('.checkbox input[type="checkbox"], .radio input[type="radio"]').each (index, el)->
      el = $(el)
      container = el.parents('.checkbox, .radio')
      container.toggleClass('checked', el.is(':checked'))
      container.toggleClass('disabled', el.is(':disabled'))
