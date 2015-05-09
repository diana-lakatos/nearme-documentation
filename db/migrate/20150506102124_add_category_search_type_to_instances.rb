class AddCategorySearchTypeToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :category_search_type, :string, default: 'AND'
    Instance.update_all("category_search_type = 'AND'")
  end
end
