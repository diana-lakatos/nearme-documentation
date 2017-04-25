class AddSearchRestrictionsToTransactableType < ActiveRecord::Migration
  def change
    add_column :transactable_types, :search_restrictions, :text
  end
end
