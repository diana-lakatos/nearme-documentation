class ChangeEncryptedResponseTypeToText < ActiveRecord::Migration
  def up
    change_column :charges, :encrypted_response, :text
    change_column :payouts, :encrypted_response, :text
  end

  def down
    change_column :charges, :encrypted_response, :string
    change_column :payouts, :encrypted_response, :string
  end
end
