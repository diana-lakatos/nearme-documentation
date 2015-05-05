class MigratePolymorphicCategories < ActiveRecord::Migration
  class CategoriesTransactable < ActiveRecord::Base
    belongs_to :category
    belongs_to :transactable
  end

  class CategoriesProduct < ActiveRecord::Base
    belongs_to :category
    belongs_to :product, class_name: Spree::Product, foreign_key: :spree_product_id
  end


  def up
    CategoriesTransactable.where.not(instance_id: nil).find_each do |ct|
      Instance.find(ct.instance_id).set_context!
      ct.transactable.categories << ct.category if ct.transactable && ct.category
    end

    CategoriesProduct.where.not(instance_id: nil).find_each do |ct|
      Instance.find(ct.instance_id).set_context!
      ct.product.categories << ct.category if ct.product && ct.category
    end

    drop_table :categories_products
    drop_table :categories_transactables
  end

  def down
    create_table "categories_products", force: true do |t|
      t.integer  "category_id"
      t.integer  "spree_product_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "instance_id"
    end

    create_table "categories_transactables", force: true do |t|
      t.integer  "category_id"
      t.integer  "transactable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "instance_id"
    end
  end
end
