class AddMessageDigestToMarketplaceErrors < ActiveRecord::Migration
  def self.up
    MarketplaceError.where('error_type = ?', 'Javascript Error').delete_all

    add_column :marketplace_errors, :message_digest, :string, null: true

    index = 0
    MarketplaceError.find_each do |marketplace_error|
      index += 1
      puts "At index: #{index}" if index % 1000 == 0
      marketplace_error.update_column(:message_digest, Digest::SHA256.hexdigest(marketplace_error.message.to_s))
    end

    add_index :marketplace_errors, [:instance_id, :error_type, :message_digest], name: 'errors_type_digest_instance'
  end

  def self.down
    remove_column :marketplace_errors, :message_digest

    remove_index :marketplace_errors, name: 'errors_type_digest_instance'
  end
end
