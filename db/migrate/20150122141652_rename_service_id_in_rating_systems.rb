class RenameServiceIdInRatingSystems < ActiveRecord::Migration
  def change
    rename_column :rating_systems, :service_id, :transactable_type_id
  end
end
