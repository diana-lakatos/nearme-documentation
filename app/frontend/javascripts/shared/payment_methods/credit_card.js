/* global Stripe */
require('jquery.payment');

const Loader = require('./modules/loader');

class PaymentMethodCreditCard {

  constructor(container) {
    console.log('PaymentMethodCreditCard :: Initializing... container: ', container);
    this.form = $('#checkout-form, #new_payment');
    this._ui = {};
    this._ui.container = container;
    this._ui.container.querySelector('fieldset').disabled = false;

    if (this._ui.container.querySelectorAll('input[type=radio]:checked').length == 0) {
      $(this._ui.container.querySelector('input[type=radio]')).click();
      this._ui.container.querySelector('input[type=radio]').checked = true;
    }

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

    $form.unbind('submit').submit(function(event) {
      console.log('PaymentMethodCreditCard :: Binding events: $form.submit');

      event.stopPropagation();
      event.preventDefault();

      var CCFormVisible = $(that._ui.container).find('.payment-source-form.hidden').size() === 0;

      if (CCFormVisible) {
        if (that._validateForm($form)) {
          Loader.show();
          if (that._publishableToken.length > 0) {
            try {
              Stripe.setPublishableKey(that._publishableToken);
              Stripe.card.createToken($form, that._stripeResponseHandler.bind(that));
            } catch (err) {
              if (err) {
                Loader.hide();
              }
            }
          } else {
            that._submitCheckoutForm.call(that);
          }
        }
      } else {
        that._submitCheckoutForm.call(that);
        $form.find('[data-disable-with]').prop('disabled', true);
      }
    });

    return false;
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

  _successResponse(response) {
    var $form = $('#checkout-form, #new_payment');
    if (response.saved || response.redirect) {
      const redirectUrl = $form.attr('data-redirect-to') || response.redirect;
      if (redirectUrl) {
        console.log('PaymentMethodCreditCard :: Form submitted. Redirecting to ', redirectUrl);
        window.location.replace(redirectUrl);
      } else {
        console.log('PaymentMethodCreditCard :: Form submitted. Reloading...');
        window.location.reload();
      }
    } else {
      console.log('PaymentMethodCreditCard :: Form submitted. Updating content');
      $('.dialog__content').html(response.html);
    }
  }

  _submitCheckoutForm() {
    var $form = $('#checkout-form, #new_payment'),
      that = this;

    // Send form via ajax if its in a modalbox (ie. when accepting offer in UOT)
    if ($form.parents('.dialog__content').length > 0) {
      console.log('PaymentMethodCreditCard :: Form submitted. Submitting checkout form using AJAX. Data: ', $form.serialize());

      $.ajax({
        url: $form.attr('action'),
        method: 'POST',
        dataType: 'json',
        data: $form.serialize()
      })
        .done(that._successResponse)
        .always(Loader.hide);

    } else {
      console.log('PaymentMethodCreditCard :: Submitting checkout form.');

      // Submit form while going through standard checkout process
      $form.get(0).submit();
    }
  }

  _updateCCToken($form, token) {
    const $input = $('<input type="hidden" name="order[payment_attributes][credit_card_attributes][credit_card_token]">');
    return $form.append($input.val(token));
  }

  _stripeResponseHandler(status, response) {
    if (response.error) {
      console.log('PaymentMethodCreditCard :: Stripe :: Responded with errors: ', response.error.message);
      $(this._ui.container).find('.has-error').text(response.error.message);

      Loader.hide();
    } else { // Token was created!

      // Get the token ID:
      var token = response.id;
      var $form = $('#checkout-form, #new_payment');

      console.log('PaymentMethodCreditCard :: Stripe :: Received token: ', token);
      // Insert the token ID into the form so it gets submitted to the server:
      this._updateCCToken($form, token);

      this._submitCheckoutForm.call(this);
    }
  }
}

module.exports = PaymentMethodCreditCard;
