class AddHostFee < ActiveRecord::Migration
  def change
    create_table :host_fee_line_items do |t|
      t.integer  "instance_id", index: true
      t.integer  "user_id", index: true
      t.integer  "company_id", index: true
      t.integer  "partner_id", index: true
      t.integer  "line_item_source_id", index: true
      t.string   "line_item_source_type"
      t.integer  "line_itemable_id", index: true
      t.string   "line_itemable_type"
      t.integer  "unit_price_cents", default: 0
      t.datetime "deleted_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
