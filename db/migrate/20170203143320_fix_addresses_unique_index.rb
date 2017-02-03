class FixAddressesUniqueIndex < ActiveRecord::Migration
  def self.up
    remove_index :addresses, name: "index_addresses_on_entity_id_and_entity_type_and_address"
    add_index "addresses", ["instance_id", "entity_id", "entity_type", "address"], name: "index_addresses_on_entity_id_and_entity_type_and_address", unique: true, using: :btree, where: '(deleted_at IS NULL)'
  end

  def self.down
    remove_index :addresses, name: "index_addresses_on_entity_id_and_entity_type_and_address"
    add_index "addresses", ["instance_id", "entity_id", "entity_type", "address"], name: "index_addresses_on_entity_id_and_entity_type_and_address", unique: true, using: :btree, where: '(deleted_at IS NULL)'
  end
end
