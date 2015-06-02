class AddExpressTokenToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :express_token, :string
    add_column :spree_orders, :express_payer_id, :string
  end
end
