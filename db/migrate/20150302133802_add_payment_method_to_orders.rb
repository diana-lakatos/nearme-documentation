class AddPaymentMethodToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :payment_method, :string
  end
end
