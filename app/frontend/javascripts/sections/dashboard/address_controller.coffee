AddressFieldController = require('./address_field_controller')

module.exports = class AddressController

  constructor: (@container) ->
    for field in @container.find('[data-behavior=address-autocomplete]')
      @addressFieldController = new AddressFieldController($(field).closest('[data-address-field]'))

