# Wrapper for the price fields - daily_price, weekly_price and monthly_price.
#
class @PriceFields

  constructor: (@container) ->
    @enablingPriceCheckboxes = @container.find('input[data-enable-price]')
    @freeCheckbox = @container.find('input[data-free-checkbox]')
    @inputWrapper = @container.find('.price-input-options')

    @bindEvents()
    @enablingPriceCheckboxes.trigger('change')

  show: ->
    @inputWrapper.show()
    @inputWrapper.find('input.hide-disabled:disabled').removeClass('hide-disabled').prop('disabled', false)

  hide: ->
    @inputWrapper.hide()
    @inputWrapper.find('input:not(:disabled)').addClass('hide-disabled').prop('disabled', true)

  bindEvents: ->
    @enablingPriceCheckboxes.change (event) =>
      @toggleEnablingPriceCheckbox($(event.target))
      if $(event.target).is(':checked')
        @freeCheckbox.prop('checked', false)
      else
        if !@enablingPriceCheckboxes.is(':checked')
          @freeCheckbox.prop('checked', true)

    @freeCheckbox.click (event) =>
      @enablingPriceCheckboxes.prop('checked', !@freeCheckbox.is(':checked'))
      @enablingPriceCheckboxes.trigger('change')


  toggleEnablingPriceCheckbox: (element) =>
    element.siblings('input[data-price-input]').attr('disabled', !element.is(':checked'))

