class AddHoursToExpirationToTransactableTypes < ActiveRecord::Migration
  def up
    add_column :transactable_types, :hours_to_expiration, :integer, default: 24
    add_column :reservations, :hours_to_expiration, :integer, null: false, default: 24
  end

  def down
    remove_column :transactable_types, :hours_to_expiration, :integer
    remove_column :reservations, :hours_to_expiration, :integer
  end
end
