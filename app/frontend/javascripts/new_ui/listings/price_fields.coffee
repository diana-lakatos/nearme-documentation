# Wrapper for the price fields - daily_price, weekly_price and monthly_price.
#
module.exports = class PriceFields

  constructor: (container) ->
    @container = $(container)
    @enablingPriceCheckboxes = @container.find('.price-options input[type=checkbox]')
    @freeCheckbox = @container.find('input[data-action-free-booking]')
    @inputWrapper = @container.find('.price-options')
    @bookingTypeInput = $('input[data-booking-type]')
    @priceFields  = @container.find('input[data-price-field]')
    @dailyBookingField = @container.find('[data-action-daily-booking]')
    @subscriptionBookingField = @container.find('[data-action-subscription-booking]')
    @hourlyField = @container.find('[data-action-hourly-booking]')
    @dailyFields ||= => @container.find('.price-options input[data-action-daily-booking-trigger]:checked')
    @subscriptionFields ||= => @container.find('.price-options input[data-action-subscription-booking-trigger]:checked')
    @defineDayRadios = @container.find('input[name="define_day"]')
    @bindEvents()
    @enablingPriceCheckboxes.trigger('change') if @bookingTypeInput.val() != 'schedule'

  show: ->
    @inputWrapper.show()
    @inputWrapper.find('input.hide-disabled:disabled').removeClass('hide-disabled').prop('disabled', false)

  hide: ->
    @inputWrapper.hide()
    @inputWrapper.find('input:not(:disabled)').addClass('hide-disabled').prop('disabled', true)

  bindEvents: ->
    @container.closest('form').on 'submit', (event) =>
      # this is related to image uploading prevening form submission when upload is in progress
      # having this here is less than optimal but I don't have better idea on how to decouple these modules better
      # it should probably by tied in into client validation if we ever get to implement it
      return if $(event.target).data('processing')

      @inputWrapper.find('input[readonly]').prop('disabled', true)
      if @bookingTypeInput.val() == 'regular'
        if @subscriptionBookingField.val() == 'true'
          @bookingTypeInput.val('subscription')
        else if @container.find('input[name="define_day"]:checked').val().length > 0
          @bookingTypeInput.val(@container.find('input[name="define_day"]:checked').val())

    @enablingPriceCheckboxes.change (event) =>
      checkbox = $(event.target)
      if checkbox.is(':checked')
        if checkbox.data('action-subscription-booking-trigger')
          @dailyFields().prop('checked', false).trigger('change')
          @hourlyField.prop('checked', false).trigger('change') if @hourlyField.is(':checked')
        else
          @subscriptionFields().prop('checked', false).trigger('change')

      @dailyBookingField.val(@dailyFields().length > 0)
      @subscriptionBookingField.val(@subscriptionFields().length > 0)
      checkbox.parents(".row").find('input[data-price-field]').attr('readonly', !checkbox.is(':checked'))
      if checkbox.data('booking-type-override') && checkbox.is(':checked')
        @bookingTypeInput.val(checkbox.data('booking-type-override')).trigger('change')
      else
        @bookingTypeInput.val('regular').trigger('change')

      # Free enabled if all prices are disabled
      @freeCheckbox.prop('checked', !@enablingPriceCheckboxes.is(':checked'))

    @freeCheckbox.click (event) =>
      @enablingPriceCheckboxes.prop('checked', !@freeCheckbox.is(':checked'))
      @enablingPriceCheckboxes.trigger('change')

    @priceFields.on 'click', (event) =>
      checkbox = $(event.target).parents(".row").find('input[type="checkbox"]')
      checkbox.prop('checked', true)
      checkbox.trigger('change')

    @priceFields.on 'blur', (event) =>
      if $(event.target).val()==''
        checkbox = $(event.target).parents(".row").find('input[type="checkbox"]')
        checkbox.prop('checked', false)
        checkbox.trigger('change')

    @priceFields.on 'change', (event) =>
      price = $(event.target)
      price.val(price.val().replace(/[^0-9\.]/, ""))

    @defineDayRadios.on 'change', (event) =>
      @bookingTypeInput.val(event.target.value)
