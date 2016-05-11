class AddNameAndStateToShipments < ActiveRecord::Migration
  def change
    add_column :shipments, :name, :string
    add_column :shipments, :state, :string
    add_column :shipments, :shipping_rule_id, :integer
  end
end
