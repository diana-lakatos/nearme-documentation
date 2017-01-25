class AddPaymentMethodToCreditCards < ActiveRecord::Migration
  def change
    add_column :credit_cards, :payment_method_id, :integer
  end
end
