const RADIO_SELECTOR = '[data-payment-method-radio]';
const TOGGLE_SELECTOR = '[data-toggle="collapse"]';

const PaymentsAccordion = () => {
  $('.accordion').on('click', TOGGLE_SELECTOR, (event) => {
    event.preventDefault();

    const $label = $(event.currentTarget);

    const $currentRadio = $label.siblings(RADIO_SELECTOR);
    const currentValue = $currentRadio.attr('checked'); // Lets operate on existence of html attribute, its more reliable than other checks
    const $allRadios = $label.closest('.accordion').find(RADIO_SELECTOR);

    $allRadios.removeAttr('checked', false); // Reset all radio buttons to collapsed
    $currentRadio.attr('checked', !currentValue); // Expand the one we are interested in
  });
};

module.exports = PaymentsAccordion;
