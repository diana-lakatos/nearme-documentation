class AddSearchSettingsToInstanceProfileTypes < ActiveRecord::Migration
  def change
    add_column :instance_profile_types, :show_categories, :boolean
    add_column :instance_profile_types, :category_search_type, :string
    add_column :instance_profile_types, :position, :integer, default: 0
  end
end
