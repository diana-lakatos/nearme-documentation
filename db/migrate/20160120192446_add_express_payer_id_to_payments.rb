class AddExpressPayerIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :express_payer_id, :string
    add_column :payments, :express_token, :string
  end
end
