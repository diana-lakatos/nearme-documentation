class AddPendingToPayouts < ActiveRecord::Migration
  def change
    add_column :payouts, :pending, :string
  end
end
