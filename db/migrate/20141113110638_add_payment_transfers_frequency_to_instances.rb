class AddPaymentTransfersFrequencyToInstances < ActiveRecord::Migration
  def up
    add_column :instances, :payment_transfers_frequency, :string, default: :fortnightly

    Instance.reset_column_information
    Instance.update_all(payment_transfers_frequency: 'monthly')
  end

  def down
    remove_column :instances, :payment_transfers_frequency
  end
end
