class @InstanceAdmin.PaymentGatewayController

  constructor: (@container) ->
    @container.find(".payment-gateway-option").first().removeClass("hidden")
    @container.find('.payment-gateway-select').on 'change', ->
      $('.payment-gateway-option').addClass('hidden')
      $('.payment-gateway-'+ $(this).val()).removeClass('hidden')
