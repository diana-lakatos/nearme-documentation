class UpdateShippingLineItemsName < ActiveRecord::Migration
  def up
    LineItem::Shipping.unscoped.update_all(name: 'Delivery')
  end

  def down; end
end
