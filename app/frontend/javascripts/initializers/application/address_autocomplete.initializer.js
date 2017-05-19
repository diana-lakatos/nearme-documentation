var els = $('[data-behavior=address-autocomplete]');
if (els.length > 0) {
  require.ensure('../../sections/dashboard/address_controller', function(require) {
    var AddressController = require('../../sections/dashboard/address_controller');
    return new AddressController(els.closest('form'));
  });
}

var form = $('#project_form');
if (form.length > 0) {
  require.ensure('../../sections/dashboard/address_controller', function(require) {
    var AddressController = require('../../sections/dashboard/address_controller');
    return new AddressController(form);
  });
}
