$(document).on('init:shippingprofilescontroller.nearme', function() {
  require.ensure('../../dashboard/controllers/shipping_profiles_controller', function(require) {
    var ShippingProfilesController = require(
      '../../dashboard/controllers/shipping_profiles_controller'
    );
    return new ShippingProfilesController('form.profiles_shipping_category_form');
  });
});
