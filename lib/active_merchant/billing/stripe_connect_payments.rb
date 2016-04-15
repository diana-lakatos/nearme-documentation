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
        if update_params[:bank_account].present? &&  update_params[:bank_account][:account_number].length > 4
          account.bank_account = update_params[:bank_account]
        end
        if update_params[:legal_entity]
          [:dob, :additional_owners, :address, :ssn_last_4, :business_tax_id, :business_vat_id,
          :personal_id_number, :verification].each do |needed_field|
            if update_params[:legal_entity][needed_field.to_sym].present?
              account.legal_entity.send("#{needed_field}=", update_params[:legal_entity][needed_field.to_sym])
            end
          end
        end

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

