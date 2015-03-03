class AddPossibleManualPaymentToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :possible_manual_payment, :boolean
  end
end
