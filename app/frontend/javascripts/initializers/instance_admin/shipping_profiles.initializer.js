$(document).on('init:shippingprofiles.nearme', function(event, profile_add_success) {
  require.ensure('../../sections/dashboard/shipping_profiles', function(require) {
    var ShippingProfiles = require('../../sections/dashboard/shipping_profiles');
    return new ShippingProfiles('.profiles_shipping_category_form', profile_add_success);
  });
});
