class CreateCategoriesCategorables < ActiveRecord::Migration
  def change
    create_table :categories_categorables do |t|
      t.integer  "category_id"
      t.integer  "categorable_id"
      t.string  "categorable_type"
      t.integer  "instance_id"
      t.timestamps
    end

    add_index :categories_categorables, :category_id
    add_index :categories_categorables, :categorable_id
    add_index :categories_categorables, :instance_id
  end
end