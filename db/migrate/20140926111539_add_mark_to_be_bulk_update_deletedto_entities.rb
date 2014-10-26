class AddMarkToBeBulkUpdateDeletedtoEntities < ActiveRecord::Migration
  def change
    add_column :locations, :mark_to_be_bulk_update_deleted, :boolean, default: false
    add_column :transactables, :mark_to_be_bulk_update_deleted, :boolean, default: false
    add_column :photos, :mark_to_be_bulk_update_deleted, :boolean, default: false
  end
end
