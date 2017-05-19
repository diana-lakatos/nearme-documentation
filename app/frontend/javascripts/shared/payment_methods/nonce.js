/* global braintree */
/* global braintree_client_token */

class PaymentMethodNonce {
  constructor(container) {
    this.form = $('#checkout-form, #new_payment');
    this._ui = {};
    this._ui.container = container;

    var that = this;

    if (!window.braintree) {
      let s = document.createElement('script');
      s.src = 'https://js.braintreegateway.com/v2/braintree.js';
      s.addEventListener('load', function() {
        that._bindEvents();
      });
      document.head.appendChild(s);
    } else {
      that._bindEvents();
    }
  }

  _bindEvents() {
    console.log('PaymentMethodNonce :: Binding events');

    var $form = $(this.form), that = this;

    var payPalSet = false;

    if ($('#braintree-paypal-button').size() == 0) {
      braintree.setup(braintree_client_token, 'paypal', {
        container: 'paypal-button',
        paymentMethodNonceInputField: $('#paypal-nonce'),
        onPaymentMethodReceived: function(payload) {
          $('#paypal-email').val(payload.details.email);
          payPalSet = true;
        },
        onCancelled: function() {
          if ($('#paypal-button').parents('.accordion-body').hasClass('in')) {
            payPalSet = false;
          }
        }
      });
    }

    $form.submit(function() {
      if (payPalSet) {
        return true;
      } else {
        $(that._ui.container).find('.has-error').text('First connect your PayPal account.');
        return false;
      }
    });
  }
}
module.exports = PaymentMethodNonce;
