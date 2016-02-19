module ActiveMerchant
  module Billing
    class BraintreeMarketplacePayments

      def self.supported_countries
        %w(US)
      end

      def initialize(settings)
        settings.each { |k, v| Braintree::Configuration.send("#{k}=", v) if Braintree::Configuration.respond_to?("#{k}=") }
        @helper_gateway = ActiveMerchant::Billing::BraintreeBlueGateway.new(settings)
      end

      def verify(bt_challenge)
        Braintree::WebhookNotification.verify(bt_challenge)
      end

      def parse_webhook(bt_signature, bt_payload)
        Braintree::WebhookNotification.parse(bt_signature, bt_payload)
      end

      def client_token
        Braintree::ClientToken.generate
      end

      def generate_token
        @helper_gateway.generate_token
      end

      def onboard!(hash)
        Braintree::MerchantAccount.create(hash)
      end

      def authorize(amount, credit_card, options)
        # Braintree does not support all options, so we extend it
        transaction_params = @helper_gateway.send(:create_transaction_parameters, amount, credit_card, options)
        if options[:merchant_account]
          transaction_params[:merchant_account_id] = options[:merchant_account].internal_payment_gateway_account_id
          transaction_params[:service_fee_amount] = @helper_gateway.send(:amount, options[:service_fee_host]).to_s
        end
        @helper_gateway.send(:commit) do
          result = @helper_gateway.instance_variable_get(:'@braintree_gateway').transaction.send(:sale, transaction_params)
          response = Response.new(result.success?, @helper_gateway.send(:message_from_transaction_result, result), @helper_gateway.send(:response_params, result), @helper_gateway.send(:response_options, result))
          response.cvv_result['message'] = ''
          response
        end
      end

      def void(*args)
        @helper_gateway.void(*args)
      end

      def refund(*args)
        @helper_gateway.refund(*args)
      end

      def capture(*args)
        @helper_gateway.capture(*args)
      end

      def update_onboard!(id, hash)
        Braintree::MerchantAccount.update(id, hash)
      end
    end
  end
end

