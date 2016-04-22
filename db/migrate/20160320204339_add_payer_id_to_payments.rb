class AddPayerIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payer_id, :integer, index: true
  end
end
