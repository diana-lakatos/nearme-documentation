class @PaymentController

  constructor: (@container) ->
    @bindEvents()
    @totalPrice = @container.find('[data-total-price]')
    @paypalButton = @container.find("#paypal-button")
    @creditCardInputs = @container.find("#credit-card input")

  bindEvents: =>
    @container.find('[data-upload-document]').on 'click', (e) ->
      $(@).closest('[data-upload]').find('input[type=file]').click()

    @container.find('input[type=file]').on 'change', (e) ->
      span = $(@).closest('[data-upload]').find('[data-file-name]')
      fileName = $(@).val().split(/(\\|\/)/g).pop()
      span.html(fileName)

    @container.find('[data-additional-charges]').on 'change', (e) =>
      target = $(e.target)
      current_price = parseFloat(@totalPrice.html())
      charge_price = parseFloat(target.closest('[data-additional-charge-wrapper]').find('[data-additional-charge-price]').html())
      if target.is(':checked')
        new_price = current_price + charge_price
      else
        new_price = current_price
      @totalPrice.html(new_price.toFixed(2))

    @paypalButton.on "click", (e) =>
      @container.find('#order_payment_method_nonce').prop('checked',true)

    @creditCardInputs.on "focus", (e) =>
      @container.find('#order_payment_method_credit_card').prop('checked',true)
