
module.exports = class PaymentModalController
  constructor: (@container) ->
    @paymentForm = @container.find("form#new_payment")
    @bindEvents()

  bindEvents: ->
    @radioTabs()
    @ajaxForm()

  radioTabs: ->
    new_credit_card_form = @container.find('.new-credit-card-form');
    @container.find('input.radio_buttons').on 'change', (event) ->
      target = $(event.target)
      if target.val() == 'custom'
        new_credit_card_form.show()
      else
        new_credit_card_form.hide()
      return

    $(@container.find('input.radio_buttons:checked')).trigger('change')

  ajaxForm: ->
    @paymentForm.on "submit", (e) =>
      e.preventDefault()
      $.ajax
        url: @paymentForm.attr('action')
        method: 'POST'
        data: @paymentForm.serialize()
        success: (response) =>
          if response.saved
            window.location.replace("/dashboard/company/orders_received")
          else
            @container.html(response.html)
