class AddServiceFeeCentsToSpreeOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :service_fee_amount_guest_cents, :integer, default: 0
    add_column :spree_orders, :service_fee_amount_host_cents, :integer, default: 0
  end
end
