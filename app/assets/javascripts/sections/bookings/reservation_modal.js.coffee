class Bookings.ReservationModal extends @ModalForm

  constructor: (@container) ->
    super(@container, @container)
    @bindEvents()
    @hideShowCreditCardFields()

  bindEvents: ->
    @container.find('input[name*=payment_method]').on 'change', @hideShowCreditCardFields
    @formatCreditCardFields()

  formatCreditCardFields: ->
    $('#card_number').payment('formatCardNumber')
    $('#card_expires').payment('formatCardExpiry')
    $('#card_code').payment('formatCardCVC')


  hideShowCreditCardFields: ->
    input = $('input#payment_method_credit_card')
    fields = $('#credit_card_fields')

    if input.is(':checked')
      fields.show()
    else
      fields.hide()

