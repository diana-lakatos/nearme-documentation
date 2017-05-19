var AddressController;

AddressController = function() {
  function AddressController(context) {
    var AddressFieldController, fields;
    if (context == null) {
      context = 'body';
    }
    fields = $(context).find('[data-address-field]');
    if (!(fields.length > 0)) {
      return;
    }
    AddressFieldController = require.ensure('./address_field_controller', function(require) {
      AddressFieldController = require('./address_field_controller');
      return fields.each(function() {
        return new AddressFieldController(this);
      });
    });
  }

  return AddressController;
}();

module.exports = AddressController;
