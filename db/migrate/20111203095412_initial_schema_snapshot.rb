class InitialSchemaSnapshot < ActiveRecord::Migration
  def change
    create_table "authentications", :force => true do |t|
      t.integer  "user_id"
      t.string   "provider"
      t.string   "uid"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "bookings", :force => true do |t|
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
      t.integer  "workplace_id"
      t.text     "comment"
      t.string   "state"
      t.integer  "user_id"
      t.date     "date"
    end

    create_table "feeds", :force => true do |t|
      t.integer  "user_id"
      t.integer  "workplace_id"
      t.string   "activity"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
      t.integer  "booking_id"
    end

    add_index "feeds", ["workplace_id"], :name => "index_feeds_on_workplace_id"

    create_table "photos", :force => true do |t|
      t.integer  "workplace_id", :null => false
      t.string   "description",  :null => false
      t.string   "file",         :null => false
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
    end

    add_index "photos", ["workplace_id"], :name => "index_photos_on_workplace_id"

    create_table "users", :force => true do |t|
      t.string   "email",                  :default => "", :null => false
      t.string   "encrypted_password",     :default => "", :null => false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          :default => 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string   "current_sign_in_ip"
      t.string   "last_sign_in_ip"
      t.datetime "created_at",                             :null => false
      t.datetime "updated_at",                             :null => false
      t.string   "name"
      t.boolean  "admin"
      t.integer  "bookings_count",         :default => 0,  :null => false
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true
    add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

    create_table "workplaces", :force => true do |t|
      t.string   "name"
      t.integer  "maximum_desks"
      t.text     "description"
      t.text     "company_description"
      t.text     "address"
      t.boolean  "confirm_bookings"
      t.integer  "creator_id"
      t.float    "latitude"
      t.float    "longitude"
      t.datetime "created_at",                                  :null => false
      t.datetime "updated_at",                                  :null => false
      t.text     "description_html"
      t.text     "company_description_html"
      t.text     "url"
      t.string   "formatted_address"
      t.boolean  "fake",                     :default => false, :null => false
      t.integer  "bookings_count",           :default => 0,     :null => false
    end
  end
end
