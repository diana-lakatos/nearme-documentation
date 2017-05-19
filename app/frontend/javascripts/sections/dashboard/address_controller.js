var AddressController, AddressFieldController;

AddressFieldController = require('./address_field_controller');

AddressController = function() {
  function AddressController(container) {
    var field, i, len, ref;
    this.container = container;
    ref = this.container.find('[data-behavior=address-autocomplete]');
    for (i = 0, len = ref.length; i < len; i++) {
      field = ref[i];
      this.addressFieldController = new AddressFieldController(
        $(field).closest('[data-address-field]')
      );
    }
  }

  return AddressController;
}();

module.exports = AddressController;
