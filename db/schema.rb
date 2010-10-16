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

ActiveRecord::Schema.define(:version => 20101016105710) do

  create_table "bookings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workplace_id"
    t.text     "comment"
    t.string   "state"
    t.integer  "user_id"
    t.date     "date"
  end

  create_table "login_accounts", :force => true do |t|
    t.string   "type"
    t.integer  "user_id"
    t.string   "remote_account_id"
    t.string   "name"
    t.string   "login"
    t.string   "picture_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "login_accounts", ["type"], :name => "index_login_accounts_on_type"
  add_index "login_accounts", ["user_id"], :name => "index_login_accounts_on_user_id"

  create_table "photos", :force => true do |t|
    t.integer  "workplace_id", :null => false
    t.string   "description",  :null => false
    t.string   "file",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photos", ["workplace_id"], :name => "index_photos_on_workplace_id"

  create_table "users", :force => true do |t|
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

end
