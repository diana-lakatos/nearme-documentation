AddressController = require('../../sections/dashboard/address_controller')
Datepickers = require('../../dashboard/forms/datepickers')

module.exports = class StripeConnectController

  constructor: (container) ->
    @container = $(container)
    @accountTypeSelect = @container.find("select[data-account-type]")
    @bindEvents()
    @accountTypeSelect.change()
    Datepickers(@container)
    @container.find('.location').each (index, el) ->
      new AddressController($(el))


  bindEvents: ->
    @accountTypeSelect.on 'change', ->
      for el in ['company', 'individual', 'both']
        fields = $("div[data-account-type=" + el + "]")
        if el == 'both'
          match = $(@).val() in ['individual', 'company']
        else
          match = $(@).val() == el

        fields.toggleClass('hidden', !match)

    @container.on 'cocoon:after-insert', (e, fields) ->
      Datepickers(fields)
      new AddressController(fields)
