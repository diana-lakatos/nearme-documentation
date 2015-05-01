class RenameCategoryMutlipleRootCategriesColumn < ActiveRecord::Migration
  def change
    rename_column :categories, :multiple_root_categries, :multiple_root_categories
  end
end
