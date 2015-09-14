class AddShippoFieldsToShipment < ActiveRecord::Migration
  def change
    add_column :spree_shipments, :shippo_label_url, :text, null: true
    add_column :spree_shipments, :shippo_tracking_number, :text, null: true
  end
end
