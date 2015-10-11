class AddAndRemoveColumnsFromInstanceClients < ActiveRecord::Migration
  def change
    add_column :instance_clients, :merchant_account_id, :integer, index: true
    add_column :instance_clients, :user_id, :integer, index: true
  end
end
