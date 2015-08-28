class AddFailedAtToPaymentTransfers < ActiveRecord::Migration
  def change
    add_column :payment_transfers, :failed_at, :datetime, default: nil
  end
end
