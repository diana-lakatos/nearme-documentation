class AddHoursToExpirationToTransactableTypes < ActiveRecord::Migration
  def up
    add_column :transactable_types, :hours_to_expiration, :integer, default: 24
    TransactableType.where(hours_to_expiration: nil).update_all(hours_to_expiration: 24)
  end

  def down
    remove_column :transactable_types, :hours_to_expiration, :integer
  end
end
