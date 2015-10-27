class AddSearchSettingsToTransactableTypes < ActiveRecord::Migration
  def change
    add_column :transactable_types, :default_search_view, :string
    add_column :transactable_types, :search_engine, :string
    add_column :transactable_types, :searcher_type, :string
    add_column :transactable_types, :search_radius, :integer
    add_column :transactable_types, :show_categories, :boolean
    add_column :transactable_types, :category_search_type, :string
    add_column :transactable_types, :allow_save_search, :boolean
    add_column :transactable_types, :show_price_slider, :boolean
    add_column :transactable_types, :search_price_types_filter, :boolean
    add_column :transactable_types, :show_date_pickers, :boolean
    add_column :transactable_types, :date_pickers_use_availability_rules, :boolean
    add_column :transactable_types, :date_pickers_mode, :string
  end
end
