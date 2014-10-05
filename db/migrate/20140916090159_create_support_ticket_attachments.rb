class CreateSupportTicketAttachments < ActiveRecord::Migration
  def change
    create_table :support_ticket_message_attachments do |t|
      t.text :description
      t.string :tag
      t.integer :instance_id, index: true
      t.integer :uploader_id, index: true
      t.integer :receiver_id, index: true
      t.integer :ticket_message_id, index: true
      t.integer :ticket_id, index: true
      t.integer :target_id
      t.string :target_type
      t.string :file
      t.string :file_type
      t.datetime :deleted_at
      t.index [:target_id, :target_type], name: 'stma_target_polymorphic'
      t.timestamps
    end
  end
end
