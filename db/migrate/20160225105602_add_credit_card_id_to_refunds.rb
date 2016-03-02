class AddCreditCardIdToRefunds < ActiveRecord::Migration
  def change
    add_column :refunds, :credit_card_id, :integer, index: true
  end
end
