module.exports = class InstanceAdminPaymentGatewaySelect
  constructor: (select) ->
    $(select).on "change", ->
      $(".payment-gateways-form").html("Loading...")
      $(@).submit()
