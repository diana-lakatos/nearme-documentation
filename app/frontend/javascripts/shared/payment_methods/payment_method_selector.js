const PaymentMethodCreditCard = require('credit_card');
const PaymentMethodAch = require('ach');
const PaymentMethodNonce = require('nonce');

class PaymentMethodSelector {

  constructor(container) {
    console.log('Bind Events');

    this._ui = {};
    this._ui.container = container;


    this._bindEvents();
  }

  _bindEvents() {
    Array.prototype.forEach.call(this._ui.container.querySelectorAll('[data-payment-method]'), (el) => {
      el.querySelector('[data-payment-method-header]').addEventListener('click', () => this._activatePaymentMethod(el));
    });

    this._activatePaymentMethod(this._ui.container.querySelector('[data-payment-method-active]'));
  }

  _activatePaymentMethod(payment_method_container) {
    this._disablePaymentMethods();

    this._ui.container.querySelector('[data-payment-method-id]').value = payment_method_container.dataset.paymentMethodId;
    this._paymentMethodProcessorsInitializer(payment_method_container);
    payment_method_container.querySelector('fieldset').disabled = false;
    var fieldset = payment_method_container.querySelector('fieldset');
    $(fieldset).show();
  }

  _disablePaymentMethods() {
    var $form = $('#checkout-form, #new_payment');
    $form.unbind('submit');

    Array.prototype.forEach.call(this._ui.container.querySelectorAll('.payment-method'), (el) => {
      var fieldset = el.querySelector('fieldset');
      fieldset.disabled = true;
      $(fieldset).hide();
    });
  }

  _paymentMethodProcessorsInitializer(payment_method_container) {
    if (payment_method_container.dataset.paymentMethodType == undefined) {
      return;
    }

    var processors = {
      'credit_card': PaymentMethodCreditCard,
      'ach': PaymentMethodAch,
      'nonce': PaymentMethodNonce
    };
    if (processors[payment_method_container.dataset.paymentMethodType]) {
      new processors[payment_method_container.dataset.paymentMethodType](payment_method_container);
    }
  }
}

module.exports = PaymentMethodSelector;
