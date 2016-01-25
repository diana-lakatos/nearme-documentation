class CorrectAddressIndex < ActiveRecord::Migration
  def change
    remove_index :addresses, ["entity_id", "entity_type", "address"]
    add_index "addresses", ["instance_id", "entity_id", "entity_type", "address"], name: "index_addresses_on_entity_id_and_entity_type_and_address", unique: true, using: :btree
  end
end
