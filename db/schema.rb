# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120806183917) do

  create_table "amenities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "secret"
    t.string   "token"
    t.text     "info"
  end

  create_table "bookings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workplace_id"
    t.text     "comment"
    t.string   "state"
    t.integer  "user_id"
    t.date     "date"
  end

  create_table "companies", :force => true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.string   "email"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "deleted_at"
  end

  create_table "feeds", :force => true do |t|
    t.integer  "user_id"
    t.integer  "workplace_id"
    t.string   "activity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "booking_id"
  end

  add_index "feeds", ["workplace_id"], :name => "index_feeds_on_workplace_id"

  create_table "inquiries", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "inquiring_user_id"
    t.text     "message"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "listings", :force => true do |t|
    t.integer  "location_id"
    t.integer  "creator_id"
    t.string   "name"
    t.text     "description"
    t.string   "currency"
    t.integer  "price_cents",        :default => 0
    t.integer  "quantity",           :default => 1
    t.float    "rating_average",     :default => 0.0
    t.integer  "rating_count",       :default => 0
    t.text     "availability_rules"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.datetime "deleted_at"
  end

  create_table "location_amenities", :force => true do |t|
    t.integer  "amenity_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "location_id"
  end

  create_table "location_organizations", :force => true do |t|
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "location_id"
  end

  create_table "locations", :force => true do |t|
    t.integer  "company_id"
    t.integer  "creator_id"
    t.string   "name"
    t.string   "email"
    t.text     "description"
    t.string   "address"
    t.string   "phone"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "amenities"
    t.text     "info"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "deleted_at"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "logo"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "photos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "content_id"
    t.string   "image"
    t.string   "caption"
    t.string   "content_type"
    t.integer  "position"
    t.datetime "deleted_at"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "content_id"
    t.string   "content_type"
    t.integer  "user_id"
    t.float    "rating"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.datetime "deleted_at"
  end

  create_table "reservation_periods", :force => true do |t|
    t.integer  "reservation_id"
    t.integer  "listing_id"
    t.date     "date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "deleted_at"
  end

  create_table "reservation_seats", :force => true do |t|
    t.integer  "reservation_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "deleted_at"
  end

  create_table "reservations", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "owner_id"
    t.string   "state"
    t.string   "confirmation_email"
    t.integer  "total_amount_cents"
    t.string   "currency"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "deleted_at"
  end

  create_table "search_queries", :force => true do |t|
    t.string   "query"
    t.text     "agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "deleted_at"
  end

  add_index "user_relationships", ["followed_id"], :name => "index_user_relationships_on_followed_id"
  add_index "user_relationships", ["follower_id", "followed_id"], :name => "index_user_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "user_relationships", ["follower_id"], :name => "index_user_relationships_on_follower_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "password_salt",                         :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "admin"
    t.integer  "bookings_count",                        :default => 0,  :null => false
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.datetime "locked_at"
    t.datetime "reset_password_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "authentication_token"
    t.string   "avatar"
    t.string   "confirmation_token"
    t.string   "phone"
    t.string   "unconfirmed_email"
    t.string   "unlock_token"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description_html"
    t.text     "company_description_html"
    t.text     "url"
    t.string   "formatted_address"
    t.boolean  "fake",                     :default => false, :null => false
    t.integer  "bookings_count",           :default => 0,     :null => false
  end

end
