# frozen_string_literal: true
class MerchantAccountOwnerDrop < BaseDrop
  # @return [MerchantAccountDrop]
  attr_reader :merchant_account_owner

  # @!method date_format
  #   @return [string] date_format of the merchant account dob

  delegate :date_format_readable, :address, to: :merchant_account_owner

  def initialize(merchant_account_owner)
    @merchant_account_owner = merchant_account_owner
  end

  def dob_date
    I18n.l(merchant_account_owner.dob_date, format: :short)
  end
end
