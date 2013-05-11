# Wrapper for the price fields - daily_price, weekly_price and monthly_price.
#
class @PriceFields

  constructor: (@container) ->

    @enablingPriceCheckboxes = @container.find('input[data-enable-price]')
    @freeCheckbox = @container.find('input[data-free-checkbox]')

    @bindEvents()

    @enablingPriceCheckboxes.trigger('change')

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
    element.parent().siblings('input[data-price-input]').attr('disabled', !element.is(':checked'))
