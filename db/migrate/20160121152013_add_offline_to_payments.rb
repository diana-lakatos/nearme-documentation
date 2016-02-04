class AddOfflineToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :offline, :boolean, default: false
  end
end
