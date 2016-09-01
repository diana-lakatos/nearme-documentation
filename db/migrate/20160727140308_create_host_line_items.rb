class CreateHostLineItems < ActiveRecord::Migration
  def change
    create_table :host_line_items do |t|
      t.integer  "instance_id"
      t.integer  "user_id"
      t.integer  "company_id"
      t.integer  "partner_id"
      t.integer  "line_item_source_id"
      t.string   "line_item_source_type"
      t.integer  "line_itemable_id"
      t.string   "line_itemable_type"
      t.string   "name"
      t.integer  "unit_price_cents",      default: 0
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
