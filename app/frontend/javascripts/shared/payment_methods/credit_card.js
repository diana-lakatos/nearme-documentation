class PaymentMethodCreditCard {

    constructor(container){
        this._ui = {};
        this._ui.container = container;

        if (this._ui.container.dataset.initialised) {
            return;
        }

        this._ui.container.dataset.initialised = true;

        this._ui.newCreditCard = container.querySelector('.nm-new-credit-card-form');
        this._ui.creditCardSwitcher = container.querySelector('.nm-credit-card-option-select');

        this._bindEvents();
        this._init();
    }

    _bindEvents() {
        Array.prototype.forEach.call(this._ui.creditCardSwitcher.querySelector('input[type=radio]'), (el)=>{
            el.addEventListener('change', (event) => this._toggleByValue(event.target.value));
        });
    }

    _toggleByValue(value) {
        if (value === 'custom') {
            return this._ui.newCreditCard.classList.remove('hidden');
        }
        this._ui.newCreditCard.classList.add('hidden');
    }

    _init(){
        let current = this._ui.creditCardSwitcher.querySelector('input[checked]');
        if (current) {
            this._toggleByValue(current.value);
        }
    }
}

module.exports = PaymentMethodCreditCard;

