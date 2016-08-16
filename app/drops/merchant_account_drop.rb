class MerchantAccountDrop < BaseDrop

  attr_reader :merchant_account

  delegate :id, :state, :merchantable, :persisted?, :payment_gateway, :permissions_granted,
    :chain_payments?, :chain_payment_set?, :pending?, :next_transfer_date, to: :merchant_account

  def initialize(merchant_account)
    @merchant_account = merchant_account
  end

  def errors
    if merchant_account.errors.any?
      "<li>" +  merchant_account.errors.full_messages.join("</ li><li>") + "</li>"
    else
      nil
    end
  end

  def state_info
    I18n.t("dashboard.merchant_account." + merchant_account.state)
  end

  def data
    merchant_account.data.stringify_keys
  end
end

