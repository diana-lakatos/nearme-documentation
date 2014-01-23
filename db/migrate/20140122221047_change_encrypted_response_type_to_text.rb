class ChangeEncryptedResponseTypeToText < ActiveRecord::Migration
  def change
    change_column :charges, :encrypted_response, :text
    change_column :payouts, :encrypted_response, :text
  end
end
