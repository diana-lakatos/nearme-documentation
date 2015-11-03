class AddSellerAttachmentsAccessLevelToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :seller_attachments_access_level, :string, limit: 255, default: 'disabled', null: false
    add_column :instances, :seller_attachments_documents_num, :integer, default: 10, null: false
  end
end
