class AddPaymentTransfersFrequencyToInstances < ActiveRecord::Migration
  def up
    add_column :instances, :payment_transfers_frequency, :string, default: :monthly
  end

  def down
    remove_column :instances, :payment_transfers_frequency
  end
end
