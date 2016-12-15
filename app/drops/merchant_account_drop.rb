# frozen_string_literal: true
class MerchantAccountDrop < BaseDrop
  # @return [MerchantAccountDrop]
  attr_reader :merchant_account

  # @!method id
  #   @return [Integer] id of the merchant account
  # @!method state
  #   @return [String] State name for the merchant account
  # @!method merchantable
  #   Merchantable object tied to this merchant account
  #   @return [Object]
  # @!method persisted?
  #   Whether the object is saved in the database
  #   @return [Boolean]
  # @!method payment_gateway
  #   @return [PaymentGateway] Payment gateway for this merchant account
  # @!method permissions_granted
  #   Indicates whether API permissions were successfully granted from the merchant's account to yours.
  #   @return [Boolean]
  # @!method chain_payments?
  #   @return [Boolean] whether it supports paypal chain payments
  # @!method chain_payment_set?
  #   @return [Boolean] whether the billing agreement is present
  # @!method pending?
  #   @return [Boolean] whether the merchant account is in the pending state
  # @!method next_transfer_date
  #   @return [Time, Date] when the next transfer will occur
  # @!method weekly_or_monthly_transfers?
  #   @return [Boolean] whether the transfer interval is weekly or monthly
  delegate :id, :state, :merchantable, :persisted?, :verified?, :payment_gateway, :permissions_granted,
           :chain_payments?, :chain_payment_set?, :pending?, :next_transfer_date, :iso_country_code,
           :weekly_or_monthly_transfers?, :minimum_company_fields, :owners, :supported_currencies,
           :first_name, :last_name, :bank_account_number, :account_type, to: :merchant_account

  def initialize(merchant_account)
    @merchant_account = merchant_account
  end

  def errors
    '<li>' + merchant_account.errors.full_messages.join('</ li><li>') + '</li>' if merchant_account.errors.any?
  end

  # @return [String, nil] errors for the merchant account in HTML format or nil if none
  # @todo -- errorsdrop?
  def all_errors
    @all_errors = merchant_account.errors.full_messages || []
    @all_errors << merchant_account.data[:disabled_reason] if merchant_account.data[:disabled_reason]
    @all_errors << merchant_account.data[:verification_details] if merchant_account.data[:verification_details]
    @all_errors << merchant_account.data[:verification_message] if merchant_account.data[:verification_message]
    @all_errors.presence
  end

  def tos_error
    merchant_account.errors[:tos].join('')
  end

  # @return [String] current state for the merchant account using translations
  #   the translation key is dashboard.merchant_account.[current_state]
  # @todo -- deprecate -- DIY
  def state_info
    I18n.t('dashboard.merchant_account.' + merchant_account.state)
  end

  # @return [Hash<String, String>] data associated with the merchant account
  def data
    merchant_account.data.stringify_keys
  end

  def account_types
    MerchantAccount::StripeConnectMerchantAccount::ACCOUNT_TYPES.map { |at| [I18n.t("dashboard.merchant_account.#{at}"), at] }
  end
end
