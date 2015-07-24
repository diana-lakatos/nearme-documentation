class @PaymentController

  constructor: (@container) ->
    @totalPriceContainer = @container.find('[data-total-price]')
    @totalPriceValue = parseFloat(@totalPriceContainer.html())

    @serviceFeeRow = @container.find('[data-service-fee]').parents('tr')
    @serviceFeeValue = parseFloat(@container.find('[data-service-fee]').html())
    @paymentOptions = @container.find(':radio')
    @manualRadio = @container.find(":radio[value='manual']")
    @paypalButton = @container.find("#paypal-button")
    @creditCardInputs = @container.find("#credit-card input")
    @bindEvents()

  bindEvents: =>
    @container.find('[data-upload-document]').on 'click', (e) ->
      $(@).closest('[data-upload]').find('input[type=file]').click()

    @container.find('input[type=file]').on 'change', (e) ->
      span = $(@).closest('[data-upload]').find('[data-file-name]')
      fileName = $(@).val().split(/(\\|\/)/g).pop()
      span.html(fileName)

    @container.find('[data-additional-charges]').on 'change', (e) =>
      target = $(e.target)
      charge_price = parseFloat(target.closest('[data-additional-charge-wrapper]').find('[data-additional-charge-price]').html())
      if target.is(':checked')
        new_price = @totalPriceValue + charge_price
      else
        new_price = @totalPriceValue
      @totalPriceContainer.html(new_price.toFixed(2))

    @paymentOptions.on 'change', (e) =>
      target = $(e.target)
      @hideServiceFee(target)

    @hideServiceFee(@manualRadio)

    @paypalButton.on "click", (e) =>
      @container.find('#order_payment_method_nonce').prop('checked',true)

    @creditCardInputs.on "focus", (e) =>
      @container.find('#order_payment_method_credit_card').prop('checked',true)

  hideServiceFee: (target) =>
    if target.is(':checked') && target.val() == 'manual'
      @totalPriceContainer.html((@totalPriceValue - @serviceFeeValue).toFixed(2))
      @serviceFeeRow.hide()
    else
      @serviceFeeRow.show()
      @totalPriceContainer.html(@totalPriceValue.toFixed(2))

