module.exports = class AvailabilityRules

  constructor: (container) ->
    @container = $(container)
    @selector = @container.find('input[type=radio][name*=availability_template]')
    return unless @selector.length > 0

    @customFields = @container.find('.custom-availability')
    @bindEvents()
    @updateCustomState(@selector)


  updateCustomState: (selector) ->
    if selector.filter(':checked').attr('data-custom-rules')?
      @showCustom(selector)
    else
      @hideCustom(selector)


  showCustom: (selector) ->
    @customFields = selector.closest('.listing-availability').find('.custom-availability')
    @customFields.find('input, select').prop('disabled', false)
    @customFields.find('.disabled').removeClass('disabled')
    @customFields.show()

  hideCustom: (selector)->
    @customFields.hide()
    @customFields.find('input, select').prop('disabled', true)

  bindEvents: ->
    # Whenever the template selector changes we need to update the state of the UI
    @selector.change (event) =>
      @updateCustomState($(event.target))

    @customFields.on 'cocoon:before-remove', (e,fields)->
      parent = $(fields).closest('.nested-container')
      parent.find('.transactable_availability_template_availability_rules__destroy input').val('true')
      parent.hide()
      parent.prependTo(parent.closest('form'))

    @customFields.on 'cocoon:after-insert', (e, insertedItem)=>
      $('html').trigger('timepickers.init.forms', [insertedItem]);
