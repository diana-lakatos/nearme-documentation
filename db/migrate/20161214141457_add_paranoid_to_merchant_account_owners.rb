# frozen_string_literal: true
class AddParanoidToMerchantAccountOwners < ActiveRecord::Migration
  def change
    add_column :merchant_account_owners, :deleted_at, :timestamp, index: true
  end
end
