class AddEncryptedTokenToPaymentTransfers < ActiveRecord::Migration
  def change
    add_column :payment_transfers, :encrypted_token, :string, index: true
  end
end
