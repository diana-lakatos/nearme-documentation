module.exports = class AddressController
  constructor: (context = 'body') ->
    fields = $(context).find('[data-address-field]')
    return unless fields.length > 0
    AddressFieldController = require.ensure './address_field_controller', (require)->
      AddressFieldController = require('./address_field_controller')
      fields.each ->
        new AddressFieldController(@)
