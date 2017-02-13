/* global Stripe */
/* global Plaid */

const plaidOptions = window.plaid_options;

class PaymentMethodAch {

  constructor(container) {
    this.form = $('#checkout-form, #new_payment');

    this._publishableToken = this.form.find('#ach_manual_payment_form').data('publishable');
    this._ui = {};
    this._ui.container = container;
    this._ui.container.querySelector('fieldset').disabled = false;

    if (this._ui.container.querySelectorAll('input[type=radio]:checked').length == 0) {
      $(this._ui.container.querySelector('input[type=radio]')).trigger('click');
      this._ui.container.querySelector('input[type=radio]').checked = true;
    }

    var that = this;

    if (!window.Stripe) {
      let s = document.createElement('script');
      s.src = 'https://js.stripe.com/v2/';
      s.addEventListener('load', function() {
        that._init();
      });
      document.head.appendChild(s);
    } else {
      that._init();
    }

    if (!window.Plaid) {
      let s = document.createElement('script');
      s.src = 'https://cdn.plaid.com/link/stable/link-initialize.js';
      s.addEventListener('load', function() {
        that._setupPlaid();
        that._init();
      });
      document.head.appendChild(s);
    } else {
      that._setupPlaid();
      that._init();
    }
  }

  _bindEvents() {
    console.log('PaymentMethodAch :: Binding events (actually, just calling _submitFormHandler)');
    this._submitFormHandler();
    $(document).trigger('init:creditcardform.nearme');
  }

  _setupPlaid() {
    if (plaidOptions.key.length < 1) {
      return true;
    }

    var linkHandler = Plaid.create({
      env: plaidOptions.env,
      clientName: plaidOptions.name,
      key: plaidOptions.key,
      product: 'auth',
      selectAccount: true,
      onSuccess: function(public_token, metadata) {
        $('#stripe_plaid_public_token').val(public_token);
        $('#stripe_plaid_account_id').val(metadata.account_id);
        $('#plaid_institution').text(plaidOptions.auth_with + metadata.institution.name);
      },
    });

    // Trigger the Link UI
    $('#linkButton').on('click', (event) => {
      event.preventDefault();
      linkHandler.open();
    });
  }

  _submitFormHandler() {
    var $form = $(this.form),
      that = this;

    if (that._publishableToken == undefined) {
      return true;
    }

    $form.unbind('submit').submit(function(event) {
      console.log('PaymentMethodAch :: Submitting form');

      event.stopPropagation();
      event.preventDefault();
      $form = $(event.target);
      Stripe.setPublishableKey(that._publishableToken);
      Stripe.bankAccount.createToken({
        country: $('[data-country]').val(),
        currency: $('[data-currency]').val(),
        routing_number: $('[data-routing-number]').val(),
        account_number: $('[data-account-number]').val(),
        account_holder_name: $('[data-account-holder-name]').val(),
        account_holder_type: $('[data-account-holder-type]').val()
      }, that._stripeResponseHandler.bind(that));
    });

    return false;
  }

  _stripeResponseHandler(status, response) {
    // Grab the form:
    var $form = $('#checkout-form, #new_payment');

    if (response.error) { // Problem!

      // Show the errors on the form:
      $(this._ui.container).find('.has-error').text(response.error.message);
      // $form.find('button').prop('disabled', false); // Re-enable submission
      console.log('PaymentMethodCreditCard :: Stripe :: Responded with errors: ', response.error.message);

    } else { // Token created!

      // Get the token ID:
      var token = response.id;
      console.log('PaymentMethodCreditCard :: Stripe :: Received token: ', token);

      // Insert the token into the form so it gets submitted to the server:
      this._ui.container.querySelector('#stripe_plaid_public_token').value = token;


      // Submit the form:
      $form.get(0).submit();
    }
  }
}

module.exports = PaymentMethodAch;
