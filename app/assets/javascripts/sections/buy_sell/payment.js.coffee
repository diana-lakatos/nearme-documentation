class @PaymentController

  constructor: (@container) ->
    @totalPriceContainer = @container.find('[data-total-price]')
    @totalAmount = $('.summary-line-value.total-amount')
    @cartPrice = $("[data-cart-total]")
    @totalPriceValue = parseFloat(@totalPriceContainer.html() || @cartPrice.html())
    @deliveryPriceContainer = $('.summary-line-value.delivery-amount')

    @paymentOptions = @container.find(':radio')
    @paypalButton = @container.find("#paypal-button")
    @creditCardInputs = @container.find("#credit-card input")
    @bindEvents()

  bindEvents: =>
    @container.find('input[name="reservation_request[delivery_ids]"]').on 'change', (e) =>
      @deliveryPriceContainer.html($(e.target).data('price-formatted'))
      total = parseFloat(@totalAmount.data('total-amount'))
      total += parseFloat($(e.target).data('price'))
      @totalAmount.text(@totalAmount.data('currency-symbol') + total.toFixed(2))

    @container.find('[data-upload-document]').on 'click', (e) ->
      $(@).closest('[data-upload]').find('input[type=file]').click()

    @container.find('input[type=file]').on 'change', (e) ->
      span = $(@).closest('[data-upload]').find('[data-file-name]')
      fileName = $(@).val().split(/(\\|\/)/g).pop()
      span.html(fileName)

    @paypalButton.on "click", (e) =>
      @container.find('#order_payment_method_nonce').prop('checked',true)

    @creditCardInputs.on "focus", (e) =>
      @container.find('#order_payment_method_credit_card').prop('checked',true)

    @container.find('[data-additional-charges]').on 'change', (e) =>
      @count_additional_charges_price()

    @paypalButton.on "click", (e) =>
      @container.find('#order_payment_method_nonce').prop('checked',true)

    @creditCardInputs.on "focus", (e) =>
      @container.find('#order_payment_method_credit_card').prop('checked',true)

    @count_additional_charges_price()

  count_additional_charges_price: () =>
    checked_charges = []
    @container.find("[data-additional-charge-wrapper]").each ->
      if $(this).find("input:checked").length == 0
        checked_charges.push(parseFloat($(this).find('[data-additional-charge-price]').html()))

    @charge_price = _.reduce(checked_charges, ((memo, num) -> memo + num), 0)

    @new_price = @totalPriceValue - @charge_price

    # When toggling optional upsells, or simply on page load, we want to hide the payments section if the new
    # total price is zero because the payment methods in the form will be ignored anyway
    # and instead the free method will be assigned always
    if @new_price > 0
      $('section.checkout-form#credit-card-select').show()
    else
      $('section.checkout-form#credit-card-select').hide()

    @totalPriceContainer.html(@new_price.toFixed(2))
    @cartPrice.html(@new_price.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');)


