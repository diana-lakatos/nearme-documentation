class CategoriesProduct < ActiveRecord::Base
  # TODO REMOVE AFER CHANGE TO STI

  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :category
  belongs_to :product, class_name: Spree::Product, foreign_key: :spree_product_id
end
