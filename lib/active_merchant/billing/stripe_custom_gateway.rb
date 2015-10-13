module ActiveMerchant
  module Billing
    class StripeCustomGateway < StripeGateway

      def initialize(settings)
        Stripe.api_key = settings[:login]
        super
      end

    end
  end
end

