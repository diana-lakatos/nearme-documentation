class WebhookConfigurations < ActiveRecord::Migration
  def change
    create_table :webhook_configurations do |t|
      t.timestamp :deleted_at
      t.integer :instance_id
      t.integer :payment_gateway_id
      t.text    :encrypted_signing_secret
      t.string  :payment_gateway_mode

      t.timestamps
    end

    add_column :webhooks, :wenhook_configuration_id, :integer
  end
end
