module BuySellMarket::CheckoutHelper
  def link_to_express_checkout(order)
    link_to(
      image_tag("https://www.paypal.com/en_US/i/btn/btn_xpressCheckout.gif"),
      express_order_checkout_index_path(order),
      class: "express-checkout")
  end

  def paypal_express_gateway_available?(order)
    PaymentGateway::PaypalExpressPaymentGateway === current_instance.payment_gateway(order.seller_iso_country_code, order.currency)
  end
end
