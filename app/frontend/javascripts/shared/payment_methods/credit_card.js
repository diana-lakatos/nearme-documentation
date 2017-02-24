/* global Stripe */
require('jquery.payment');

const Loader = require('./modules/loader');

class PaymentMethodCreditCard {

  constructor(container) {
    console.log('PaymentMethodCreditCard :: Initializing... container: ', container);
    this.form = $('#checkout-form, #new_payment');
    this._ui = {};
    this._ui.container = container;

    this._publishableToken = this.form.find('.nm-credit-card-fields').data('publishable');

    var that = this;

    if (!window.Stripe) {
      let s = document.createElement('script');
      s.src = 'https://js.stripe.com/v2/';
      s.addEventListener('load', function() {
        that._bindEvents();
      });
      document.head.appendChild(s);
    } else {
      that._bindEvents();
    }
  }

  _bindEvents() {
    console.log('PaymentMethodCreditCard :: Binding events');
    this._submitFormHandler();
    this._bindFieldValidation();
    $(document).trigger('init:creditcardform.nearme');
  }

  _submitFormHandler() {
    var $form = $(this.form),
      that = this;

    $form.submit(function() {

      var CCFormVisible = $(that._ui.container).find('.payment-source-form.hidden').size() === 0;
      console.log('PaymentMethodCreditCard :: Binding events: $form.submit', CCFormVisible);

      if (CCFormVisible) {
        if (that._validateForm($form)) {
          Loader.show();
          if (that._publishableToken.length > 0) {
            try {
              Stripe.setPublishableKey(that._publishableToken);
              Stripe.card.createToken($form, that._stripeResponseHandler.bind(that));
              return false;
            } catch (err) {
              if (err) {
                Loader.hide();
                return false;
              }
            }
          }
        } else {
          return false;
        }
      } else {
        $form.find('[data-disable-with]').prop('disabled', true);
      }
    });

    return true;
  }

  _validateForm(form) {
    var valid = true,
      that = this;

    $(this.form).find('.errors').html('');

    valid = this._validateField(form.find('[data-stripe="number"]'), this._presenceValidator) && this._validateField(form.find('[data-stripe="number"]'), $.payment.validateCardNumber) && valid;
    valid = this._validateField(form.find('[data-stripe="cvc"]'), this._presenceValidator) && this._validateField(form.find('[data-stripe="cvc"]'), $.payment.validateCardCVC) && valid;

    $.each(['exp_month', 'exp_year', 'last_name', 'first_name'], function(index, field) {
      valid = that._validateField(form.find('[data-stripe="' + field + '"]'), that._presenceValidator) && valid;
    });

    return valid;
  }

  _validateField(field, validator) {
    if (!validator(field.val())) {
      field.parents('.control-group, .form-group')
        .addClass('error has-error')
        .find('.error-block').remove()
        .end() // append to `parents()`, not .error-block
        .append('<p class="error-block">' + this._validationMessage(validator) + '</p>');

      return false;
    } else {
      field.parents('.control-group, .form-group')
        .removeClass('error has-error')
        .find('.error-block').remove();

      return true;
    }
  }

  _bindFieldValidation() {
    var $form = $(this.form),
      that = this,
      valid = true;

    $(this._ui.container).find('[data-stripe]').change(function(event) {
      valid = that._validateField($(event.target), that._presenceValidator);
      if ($(event.target).data('stripe') == 'number') {
        valid && that._validateField($form.find('[data-stripe="number"]'), $.payment.validateCardNumber);
      }
    });
  }

  _presenceValidator(value) {
    return value.length > 0;
  }

  _validationMessage(validator) {
    if (validator !== this._presenceValidator) {
      return 'is incorrect';
    } else {
      return 'is required';
    }
  }

  _updateCCToken($form, token) {
    $form.find('[data-stripe="number"]').attr('name');
    var $input = $('<input type="hidden">');

    $input = $input.attr('name', $('form').find('[data-stripe="number"]').attr('name').replace('number', 'credit_card_token'));

    $('[data-stripe]').attr('disabled', true);

    return $form.append($input.val(token));
  }

  _stripeResponseHandler(status, response) {
    if (response.error) {
      console.log('PaymentMethodCreditCard :: Stripe :: Responded with errors: ', response.error.message);
      $(this._ui.container).find('.has-error').text(response.error.message);

      Loader.hide();
      return false;
    } else { // Token was created!

      // Get the token ID:
      var token = response.id;
      var $form = $('#checkout-form, #new_payment');

      console.log('PaymentMethodCreditCard :: Stripe :: Received token: ', token);
      // Insert the token ID into the form so it gets submitted to the server:
      this._updateCCToken($form, token);
      $form.get(0).submit();
    }
  }
}

module.exports = PaymentMethodCreditCard;
