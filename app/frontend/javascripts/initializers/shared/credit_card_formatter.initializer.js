$(document).on('init:creditcardform.nearme', () => {
  require.ensure('../../shared/credit_card_formatter.js', (require) => {
    const CCFormatter = require('../../shared/credit_card_formatter.js');
    new CCFormatter();
  });
});

if ($('input[data-card-number], input[data-card-code]').length > 0) {
  $(document).trigger('init:creditcardform.nearme');
}
