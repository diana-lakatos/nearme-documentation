class AddPendingToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :pending, :boolean, :default => false
  end
end
