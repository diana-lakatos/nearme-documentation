class MerchantAccountDrop < BaseDrop

  attr_reader :merchant_account

  delegate :state, :merchantable, :persisted?, to: :merchant_account

  def initialize(merchant_account)
    @merchant_account = merchant_account
  end

  def errors
    merchant_account.errors.values.join(', ')
  end

  def data
    merchant_account.data.stringify_keys
  end

end

