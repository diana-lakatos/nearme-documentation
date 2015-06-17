class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.integer :instance_id
      t.integer :webhookable_id
      t.string :webhookable_type
      t.text :encrypted_response
      t.timestamps
    end
    add_index :webhooks, [:instance_id, :webhookable_id, :webhookable_type], name: 'index_webhooks_on_instance_id_and_webhookable'
  end
end
