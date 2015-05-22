class RemoveCategoriesCategorizablesIndex < ActiveRecord::Migration
  def change
    remove_index "categories_categorizables", column: "categorizable_id"
    remove_index "categories_categorizables", column: "instance_id"
  end
end
