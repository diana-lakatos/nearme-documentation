class AddPaymentMethodIdToOrders < ActiveRecord::Migration
  def change
    rename_column :spree_orders, :payment_method, :old_payment_method
    add_column :spree_orders, :payment_method_id, :integer
  end
end
