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
      checked_charges = []
      @container.find("[data-additional-charge-wrapper]").each -> 
        if $(this).find("input:checked").length > 0
          checked_charges.push(parseFloat($(this).find('[data-additional-charge-price]').html()))

      charge_price = _.reduce(checked_charges, ((memo, num) -> memo + num), 0)

      new_price = @totalPriceValue + charge_price
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

    @paypalButton.on "click", (e) =>
      @container.find('#order_payment_method_nonce').prop('checked',true)

    @creditCardInputs.on "focus", (e) =>
      @container.find('#order_payment_method_credit_card').prop('checked',true)
