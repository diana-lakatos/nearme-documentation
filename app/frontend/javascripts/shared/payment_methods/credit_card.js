/* global Stripe */

class PaymentMethodCreditCard {

  constructor(container) {
    this.form = $('#checkout-form, #new_payment');
    this._ui = {};
    this._ui.container = container;

    this._publishableToken = this.form.find('.nm-credit-card-fields').data('publishable');
    if (this._ui.container.dataset.initialised) {
      return;
    }

    this._ui.container.dataset.initialised = true;

    this._ui.newCreditCard = container.querySelector('.nm-new-credit-card-form');
    this._ui.creditCardSwitcher = container.querySelector('.nm-credit-card-option-select');

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
    Array.prototype.forEach.call(this._ui.creditCardSwitcher.querySelectorAll('input[type=radio]'), (el)=>{
      el.addEventListener('change', (event) => this._toggleByValue(event.target.value));
    });
    this._submitFormHandler();
    this._bindFieldValidation();
  }

  _toggleByValue(value) {
    if (value === 'custom') {
      this._ui.newCreditCard.classList.remove('hidden');
      this._submitFormHandler();
      return;
    }
    this._ui.newCreditCard.classList.add('hidden');
  }

  _init(){
    let current = this._ui.creditCardSwitcher.querySelector('input[checked]');
    if (current) {
      this._toggleByValue(current.value);
    }
  }

  _submitFormHandler(){
    var $form = $(this.form), that = this;
    $form.unbind('submit').submit(function(event) {
      event.stopPropagation();
      event.preventDefault();

      if ($form.find('.nm-new-credit-card-form:visible').length > 0) {
        if (that._validateForm($form)) {
          that._showLoader();
          if (that._publishableToken.length > 0) {
            try {
              Stripe.setPublishableKey(that._publishableToken);
              Stripe.card.createToken($form, that._stripeResponseHandler.bind(that));
            }
            catch(err) {
              if (err) {
                that._hideLoader();
              }
            }
          } else {
            that._submitCreditCardForm().call(that);
          }
        }
      } else {
        that._submitCreditCardForm().call(that);
        $form.find('[data-disable-with]').prop('disabled', true);
      }

      // Prevent the form from being submitted:
      return false;
    });
  }

  _validateForm(form) {

    var valid =  true, that = this;

    $(this.form).find('.errors').html('');

    valid = this._validateField(form.find('[data-stripe="number"]'), this._presenceValidator) && this._validateField(form.find('[data-stripe="number"]'), $.payment.validateCardNumber) && valid;

    valid = this._validateField(form.find('[data-stripe="cvc"]'), this._presenceValidator) && this._validateField(form.find('[data-stripe="cvc"]'), $.payment.validateCardCVC) && valid;

    $.each(['exp_month', 'exp_year', 'last_name', 'first_name'],  function(index, field){
      valid = that._validateField(form.find('[data-stripe="' + field + '"]'), that._presenceValidator) && valid;
    });

    return valid;
  }

  _validateField(field, validator) {
    if (!validator(field.val())) {
      field.parents('.control-group, .form-group').addClass('error has-error');
      field.parents('.control-group, .form-group').find('.error-block').remove();
      field.parents('.control-group, .form-group').append('<p class="error-block">' + this._validationMessage(validator) +'</p>');
      return false;
    } else {
      field.parents('.control-group, .form-group').removeClass('error has-error');
      field.parents('.control-group, .form-group').find('.error-block').remove();

      return true;
    }
  }

  _bindFieldValidation() {
    var $form = $(this.form), that = this, valid = true;
    $form.find('[data-stripe]').change(function(event){
      valid = that._validateField($(event.target), that._presenceValidator);
      if ( $(event.target).data('stripe') == 'number') {
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
    this._hideLoader();
  }

  _showLoader(){
    $('.spinner-overlay').show();
  }

  _hideLoader(){
    $('.spinner-overlay').hide();
  }

  _submitCreditCardForm() {
    var $form = $('#checkout-form, #new_payment'), that = this;

    if ($form.parents('.dialog__content').length > 0) {
      $.ajax({
        url: $form.attr('action'),
        method: 'POST',
        dataType: 'json',
        data: $form.serialize()
      }).done(that._successResponse);

    } else {
      // Submit the form:
      $form.get(0).submit();
    }
  }

  _stripeResponseHandler(status, response) {
    // Grab the form:
    var $form = $('#checkout-form, #new_payment');

    if (response.error) { // Problem!
        // Show the errors on the form:
      $form.find('.errors').eq(0).html('<p class="error-block">' + response.error.message + '</p>');
      this._hideLoader();


    } else { // Token was created!

      // Get the token ID:
      var token = response.id;

      // NOTE currently we need to send CC data to the server
      // we should reverse the flow - first store card then authorize
      //
      // Prevent from sending Credit Card data to the server
      // $form.find('[data-stripe]').removeAttr('name')

      // Insert the token ID into the form so it gets submitted to the server:
      $form.append($('<input type="hidden" name="order[payment_attributes][credit_card_attributes][credit_card_token]">').val(token));

      this._submitCreditCardForm.call(this);

    }
  }
}

module.exports = PaymentMethodCreditCard;

