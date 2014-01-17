class AddBalancedApiKeyToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :balanced_api_key, :string
    add_column :instances, :encrypted_balanced_api_key, :string
  end
end
