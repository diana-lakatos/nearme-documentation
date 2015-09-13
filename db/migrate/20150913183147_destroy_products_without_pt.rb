class DestroyProductsWithoutPt < ActiveRecord::Migration
  def up
    Spree::Product.unscoped.where("spree_products.deleted_at is null").
      joins("inner join transactable_types on spree_products.product_type_id = transactable_types.id").
      where("transactable_types.type = 'Spree::ProductType'").
      where("transactable_types.deleted_at is not null").destroy_all
  end
end
