const CREDIT_CARD_SWITCHER_SELECTOR = '.payment-source-option-select, .nm-new-credit-card-form';
const $newCreditCardForm = () => {
  return $('body').find('.nm-credit-card-option-select, .payment-source-form');
};
const $creditCardSwitcher = () => {
  return $('body').find(CREDIT_CARD_SWITCHER_SELECTOR);
};
const $formFields = () => {
  return $newCreditCardForm().find('select, input');
};

class NewCreditCardFormToggle {
  constructor() {
    this._initialize();
  }

  _initialize() {
    /*
      Need to duplicate this initialization part with initial value because firefox ignores trigger on body for some reason
    */
    var that = this;
    $creditCardSwitcher().find('input:checked').each(function() {
      that.update(this);
    });
    this._attachEventHandlers();

    $newCreditCardForm().data('NewCreditCardFormToggleInitialized', true);
    console.log('NewCreditCardFormToggle :: Initialized');
  }

  _attachEventHandlers() {
    $('body').on('change', CREDIT_CARD_SWITCHER_SELECTOR, event => {
      this.update(
        event.target
      ); /* event.target is pointing to changed input, not div from selector */
    });
  }

  update(checkbox) {
    var $checkbox = $(checkbox);
    var $checboxFieldset = $checkbox.parents('fieldset');

    console.log('NewCreditCardFormToggle value: ', $checkbox.val());

    const showOrHide = $checkbox.val() === 'new_credit_card' || $checkbox.val() == 'new_ach';

    $checboxFieldset
      .find('.nm-credit-card-option-select, .payment-source-form')
      .toggleClass('hidden', !showOrHide);
    // Hide/show new cc form
    $formFields().each(
      () => $(this).attr('disabled', showOrHide)
    ); // Disable/enable inputs/selects inside of it
  }
}

module.exports = NewCreditCardFormToggle;
