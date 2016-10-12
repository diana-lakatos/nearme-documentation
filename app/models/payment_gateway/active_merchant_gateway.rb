class PaymentGateway
  module ActiveMerchantGateway
    def self.included(base)
      base.extend(ClassMethods)
    end

    def settings
      super.merge(test: test_mode?)
    end

    def gateway
      @gateway = self.class.active_merchant_class.new(settings) if @gateway.nil?
      @gateway
    end

    module ClassMethods
      def supported_countries
        active_merchant_class.supported_countries
      end
    end
  end
end
