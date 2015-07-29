class MerchantAccountDrop < BaseDrop

  attr_reader :merchant_account

  delegate :id, :state, :merchantable, :persisted?, to: :merchant_account

  def initialize(merchant_account)
    @merchant_account = merchant_account
  end

  def errors
    merchant_account.errors.map { |k, v| (k == :data ? '' : "#{k.to_s.humanize} ") + v }.join(', ')
  end

  def data
    merchant_account.data.stringify_keys
  end
end

