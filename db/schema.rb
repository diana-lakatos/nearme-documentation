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

ActiveRecord::Schema.define(:version => 20101016115959) do

  create_table "bookings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "workplace_id"
    t.text     "comment"
    t.string   "state"
    t.integer  "user_id"
    t.date     "date"
  end

  create_table "locations", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.string   "name"
    t.string   "street_address"
    t.string   "route"
    t.string   "intersection"
    t.string   "political"
    t.string   "country"
    t.string   "administrative_area_level_1"
    t.string   "administrative_area_level_2"
    t.string   "administrative_area_level_3"
    t.string   "colloquial_area"
    t.string   "locality"
    t.string   "sublocality"
    t.string   "neighborhood"
    t.string   "premise"
    t.string   "subpremise"
    t.string   "postal_code"
    t.string   "natural_feature"
    t.string   "airport"
    t.string   "park"
    t.string   "point_of_interest"
    t.string   "post_box"
    t.string   "street_number"
    t.string   "floor"
    t.string   "room"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["administrative_area_level_1"], :name => "index_locations_on_administrative_area_level_1"
  add_index "locations", ["administrative_area_level_2"], :name => "index_locations_on_administrative_area_level_2"
  add_index "locations", ["administrative_area_level_3"], :name => "index_locations_on_administrative_area_level_3"
  add_index "locations", ["airport"], :name => "index_locations_on_airport"
  add_index "locations", ["colloquial_area"], :name => "index_locations_on_colloquial_area"
  add_index "locations", ["country"], :name => "index_locations_on_country"
  add_index "locations", ["floor"], :name => "index_locations_on_floor"
  add_index "locations", ["intersection"], :name => "index_locations_on_intersection"
  add_index "locations", ["locality"], :name => "index_locations_on_locality"
  add_index "locations", ["name"], :name => "index_locations_on_name"
  add_index "locations", ["natural_feature"], :name => "index_locations_on_natural_feature"
  add_index "locations", ["neighborhood"], :name => "index_locations_on_neighborhood"
  add_index "locations", ["park"], :name => "index_locations_on_park"
  add_index "locations", ["point_of_interest"], :name => "index_locations_on_point_of_interest"
  add_index "locations", ["political"], :name => "index_locations_on_political"
  add_index "locations", ["post_box"], :name => "index_locations_on_post_box"
  add_index "locations", ["postal_code"], :name => "index_locations_on_postal_code"
  add_index "locations", ["premise"], :name => "index_locations_on_premise"
  add_index "locations", ["room"], :name => "index_locations_on_room"
  add_index "locations", ["route"], :name => "index_locations_on_route"
  add_index "locations", ["street_address"], :name => "index_locations_on_street_address"
  add_index "locations", ["street_number"], :name => "index_locations_on_street_number"
  add_index "locations", ["sublocality"], :name => "index_locations_on_sublocality"
  add_index "locations", ["subpremise"], :name => "index_locations_on_subpremise"

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
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
