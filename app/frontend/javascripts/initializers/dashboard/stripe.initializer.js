var els = $('form[data-payouts-form]');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/stripe_connect_controller', function(require) {
    var StripeConnectController = require('../../dashboard/controllers/stripe_connect_controller');
    els.each(function() {
      return new StripeConnectController(this);
    });
  });
}
