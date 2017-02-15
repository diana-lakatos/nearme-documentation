const CREDIT_CARD_SWITCHER_SELECTOR = '.payment-source-option-select, .nm-new-credit-card-form';
const $newCreditCardForm = () => { return $('body').find('.nm-credit-card-option-select, .payment-source-form'); };
const $creditCardSwitcher = () => { return $('body').find(CREDIT_CARD_SWITCHER_SELECTOR); };
const $formFields = () => { return $newCreditCardForm().find('select, input'); };

class NewCreditCardFormToggle {
  constructor() {
    if (!this._isInitialized()) {
      this._initialize();
    }
  }

  _isInitialized() {
    return $newCreditCardForm().data('NewCreditCardFormToggleInitialized');
  }

  _initialize() {
    /*
      Need to duplicate this initialization part with initial value because firefox ignores trigger on body for some reason
    */
    const initialValue = $creditCardSwitcher().find('input:checked').val();
    this.update(initialValue);
    this._attachEventHandlers();

    $newCreditCardForm().data('NewCreditCardFormToggleInitialized', true);
    console.log('NewCreditCardFormToggle :: Initialized');
  }

  _attachEventHandlers() {
    $('body').on('change', CREDIT_CARD_SWITCHER_SELECTOR, (event) => {
      this.update(event.target.value); /* event.target is pointing to changed input, not div from selector */
    });
  }

  update(value) {
    console.log('NewCreditCardFormToggle value: ', value);

    const showOrHide = value === 'new_credit_card';

    $newCreditCardForm().toggleClass('hidden', !showOrHide); // Hide/show new cc form
    $formFields().each(() => $(this).attr('disabled', showOrHide)); // Disable/enable inputs/selects inside of it
  }
}

module.exports = NewCreditCardFormToggle;
