class AddHintToApprovalRequestAttachments < ActiveRecord::Migration
  def change
    add_column :approval_request_attachments, :hint, :text
  end
end
