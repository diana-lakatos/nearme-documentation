class AddSupportImapHashToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :support_imap_hash, :text
  end
end
