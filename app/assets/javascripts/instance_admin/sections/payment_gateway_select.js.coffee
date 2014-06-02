class @InstanceAdmin.PaymentGatewaySelect
  constructor: (@select) ->
    @select.on "change", ->
      $(".payment-gateways-form").html("Loading...")
      $(@).submit()
