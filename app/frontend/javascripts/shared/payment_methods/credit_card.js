/* global Stripe */
require('jquery.payment');

const Loader = {
  show: () => { $('.spinner-overlay').show(); },
  hide: () => { $('.spinner-overlay').hide(); }
};

class PaymentMethodCreditCard {

  constructor(container) {
    this.form = $('#checkout-form, #new_payment');
    this._ui = {};
    this._ui.container = container;
    this._ui.container.querySelector('fieldset').disabled = false;

    if (this._ui.container.querySelectorAll('input[type=radio]:checked').length == 0) {
      $(this._ui.container.querySelector('input[type=radio]')).click();
      this._ui.container.querySelector('input[type=radio]').checked = true;
    }

    this._publishableToken = this.form.find('.nm-credit-card-fields').data('publishable');
    this._ui.newCreditCard = this._ui.container.querySelector('.nm-credit-card-option-select, .payment-source-form');
    this._ui.creditCardSwitcher = container.querySelector('.payment-source-option-select, .nm-new-credit-card-form');

    var that = this;

    if (!window.Stripe) {
      let s = document.createElement('script');
      s.src = 'https://js.stripe.com/v2/';
      s.addEventListener('load', function() {
        that._bindEvents();
        that._init();
      });
      document.head.appendChild(s);
    } else {
      that._bindEvents();
      that._init();
    }
  }

  _bindEvents() {
    Array.prototype.forEach.call(this._ui.creditCardSwitcher.querySelectorAll('input[type=radio]'), (el) => {
      el.addEventListener('change', (event) => this._toggleByValue(event.target.value));
    });
    this._submitFormHandler();
    this._bindFieldValidation();
    $(document).trigger('init:creditcardform.nearme');
  }


  _setFormFieldDisabledAttribute(elements, value) {
    Array.prototype.forEach.call(elements, (element) => element.disabled = value);
  }

  _toggleByValue(value) {
    let inputs = this._ui.newCreditCard.querySelectorAll('input');
    let selects = this._ui.newCreditCard.querySelectorAll('select');

    if (value === 'new_credit_card') {
      this._ui.newCreditCard.classList.remove('hidden');

      this._setFormFieldDisabledAttribute(inputs, false);
      this._setFormFieldDisabledAttribute(selects, false);

      return this._submitFormHandler();
    }

    this._ui.newCreditCard.classList.add('hidden');

    this._setFormFieldDisabledAttribute(inputs, true);
    this._setFormFieldDisabledAttribute(selects, false);
  }

  _init() {
    let current = this._ui.creditCardSwitcher.querySelector('input:checked');
    if (current) {
      this._toggleByValue(current.value);
    }
  }

  _submitFormHandler() {
    var $form = $(this.form),
      that = this;

    $form.off('submit').on('submit', (event) => {
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
    if (response.saved) {
      if ($form.attr('data-redirect-to')) {
        window.location.replace($form.attr('data-redirect-to'));
      } else {
        window.location.reload();
      }
    } else {
      $('.dialog__content').html(response.html);
    }
  }

  _submitCheckoutForm() {
    var $form = $('#checkout-form, #new_payment'),
      that = this;

    // Send form via ajax if its in a modalbox (ie. when accepting offer in UOT)
    if ($form.parents('.dialog__content').length > 0) {
      $.ajax({
        url: $form.attr('action'),
        method: 'POST',
        dataType: 'json',
        data: $form.serialize()
      })
      .done(that._successResponse)
      .always(Loader.hide);

    } else {
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
      $(this._ui.container).find('.has-error').text(response.error.message);

      Loader.hide();
    } else { // Token was created!

      // Get the token ID:
      var token = response.id;
      var $form = $('#checkout-form, #new_payment');

      // Insert the token ID into the form so it gets submitted to the server:
      this._updateCCToken($form, token);

      // NOTE currently we need to send CC data to the server
      // we should reverse the flow - first store card then authorize
      //
      // Prevent from sending Credit Card data to the server
      // $form.find('[data-stripe]').removeAttr('name')

      this._submitCheckoutForm.call(this);
    }
  }
}

module.exports = PaymentMethodCreditCard;
