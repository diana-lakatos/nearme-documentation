module ActiveMerchant
  module Billing
    class StripeCustomGateway < StripeGateway
      def initialize(settings)
        Stripe.api_key = settings[:login]
        Stripe.api_version = settings[:version] = PaymentGateway::StripePaymentGateway::API_VERSION
        super
      end

      def find_payment(token, _merchant_account = nil)
        PaymentGateway::Response::Stripe::Payment.new(Stripe::Charge.retrieve(token))
      end
    end
  end
end
