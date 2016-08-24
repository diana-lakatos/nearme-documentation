
module.exports = class PaymentModalController
  constructor: (@container) ->
    @paymentForm = @container.find("form#new_payment")
    @bindEvents()

  bindEvents: ->
    @ajaxForm()

  ajaxForm: ->
    @paymentForm.on "submit", (e) =>
      e.preventDefault()
      $.ajax
        url: @paymentForm.attr('action')
        method: 'POST'
        data: @paymentForm.serialize()
        success: (response) =>
          if response.saved
            window.location.replace(@paymentForm.attr('data-redirect-to'))
          else
            @container.find('.dialog__content').html(response.html)

      return false
