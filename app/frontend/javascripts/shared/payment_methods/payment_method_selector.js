const PaymentMethodCreditCard = require('credit_card');
const PaymentMethodAch = require('ach');

class PaymentMethodSelector {

  constructor(container) {
    this._ui = {};
    this._ui.container = container;
    this._ui.payment_methods = container;

    Array.prototype.forEach.call(this._ui.container.querySelectorAll('a[data-payment-method-link]'), (el) => {
      el.addEventListener('click', (event) => this._switchPaymentMethod(event.target));
    });

    this._switchPaymentMethod(this._ui.container.querySelector('.accordion-heading input:checked').previousElementSibling);
  }

  _switchPaymentMethod(element) {
    element.nextElementSibling.checked = true;
    this._ui.currentPaymentMethodContainer = this._ui.container.querySelector(element.dataset.target);
    var selectedPaymentMethod = this._ui.currentPaymentMethodContainer.dataset.paymentMethodType;
    if (this.paymentMethodProcessor != undefined) {
      var $form = $('#checkout-form, #new_payment');
      $form.unbind('submit');
      this.lastActiveFieldset.disabled = true;
    }
    var paymentMethodProcessors = {
      'credit_card': PaymentMethodCreditCard,
      'ach': PaymentMethodAch
    };

    this.lastActiveFieldset = this._ui.currentPaymentMethodContainer.querySelector('fieldset');

    if (paymentMethodProcessors[selectedPaymentMethod]) {
      this.paymentMethodProcessor = new paymentMethodProcessors[selectedPaymentMethod](this._ui.currentPaymentMethodContainer);
    } else {
      this._ui.currentPaymentMethodContainer.querySelector('fieldset').disabled = false;
    }
  }
}

module.exports = PaymentMethodSelector;
