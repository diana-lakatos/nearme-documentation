class AddOrderIdToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :order_id, :integer, index: true
  end
end
