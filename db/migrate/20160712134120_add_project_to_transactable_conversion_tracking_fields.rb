class AddProjectToTransactableConversionTrackingFields < ActiveRecord::Migration
  def change
    add_column :projects, :transactable_id, :integer
    add_column :transactable_types, :custom_settings, :hstore, null: false, default: ''

    add_index :projects, :transactable_id
  end
end
