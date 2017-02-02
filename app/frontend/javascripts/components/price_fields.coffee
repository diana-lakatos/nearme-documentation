# Wrapper for the price fields - daily_price, weekly_price and monthly_price.
#
module.exports = class PriceFields

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
    @container.closest('form').on 'submit', (event) =>
      @inputWrapper.find('input[readonly]').prop('disabled', true)

    @enablingPriceCheckboxes.change (event) =>
      checkbox = $(event.target)
      checkbox.parents(".price-containter").find('input[data-type*=price-input]').attr('readonly', !checkbox.is(':checked'))

      # Free enabled if all prices are disabled
      @freeCheckbox.prop('checked', !@enablingPriceCheckboxes.is(':checked'))

    @freeCheckbox.click (event) =>
      @enablingPriceCheckboxes.prop('checked', !@freeCheckbox.is(':checked'))
      @enablingPriceCheckboxes.trigger('change')

    @priceFields.on 'click', (event) ->
      checkbox = $(event.target).parents(".price-containter").find('label').find('input[data-behavior*=enable-price]')
      checkbox.prop('checked', true)
      checkbox.trigger('change')
      # yeah well.. otherwise IE will think that input is readable, even though we have just changed this...
      $(event.target).select()

    @priceFields.on 'blur', (event) ->
      if $(event.target).val()==''
        checkbox = $(event.target).siblings('label').find('input[data-behavior*=enable-price]')
        checkbox.prop('checked', false)
        checkbox.trigger('change')

    @priceFields.on 'change', (event) ->
      price = $(event.target)
      price.val(price.val().replace(/[^0-9\.]/, ""))
