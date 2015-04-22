class AddDisplayOptionsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :display_options, :text
    add_column :categories, :search_options, :text
    add_column :categories, :mandatory, :boolean
  end
end
