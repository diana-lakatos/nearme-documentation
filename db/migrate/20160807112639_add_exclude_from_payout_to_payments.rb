class AddExcludeFromPayoutToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :exclude_from_payout, :boolean, default: false
  end
end
