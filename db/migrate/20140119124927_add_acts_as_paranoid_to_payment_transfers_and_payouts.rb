class AddActsAsParanoidToPaymentTransfersAndPayouts < ActiveRecord::Migration
  def change
    add_column :payment_transfers, :deleted_at, :datetime
    add_column :payouts, :deleted_at, :datetime
  end
end
