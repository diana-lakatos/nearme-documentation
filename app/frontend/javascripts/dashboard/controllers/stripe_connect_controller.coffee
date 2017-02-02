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
      companyFields = $("div[data-account-type=company]")
      if $(@).val() == 'company'
        companyFields.removeClass('hidden')
      else
        companyFields.addClass('hidden')


    @container.on 'cocoon:after-insert', (e, fields) ->
      Datepickers(fields)
      new AddressController(fields)
