class RemoveSupportImapHashFromInstances < ActiveRecord::Migration
  def change
    remove_column :instances, :support_imap_hash, :text
  end
end
