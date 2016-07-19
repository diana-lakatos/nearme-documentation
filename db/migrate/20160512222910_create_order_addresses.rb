class CreateOrderAddresses < ActiveRecord::Migration
  def change
    create_table :order_addresses do |t|
      t.string   "firstname",         limit: 255
      t.string   "lastname",          limit: 255
      t.string   "company",           limit: 255
      t.string   "street1",           limit: 255
      t.string   "street2",           limit: 255
      t.string   "city",              limit: 255
      t.string   "zip",               limit: 255
      t.string   "phone",             limit: 255
      t.string   "email"
      t.string   "state_name",        limit: 255
      t.string   "alternative_phone", limit: 255
      t.integer  "state_id",          index: true
      t.integer  "country_id",        index: true
      t.integer  "instance_id",       index: true
      t.integer  "user_id"
      t.string   "shippo_id"

      t.datetime "deleted_at"


      t.timestamps null: false
    end
  end
end
