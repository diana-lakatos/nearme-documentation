module BuySellMarket::CheckoutHelper
  def paypal_express_gateway_available?(order)
    PaymentGateway::PaypalExpressPaymentGateway === current_instance.payment_gateway(order.seller_iso_country_code, order.currency)
  end

  def checkout_step
    controller_name == 'checkout' && defined?(step) ? step : nil
  end

  def current_order
    controller_name == 'checkout' && defined?(@order) ? @order : nil
  end
end
