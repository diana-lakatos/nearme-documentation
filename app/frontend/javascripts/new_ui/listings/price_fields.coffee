# Wrapper for the price fields - daily_price, weekly_price and monthly_price.
#
module.exports = class PriceFields

  constructor: (container) ->
    @container = $(container)
    @enablingPriceCheckboxes = @container.find('.price-options input[data-price-enabler]')
    @freeCheckboxes = @container.find('input[data-free-booking]')
    @inputWrapper = @container.find('.price-options')
    @priceFields  = @container.find('input[data-price-field]')
    @bindEvents()
    @enablingPriceCheckboxes.trigger('change')

  show: ->
    @inputWrapper
      .show()
      .find('input.hide-disabled:disabled')
      .removeClass('hide-disabled')
      .prop('disabled', false)

  hide: ->
    @inputWrapper
      .hide()
      .find('input:not(:disabled)')
      .addClass('hide-disabled')
      .prop('disabled', true)

  bindEvents: ->
    @container.closest('form').on 'submit', (event) =>
      # this is related to image uploading prevening form submission when upload is in progress
      # having this here is less than optimal but I don't have better idea on how to decouple these modules better
      # it should probably by tied in into client validation if we ever get to implement it
      return if $(event.target).data('processing')

    @enablingPriceCheckboxes.change (event) =>
      $checkbox = $(event.target)
      $freeBookingSwitch = $checkbox.parents(".row").find('input[data-free-booking]')
      $checkbox.parents(".row").find('input[id$=_destroy]').val(!$checkbox.is(':checked'))
      if $freeBookingSwitch.is(':checked')
        @changePriceState($checkbox, true)
      else
        @changePriceState($checkbox, !$checkbox.is(':checked'))
      if !$checkbox.is(':checked')
        $freeBookingSwitch.prop('checked', false)

    @freeCheckboxes.click (event) =>
      $checkbox = $(event.target)
      @changePriceState($checkbox, $checkbox.is(':checked'))
      if $checkbox.is(':checked')
        $checkbox.parents(".row").find('input[data-price-enabler]').prop('checked', true).trigger('change')

    @priceFields.on 'click touchstart', (event) =>
      $target = $(event.target)
      $freeBooking = $target.parents(".row").find('input[data-free-booking]')
      $priceEnabler = $target.parents(".row").find('input[data-price-enabler]')

      $freeBooking.prop('checked', false)
      if $priceEnabler.size()
        $priceEnabler.prop('checked', true).trigger('change')
        $target.focus()
      else
        @changePriceState($(event.target), false)

    @priceFields.on 'blur', (event) =>
      if $(event.target).val() == '' || $(event.target).val() == '0.00' # TODO: Rethink '0.00' -- from localization POV to simple '0' !== '0.00'  || '0.0' !== '0.00'
        $priceEnabler = $(event.target).parents(".row").find('input[data-price-enabler]')
        if $priceEnabler.size()
          $priceEnabler.prop('checked', false).trigger('change')

    @priceFields.on 'change', (event) =>
      $price = $(event.target)
      $price.val($price.val().replace(/[^0-9\.]/, ""))

  changePriceState: ($target, state) =>
    $target.parents(".row").find('input[data-price-field]').attr('readonly', state)

