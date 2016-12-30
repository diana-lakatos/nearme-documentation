/* global Stripe */
/* global Plaid */

class PaymentMethodAch {

  constructor(container, options) {
    this.form = $('#checkout-form, #new_payment');
    this.__plaid_options = plaid_options

    this._publishableToken = this.form.find('#ach_manual_payment_form').data('publishable');
    this._ui = {};
    this._ui.container = container;
    this._ui.container.querySelector('fieldset').disabled = false;

    if (this._ui.container.querySelectorAll('input[type=radio]:checked').length == 0) {
      $(this._ui.container.querySelector('input[type=radio]')).click();
      this._ui.container.querySelector('input[type=radio]').checked = true;
    }
    this._ui.newCreditCard = this._ui.container.querySelector('.payment-source-form');
    this._ui.creditCardSwitcher = this._ui.container.querySelector('.payment-source-option-select');

    var that = this;

    Array.prototype.forEach.call(this._ui.creditCardSwitcher.querySelectorAll('input[type=radio]'), (el)=>{
      el.addEventListener('change', (event) => this._toggleByValue(event.target.value));
    });

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

  _init(){
    let current = this._ui.creditCardSwitcher.querySelector('input:checked');
    if (current) {
      this._toggleByValue(current.value);
    }
  }

  _toggleByValue(value) {
    if (value === 'new_ach') {
      this._ui.newCreditCard.classList.remove('hidden');
      var inputs = this._ui.newCreditCard.getElementsByTagName("input");
      for (var i = 0; i < inputs.length; i++) {
          inputs[i].disabled = false;
      }
      var selects = this._ui.newCreditCard.getElementsByTagName("select");
      for (var i = 0; i < selects.length; i++) {
          selects[i].disabled = false;
      }

      this._submitFormHandler();
      return;
    }
    this._ui.newCreditCard.classList.add('hidden');
    var inputs = this._ui.newCreditCard.getElementsByTagName("input");
    for (var i = 0; i < inputs.length; i++) {
        inputs[i].disabled = true;
    }
    var selects = this._ui.newCreditCard.getElementsByTagName("select");
    for (var i = 0; i < selects.length; i++) {
        selects[i].selectize
        selects[i].disabled = false;
    }

    var $form = $(this.form), that = this;

    $form.unbind('submit')
  }

  _bindEvents() {
    this._submitFormHandler();
  }

 _setupPlaid(){
    if (this.__plaid_options.key.length < 1 ) {
      return true
    }

    var linkHandler = Plaid.create({
      env: this.__plaid_options.env,
      clientName: this.__plaid_options.name,
      key: this.__plaid_options.key,
      product: 'auth',
      selectAccount: true,
      onSuccess: function(public_token, metadata) {
        $('#stripe_plaid_public_token').val(public_token)
        $('#stripe_plaid_account_id').val(metadata.account_id)
        $('#plaid_institution').text(plaid_options.auth_with + metadata.institution.name)
      },
    });

    // Trigger the Link UI
    var plaidLink = document.getElementById('linkButton');
    if (plaidLink != undefined) {
      plaidLink.onclick = function(event) {
        event.preventDefault()
        linkHandler.open();
      };
    }
  }


  _submitFormHandler(){
    var $form = $(this.form), that = this;

    if (that._publishableToken == undefined) {
      return true
    }

    $form.unbind('submit').submit(function(event) {
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

    // Prevent the form from being submitted:
    return false;
  }

  _stripeResponseHandler(status, response) {

    // Grab the form:
    var $form = $('#checkout-form, #new_payment');

    if (response.error) { // Problem!

      // Show the errors on the form:
      $(this._ui.container).find('.has-error').text(response.error.message);
      // $form.find('button').prop('disabled', false); // Re-enable submission

    } else { // Token created!

      // Get the token ID:
      var token = response.id;

      // Insert the token into the form so it gets submitted to the server:
      this._ui.container.querySelector('#stripe_plaid_public_token').value = token;

      // Submit the form:
      $form.get(0).submit();

    }
  }

}

module.exports = PaymentMethodAch;

