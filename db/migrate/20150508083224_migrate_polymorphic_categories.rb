class CategoriesProduct < ActiveRecord::Base
  belongs_to :category
  belongs_to :product, class_name: Spree::Product, foreign_key: :spree_product_id
end

class Transactable < ActiveRecord::Base
  has_many :categories_categorables, as: :categorable
  has_many :categories, through: :categories_categorables
end

class Spree::Product < Spree::Base
  has_many :categories_categorables, as: :categorable
  has_many :categories, through: :categories_categorables
end

class CategoriesCategorable < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :category
  belongs_to :categorable, polymorphic: true
end

class CategoriesTransactable < ActiveRecord::Base
  belongs_to :category
  belongs_to :transactable
end

class MigratePolymorphicCategories < ActiveRecord::Migration
  def up
    CategoriesTransactable.where.not(instance_id: nil).find_each do |ct|
      Instance.find(ct.instance_id).set_context!
      ct.transactable.categories << ct.category if ct.transactable && ct.category
    end

    PlatformContext.clear_current

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
