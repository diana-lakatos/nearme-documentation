class DropPartnersTable < ActiveRecord::Migration
  def up
    drop_table :partners
    remove_column :instances, :partner_id
  end

  def down
    create_table "partners", :force => true do |t|
      t.string   "name"
      t.decimal  "service_fee_percent", :precision => 5, :scale => 2, :default => 0.0
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
    add_column :instances, :partner_id, :integer
  end
end
