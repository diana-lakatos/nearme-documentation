class AddPaymentGatewayModeToCreditCards < ActiveRecord::Migration
  def change
    add_column :credit_cards, :test_mode, :boolean, default: true
  end
end
