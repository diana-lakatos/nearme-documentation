var els = $('[data-location-field]');
if (els.length > 0) {
  require.ensure('../../dashboard/listings/location_field', function(require) {
    var LocationField = require('../../dashboard/listings/location_field');
    els.each(function() {
      return new LocationField(this);
    });
  });
}
