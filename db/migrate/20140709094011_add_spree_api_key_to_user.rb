class AddSpreeApiKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :spree_api_key, :string
  end
end
