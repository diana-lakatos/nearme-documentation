var fields = $('[data-address-field]');

if (fields.length > 0) {
  require.ensure('../../dashboard/address_field/address_controller', function(require){
    var AddressController = require('../../dashboard/address_field/address_controller');
    return new AddressController();
  });
}

$('html').on('loaded:dialog.nearme', function(){
  require.ensure('../../dashboard/address_field/address_controller', function(require){
    var AddressController = require('../../dashboard/address_field/address_controller');
    return new AddressController('.dialog');
  });
});
