class FixMarketplaceErrorGroupIndex < ActiveRecord::Migration
  def self.up
    remove_index :marketplace_error_groups, name: "meg_instance_type_digest"
    add_index :marketplace_error_groups, [:instance_id, :error_type, :message_digest], name: :meg_instance_type_digest, unique: true, where: '(deleted_at IS NULL)'
  end

  def self.down
    remove_index :marketplace_error_groups, name: "meg_instance_type_digest"
    add_index :marketplace_error_groups, [:instance_id, :error_type, :message_digest], name: :meg_instance_type_digest, unique: true, where: '(deleted_at IS NULL)'
  end
end
