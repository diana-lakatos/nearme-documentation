class AddOptionalManualPayment < ActiveRecord::Migration
  def change
    add_column :transactable_types, :manual_payment, :boolean, default: false
    add_column :transactables, :manual_payment, :boolean, default: false
  end
end
