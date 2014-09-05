class AddTransactableTypePageEnabled < ActiveRecord::Migration
  def change
    add_column :transactable_types, :show_page_enabled, :boolean, default: false
  end
end
