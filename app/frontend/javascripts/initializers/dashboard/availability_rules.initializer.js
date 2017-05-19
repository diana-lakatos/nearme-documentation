var els = $('.listing-availability');
if (els.length > 0) {
  require.ensure('../../dashboard/listings/availability_rules', function(require) {
    var AvailabilityRules = require('../../dashboard/listings/availability_rules');
    els.each(function() {
      return new AvailabilityRules(this);
    });
  });
}
