class CreateCategoriesCategorizables < ActiveRecord::Migration
  class Category < ActiveRecord::Base
  end

  def change
    rename_table :categories_categorables, :categories_categorizables

    rename_column :categories, :categorable_type, :categorizable_type
    rename_column :categories, :categorable_id, :categorizable_id

    rename_column :categories_categorizables, :categorable_type, :categorizable_type
    rename_column :categories_categorizables, :categorable_id, :categorizable_id

    add_index :categories_categorizables, [:instance_id, :categorizable_id, :categorizable_type], name: 'poly_categorizables'
  end
end
