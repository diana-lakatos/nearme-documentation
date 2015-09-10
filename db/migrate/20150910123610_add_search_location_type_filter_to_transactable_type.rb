class AddSearchLocationTypeFilterToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :search_location_type_filter, :boolean, default: true
  end
end
