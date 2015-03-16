class AddAvailabilitiesMetadataToTransactables < ActiveRecord::Migration
  def change
    add_column :transactables, :opened_on_days, :integer, array: true, default: []
    add_index :transactables, :opened_on_days, using: :gin
    add_column :locations, :opened_on_days, :integer, array: true, default: []
    add_index :locations, :opened_on_days, using: :gin
  end
end
