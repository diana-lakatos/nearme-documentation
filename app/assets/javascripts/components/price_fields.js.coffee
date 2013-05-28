# Wrapper for the price fields - daily_price, weekly_price and monthly_price.
#
class @PriceFields

  constructor: (@container) ->
    @enablingPriceCheckboxes = @container.find('input[data-behavior*=enable-price]')
    @freeCheckbox = @container.find('input[data-behavior*=toggle-free]')
    @inputWrapper = @container.find('.price-input-options')
    @priceFields  = @container.find('input[data-type=price-input]')

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
      checkbox = $(event.target)
      checkbox.siblings('input[data-type*=price-input]').attr('disabled', !checkbox.is(':checked'))

      # Free enabled if all prices are disabled
      @freeCheckbox.prop('checked', !@enablingPriceCheckboxes.is(':checked'))

    @freeCheckbox.click (event) =>
      @enablingPriceCheckboxes.prop('checked', !@freeCheckbox.is(':checked'))
      @enablingPriceCheckboxes.trigger('change')

    @priceFields.on 'change', (event) =>
      price = $(event.target)
      price.val(price.val().replace(/[^0-9\.]/, ""))


