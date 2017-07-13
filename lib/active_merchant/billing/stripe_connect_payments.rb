# frozen_string_literal: true
require 'stripe'

module ActiveMerchant
  module Billing
    class StripeConnectPayments < StripeGateway

      RETRIVEABLE_OBJECTS = %w(balance_transaction charge event payout customer account)

      def initialize(settings)
        Stripe.api_key = settings[:login]
        Stripe.api_version = settings[:version] = PaymentGateway::StripePaymentGateway::API_VERSION
        super
      end

      RETRIVEABLE_OBJECTS.each do |object_name|
        define_method "retrieve_#{object_name}" do |id, merchant_account_id=nil|
          call_stripe("Stripe::#{object_name.classify}".constantize, :retrieve, id, merchant_account_id)
        end
      end

      # TODO remove aliases
      alias find_payment retrieve_charge
      alias parse_webhook retrieve_event
      alias find_balance retrieve_balance_transaction

      def onboard!(create_params)
        call_stripe(Stripe::Account, :create, create_params)
      end

      # This method allows to call proper Stripe Account. If merchant id is passed
      # we want to call merchant account otherwise we use MPO account
      def call_stripe(stripe_class, action, args, merchant_id = nil)
        response_wrapper(stripe_class.name) do
          if merchant_id
            stripe_class.send(action, args, { stripe_account: merchant_id })
          else
            stripe_class.send(action, args)
          end
        end
      rescue => e
        raise_error(e)
      end

      def response_wrapper(response_class_name)
        "Payment::Gateway::Response::#{response_class_name}".constantize.new(yield)
      rescue
        # in some cases we don't have wrapper we just return Stripe object then
        yield
      end

      def create_token(credit_card_id, customer_id, merchant_id)
        call_stripe(Stripe::Token, :create, { customer: customer_id, card: credit_card_id }, merchant_id)
      end

      def create_customer(token, description, merchant_id = nil)
        call_stripe(Stripe::Customer, :create, { description: description, source: token }, merchant_id)
      end

      def find_transfer_transactions(transfer_id, merchant_account_id)
        call_stripe(Stripe::BalanceTransaction, :all, { transfer: transfer_id }, merchant_account_id)
      end

      def raise_error(error)
        if [404, 403].include?(error.respond_to?(:http_status) && error.http_status)
          raise ActiveRecord::RecordNotFound
        else
          raise error
        end
      end

      def update_onboard!(stripe_account_id, update_params)
        account = retrieve_account(stripe_account_id)

        if update_params[:bank_account].present? && update_params[:bank_account][:account_number].length > 4
          account.bank_account = update_params[:bank_account]
        end

        if update_params[:legal_entity]
          [:first_name, :last_name, :dob, :additional_owners, :address, :ssn_last_4, :business_tax_id, :business_name,
           :personal_id_number, :verification, :type].each do |needed_field|
            if update_params[:legal_entity][needed_field.to_sym].present?
              account.legal_entity.send("#{needed_field}=", update_params[:legal_entity][needed_field.to_sym])
            end
          end
        end

        begin
          account.save
        rescue => e
          if e.param == "bank_account"
            OpenStruct.new(error: "Bank account: #{e.message}")
          else
            OpenStruct.new(error: e.message)
          end
        end
      end

      # TODO: headers and add_destination and create_post_for_auth_or_purchase methods is
      # temporal work around.
      # Should be removed with upgrade of ActiveMerchant (activemerchant gem)
      # to the version higher that v1.60.0

      def headers(options = {})
        super.tap do |headers|
          headers.merge!('Stripe-Account' => options[:stripe_account]) if options[:stripe_account]
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
