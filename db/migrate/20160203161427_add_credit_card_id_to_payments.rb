class AddCreditCardIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :credit_card_id, :integer
    add_index :payments, :credit_card_id
  end
end
