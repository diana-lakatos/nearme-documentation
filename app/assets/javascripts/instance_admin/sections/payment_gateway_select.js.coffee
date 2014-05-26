class @InstanceAdmin.PaymentGatewaySelect
  constructor: (@select) ->
    @select.on "change", ->
      $(@).submit()
