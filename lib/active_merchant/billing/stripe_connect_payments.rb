require 'stripe'

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

      def create_token(credit_card_id, customer_id, merchant_id)
        Stripe::Token.create(
          {:customer => customer_id, :card => credit_card_id},
          {:stripe_account => merchant_id} # id of the connected account
        )
      rescue
        nil
      end

      def parse_webhook(id)
        Stripe::Event.retrieve(id)
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

      # TODO headers and add_destination and create_post_for_auth_or_purchase methods is 
      # temporal work around.
      # Should be removed with upgrade of ActiveMerchant (activemerchant gem)
      # to the version higher that v1.60.0

      def headers(options = {})
        super.tap do |headers|
          headers.merge!("Stripe-Account" => options[:stripe_account]) if options[:stripe_account]
        end
      end

      def add_destination(post, options)
        post[:destination] = options[:destination] if options[:destination]
      end

      def create_post_for_auth_or_purchase(money, payment, options)
        super.tap do |post|
          add_destination(post, options)
          post
        end
      end
    end
  end
end

