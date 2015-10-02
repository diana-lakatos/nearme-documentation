class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer  "instance_id"
      t.integer  "creator_id"
      t.hstore   "properties"
      t.datetime "deleted_at"
      t.integer  "transactable_type_id"
      t.integer  "wish_list_items_count", default: 0
      t.string   "name"
      t.text     "description"
      t.string "external_id"
      t.timestamps
    end
    add_index :projects, [:instance_id, :creator_id]
  end
end
