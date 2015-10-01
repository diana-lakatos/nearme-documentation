class AddWebhookTokenToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :encrypted_webhook_token, :string
  end
end
