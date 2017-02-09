
module.exports = class PaymentModalController
  constructor: (@container) ->
    @paymentForm = @container.find("form#new_payment")
    @bindEvents()

  bindEvents: ->
    console.log('PaymentModalController :: Binding events')
    @ajaxForm()

  ajaxForm: ->
    @paymentForm.on "submit", (e) =>
      e.preventDefault()
      $.ajax
        url: @paymentForm.attr('action')
        method: 'POST'
        dataType: 'json',
        data: @paymentForm.serialize()
        success: (response) =>
          if response.saved
            console.log('PaymentModalController :: Form submitted. Redirecting to ', @paymentForm.attr('data-redirect-to'))
            window.location.replace(@paymentForm.attr('data-redirect-to'))
          else
            console.log('PaymentModalController :: Form submitted. Updating dialog content.')
            @container.find('.dialog__content').html(response.html)

      return false
