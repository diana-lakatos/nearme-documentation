# frozen_string_literal: true
class AddMerchantAccountToPaymentTransfers < ActiveRecord::Migration
  def change
    add_column :payment_transfers, :merchant_account_id, :integer, index: true
  end
end
