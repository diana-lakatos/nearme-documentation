class AddCategoriesProductsTable < ActiveRecord::Migration
  def change
    create_table "categories_products", force: true do |t|
      t.integer  "category_id"
      t.integer  "spree_product_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "instance_id"
    end
  end
end
