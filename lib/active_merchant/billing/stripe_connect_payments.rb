module ActiveMerchant
  module Billing
    class StripeConnectPayments < StripeGateway

      def initialize(settings)
        Stripe.api_key = settings[:login]
        Stripe.api_version = settings[:version] = '2015-04-07'
        super
      end

      def onboard!(create_params)
        Stripe::Account.create(create_params)
      rescue => e
        OpenStruct.new(error: e.message)
      end

      def parse_webhook(id, secret_key)
        Stripe::Event.retrieve(id, secret_key)
      end

      def retrieve_account(id)
        Stripe::Account.retrieve(id)
      end

      def update_onboard!(stripe_account_id, update_params)
        account = Stripe::Account.retrieve(stripe_account_id)
        account.bank_account = update_params[:bank_account]
        account.legal_entity.dob = update_params[:legal_entity][:dob]
        account.save
      rescue => e
        OpenStruct.new(error: e.message)
      end

      def create_post_for_auth_or_purchase(money, payment, options)
        super.tap do |p|
          if options[:merchant_account]
            p[:destination]     = options[:merchant_account].internal_payment_gateway_account_id
            p[:application_fee] = amount(options[:service_fee_host]).to_s
          end
        end
      end

    end
  end
end

