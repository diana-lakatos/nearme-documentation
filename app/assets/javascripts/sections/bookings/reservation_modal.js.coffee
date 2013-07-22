class Bookings.ReservationModal extends @ModalForm

  constructor: (@container) ->
    @serviceFeeLine = @container.find('.service-fee-line')
    @totalCostLine = @container.find('.total-cost-line')

    @paymentMethodCreditCard = @container.find('input#payment_method_credit_card')
    @creditCardFields  = @container.find('#credit_card_fields')
    @creditCardNumber  = @container.find('#card_number')
    @creditCardExpires = @container.find('#card_expires')
    @creditCardCode    = @container.find('#card_code')

    super(@container, @container)
    @hideShowCreditCardFields()

  bindEvents: ->
    @container.find('input[name*=payment_method]').on 'change', =>
      @hideShowCreditCardFields()
      @toggleServiceFee()

    @formatCreditCardFields()

  formatCreditCardFields: ->
    @creditCardNumber.payment('formatCardNumber')
    @creditCardExpires.payment('formatCardExpiry')
    @creditCardCode.payment('formatCardCVC')

  hideShowCreditCardFields: ->
    if @paymentMethodCreditCard.is(':checked')
      @creditCardFields.show()
    else
      @creditCardFields.hide()

  toggleServiceFee: ->
    if @paymentMethodCreditCard.is(':checked')
      @serviceFeeLine.show()
      @totalCostLine.find('.total-amount').text(@totalCostLine.data('total'))
    else
      @serviceFeeLine.hide()
      @totalCostLine.find('.total-amount').text(@totalCostLine.data('subtotal'))

