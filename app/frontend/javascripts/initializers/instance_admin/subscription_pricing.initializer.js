var els = $('[data-subscription-unit]');
if (els.length > 0) {
  require.ensure('../../instance_admin/forms/subscription_pricing', function(require) {
    var SubscriptionPricing = require('../../instance_admin/forms/subscription_pricing');
    return new SubscriptionPricing();
  });
}
