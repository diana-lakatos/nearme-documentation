class AddEncryptedTokenToPaymentTransfers < ActiveRecord::Migration
  def change
    add_column :payment_transfers, :encrypted_token, :string
  end
end
