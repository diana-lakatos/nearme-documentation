require('jquery.payment');

const CCFormatter = () => {
  $('input[data-card-number]').payment('formatCardNumber');
  $('input[data-card-code]').payment('formatCardCVC');
};

module.exports = CCFormatter;
