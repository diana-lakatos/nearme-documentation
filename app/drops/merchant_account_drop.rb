class MerchantAccountDrop < BaseDrop

  # @return [MerchantAccountDrop]
  attr_reader :merchant_account

  # @!method id
  #   @return [Integer] id of the merchant account
  # @!method state
  #   State name for the merchant account
  #   @return (see MerchantAccount#state)
  # @!method merchantable
  #   Merchantable object tied to this merchant account
  #   @return [Object]
  # @!method persisted?
  #   Whether the object is saved in the database
  #   @return [Boolean]
  # @!method payment_gateway
  #   Payment gateway for this merchant account
  #   @return (see MerchantAccount#payment_gateway)
  # @!method permissions_granted
  #   Indicates whether API permissions were successfully granted from the merchant’s account to yours.
  #   @return [Boolean]
  # @!method chain_payments?
  #   @return (see MerchantAccount#chain_payments?)
  # @!method chain_payment_set?
  #   @return [Boolean] whether the billing agreement is present
  # @!method pending?
  #   @return [Boolean] whether the merchant account is in the pending state
  # @!method next_transfer_date
  #   @return [Time, Date] when the next transfer will occur
  # @!method weekly_or_monthly_transfers?
  #   @return [Boolean] whether the transfer interval is weekly or monthly
  delegate :id, :state, :merchantable, :persisted?, :payment_gateway, :permissions_granted,
           :chain_payments?, :chain_payment_set?, :pending?, :next_transfer_date,
           :weekly_or_monthly_transfers?,  to: :merchant_account

  def initialize(merchant_account)
    @merchant_account = merchant_account
  end

  # @return [String, nil] errors for the merchant account in HTML format or nil if none
  def errors
    if merchant_account.errors.any?
      '<li>' + merchant_account.errors.full_messages.join('</ li><li>') + '</li>'
    else
      nil
    end
  end

  # @return [String] current state for the merchant account using translations
  #   the translation key is dashboard.merchant_account.[current_state]
  def state_info
    I18n.t('dashboard.merchant_account.' + merchant_account.state)
  end

  # @return [Hash<String, String>] data associated with the merchant account
  def data
    merchant_account.data.stringify_keys
  end
end
