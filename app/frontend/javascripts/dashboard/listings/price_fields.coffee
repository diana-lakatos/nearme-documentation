# Wrapper for the price fields - daily_price, weekly_price and monthly_price.
#
module.exports = class PriceFields

  constructor: (container) ->
    @container = $(container)
    @enablingPriceCheckboxes = @container.find('.price-options input[data-price-enabler]')
    @freeCheckboxes = @container.find('input[data-free-booking]')
    @inputWrapper = @container.find('.price-options')
    @priceFields  = @container.find('input[data-price-field]')
    @currencySelect = @container.closest('form').find('select[data-currency-symbols]')
    @bindEvents()
    @enablingPriceCheckboxes.trigger('change')

  show: ->
    @inputWrapper.show()
    @inputWrapper.find('input.hide-disabled:disabled').removeClass('hide-disabled').prop('disabled', false)

  hide: ->
    @inputWrapper.hide()
    @inputWrapper.find('input:not(:disabled)').addClass('hide-disabled').prop('disabled', true)

  bindEvents: ->
    @container.closest('form').on 'submit', (event) ->
      # this is related to image uploading prevening form submission when upload is in progress
      # having this here is less than optimal but I don't have better idea on how to decouple these modules better
      # it should probably by tied in into client validation if we ever get to implement it
      return if $(event.target).data('processing')

    @enablingPriceCheckboxes.change (event) =>
      checkbox = $(event.target)
      free_booking_switch = $(event.target).parents(".row").find('input[data-free-booking]')
      $(event.target).parents(".row").find('input[id$=_destroy]').val(!checkbox.is(':checked'))
      if free_booking_switch.is(':checked')
        @changePriceState(checkbox, true)
      else
        @changePriceState(checkbox, !checkbox.is(':checked'))
      if !checkbox.is(':checked')
        free_booking_switch.prop('checked', false)

    @freeCheckboxes.click (event) =>
      checkbox = $(event.target)
      @changePriceState(checkbox, checkbox.is(':checked'))
      if checkbox.is(':checked')
        $(event.target).parents(".row").find('input[data-price-enabler]').prop('checked', true).trigger('change')

    @priceFields.on 'click', (event) =>
      $(event.target).parents(".row").find('input[data-free-booking]').prop('checked', false)
      if $(event.target).parents(".row").find('input[data-price-enabler]').length > 0
        $(event.target).parents(".row").find('input[data-price-enabler]').prop('checked', true).trigger('change')
      else
        @changePriceState($(event.target), false)

    @priceFields.on 'blur', (event) ->
      if $(event.target).val() == '' || $(event.target).val()=='0.00'
        price_enabler = $(event.target).parents(".row").find('input[data-price-enabler]')
        if price_enabler.length > 0
          price_enabler.prop('checked', false).trigger('change')

    @priceFields.on 'change', (event) ->
      price = $(event.target)
      price.val(price.val().replace(/[^0-9\.]/, ""))

    @currencySelect.on 'change', (event) =>
      value = $(event.target).val()
      symbols = $(event.target).data('currency-symbols')
      if value and symbols[value]
        @priceFields.closest('.input-group').find('.input-group-addon').html(symbols[value])


  changePriceState: (target, state) ->
    target.parents(".row").find('input[data-price-field]').attr('readonly', state)

