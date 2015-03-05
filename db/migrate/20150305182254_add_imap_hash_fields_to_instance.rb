class AddImapHashFieldsToInstance < ActiveRecord::Migration
  # We do not delete the old column for now as a safety precaution
  # will blank it and then remove it afterwards if all goes well with this update
  def self.up
    add_column :instances, :support_imap_username, :string
    add_column :instances, :encrypted_support_imap_password, :string
    add_column :instances, :support_imap_server, :string
    add_column :instances, :support_imap_port, :integer
    add_column :instances, :support_imap_ssl, :boolean

    Instance.all.each do |instance|
      isc = ImapSettingsConverter.new(instance)
      isc.convert_hash
    end
  end

  def self.down
    remove_column :instances, :support_imap_username
    remove_column :instances, :encrypted_support_imap_password
    remove_column :instances, :support_imap_server
    remove_column :instances, :support_imap_port
    remove_column :instances, :support_imap_ssl
  end

end

