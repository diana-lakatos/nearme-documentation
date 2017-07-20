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
  # @!method iso_country_code
  #   @return [String] country symbol associated with merchant account
  #   this value is inherited from Country or User address
  # @!method owners
  #   @return [Array] owners associated with merchant account
  # @!method supported_currencies
  #   @return [Array] currencies supported in given location
  # @!method first_name
  #   @return [String] merchant first_name
  # @!method last_name
  #   @return [String] merchant last_name
  # @!method bank_account_number
  #   @return [String] merchant bank_account_number
  # @!method account_type
  #   @return [String] merchant account_type for now only Company and Individual types are supported
  # @!method verified?
  #   @return [Boolean] determines merchant account verification the ability to trafner money.

  delegate :id, :state, :merchantable, :persisted?, :verified?, :payment_gateway, :permissions_granted,
           :chain_payments?, :chain_payment_set?, :pending?, :next_transfer_date, :iso_country_code,
           :weekly_or_monthly_transfers?, :owners, :supported_currencies,
           :first_name, :last_name, :business_name, :bank_account_number, :account_type, to: :merchant_account

  def initialize(merchant_account)
    @merchant_account = merchant_account
  end

  # @return [Boolean] true if provided personal number
  def personal_id_number_provided
    merchant_account.attribute('legal_entity.personal_id_number_provided')
  end

  # @return [String] timestamp - date until account is valid
  def due_by
    I18n.l(Time.at(data["due_by"].to_i), format: :long) if data["due_by"]
  end

  # @return [String] object errors returned by Validation mechanims as html list
  def errors
    '<li>' + merchant_account.errors.full_messages.join('</ li><li>') + '</li>' if merchant_account.errors.any?
  end

  # @return [String, nil] errors for the merchant account in HTML format or nil if none
  # @todo -- errorsdrop?
  def all_errors
    @all_errors = merchant_account.errors.full_messages || []
    @all_errors << data["disabled_reason"] if data["disabled_reason"]
    @all_errors << data["verification_message"] if data["verification_message"]
    return @all_errors.presence if stripe_wants_only_photo_but_without_due_date?

    if fields_needed.present?
      @all_errors << I18n.t('dashboard.merchant_account.fields_needed.header')
      fields_needed.each do |field|
        @all_errors << I18n.t('dashboard.merchant_account.fields_needed.' + field)
      end
    end
    @all_errors.presence
  end

  # @return [Array] fields list requested by Stripe
  def fields_needed
    merchant_account.respond_to?(:fields_needed) ? merchant_account.fields_needed : []
  end

  # @return [Boolean] true when no text errors passed in update
  # this is different from verified? which observes ability to transfer money
  def complete?
    !merchant_account.account_incomplete?
  end

  # @return [String] error if tos not signed
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

  # @return [Array] types that are supported in Stripe Connect merchant account creation
  def account_types
    MerchantAccount::StripeConnectMerchantAccount::ACCOUNT_TYPES.map { |at| [I18n.t("dashboard.merchant_account.#{at}"), at] }
  end

  private

  def stripe_wants_only_photo_but_without_due_date?
    fields_needed == ["legal_entity.verification.document"] && data["due_by"].nil?
  end
end
