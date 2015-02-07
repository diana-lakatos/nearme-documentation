class AddPlatformContextDetailToSpreeOrders < ActiveRecord::Migration
  def change
    add_reference :spree_orders, :platform_context_detail, polymorphic: true
    add_index :spree_orders, [:platform_context_detail_id, :platform_context_detail_type], name: 'index_spree_orders_on_platform_context_detail'
  end
end
