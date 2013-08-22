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

ActiveRecord::Schema.define(:version => 20130821014437) do

  create_table "amenities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "amenity_type_id"
  end

  add_index "amenities", ["amenity_type_id"], :name => "index_amenities_on_amenity_type_id"

  create_table "amenity_types", :force => true do |t|
    t.string   "name"
    t.integer  "position"
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

  create_table "availability_rules", :force => true do |t|
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "day"
    t.integer  "open_hour"
    t.integer  "open_minute"
    t.integer  "close_hour"
    t.integer  "close_minute"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "availability_rules", ["target_type", "target_id"], :name => "index_availability_rules_on_target_type_and_target_id"

  create_table "charges", :force => true do |t|
    t.integer  "reference_id"
    t.boolean  "success"
    t.text     "response"
    t.integer  "amount"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "user_id"
    t.string   "reference_type"
    t.string   "currency"
  end

  create_table "companies", :force => true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.string   "email"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "deleted_at"
    t.string   "url"
    t.string   "paypal_email"
    t.text     "mailing_address"
    t.string   "external_id"
    t.integer  "instance_id"
  end

  add_index "companies", ["instance_id"], :name => "index_companies_on_instance_id"

  create_table "company_industries", :id => false, :force => true do |t|
    t.integer "industry_id"
    t.integer "company_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "domains", ["instance_id"], :name => "index_domains_on_instance_id"

  create_table "industries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "inquiries", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "inquiring_user_id"
    t.text     "message"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "instance_themes", :force => true do |t|
    t.integer  "instance_id"
    t.string   "name"
    t.string   "compiled_stylesheet"
    t.string   "icon_image"
    t.string   "icon_retina_image"
    t.string   "logo_image"
    t.string   "logo_retina_image"
    t.string   "hero_image"
    t.string   "color_blue"
    t.string   "color_red"
    t.string   "color_orange"
    t.string   "color_green"
    t.string   "color_gray"
    t.string   "color_black"
    t.string   "color_white"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "instances", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "partner_id"
    t.string   "site_name"
    t.string   "description"
    t.string   "tagline"
    t.string   "support_email"
    t.string   "contact_email"
    t.string   "address"
    t.string   "phone_number"
    t.string   "support_url"
    t.string   "blog_url"
    t.string   "twitter_url"
    t.string   "facebook_url"
    t.string   "bookable_noun", :default => "Desk"
    t.string   "meta_title"
  end

  create_table "listing_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "listings", :force => true do |t|
    t.integer  "location_id"
    t.string   "name"
    t.text     "description"
    t.integer  "quantity",                :default => 1
    t.text     "availability_rules_text"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.datetime "deleted_at"
    t.boolean  "confirm_reservations",    :default => true,  :null => false
    t.boolean  "delta",                   :default => true,  :null => false
    t.integer  "listing_type_id"
    t.integer  "daily_price_cents"
    t.integer  "weekly_price_cents"
    t.integer  "monthly_price_cents"
    t.boolean  "hourly_reservations"
    t.integer  "hourly_price_cents"
    t.integer  "minimum_booking_minutes"
    t.string   "external_id"
    t.boolean  "free",                    :default => false
  end

  create_table "location_amenities", :force => true do |t|
    t.integer  "amenity_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "location_id"
  end

  create_table "location_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "locations", :force => true do |t|
    t.integer  "company_id"
    t.string   "email"
    t.text     "description"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "info"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "deleted_at"
    t.string   "formatted_address"
    t.string   "currency"
    t.text     "special_notes"
    t.text     "address_components"
    t.string   "street"
    t.string   "suburb"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "slug"
    t.integer  "location_type_id"
    t.string   "custom_page"
    t.string   "address2"
    t.string   "postcode"
  end

  add_index "locations", ["slug"], :name => "index_locations_on_slug"

  create_table "pages", :force => true do |t|
    t.string   "path",        :null => false
    t.text     "content"
    t.integer  "instance_id"
    t.string   "hero_image"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "partners", :force => true do |t|
    t.string   "name"
    t.decimal  "service_fee_percent", :precision => 5, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  create_table "payment_transfers", :force => true do |t|
    t.integer  "company_id"
    t.datetime "transferred_at"
    t.string   "currency"
    t.integer  "amount_cents",             :default => 0, :null => false
    t.integer  "service_fee_amount_cents", :default => 0, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "payment_transfers", ["company_id"], :name => "index_payment_transfers_on_company_id"

  create_table "photos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "content_id"
    t.string   "image"
    t.string   "caption"
    t.string   "content_type"
    t.integer  "position"
    t.datetime "deleted_at"
    t.integer  "creator_id"
    t.boolean  "versions_generated", :default => false, :null => false
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_h"
    t.integer  "crop_w"
    t.integer  "rotation_angle"
  end

  create_table "reservation_charges", :force => true do |t|
    t.integer  "reservation_id"
    t.integer  "subtotal_amount_cents"
    t.integer  "service_fee_amount_cents"
    t.datetime "paid_at"
    t.datetime "failed_at"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "currency"
    t.datetime "deleted_at"
    t.integer  "payment_transfer_id"
  end

  add_index "reservation_charges", ["payment_transfer_id"], :name => "index_reservation_charges_on_payment_transfer_id"
  add_index "reservation_charges", ["reservation_id"], :name => "index_reservation_charges_on_reservation_id"

  create_table "reservation_periods", :force => true do |t|
    t.integer  "reservation_id"
    t.date     "date"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "deleted_at"
    t.integer  "start_minute"
    t.integer  "end_minute"
  end

  create_table "reservation_seats", :force => true do |t|
    t.integer  "reservation_period_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.datetime "deleted_at"
  end

  create_table "reservations", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "owner_id"
    t.string   "state"
    t.string   "confirmation_email"
    t.integer  "subtotal_amount_cents"
    t.string   "currency"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.datetime "deleted_at"
    t.text     "comment"
    t.boolean  "create_charge"
    t.string   "payment_method",           :default => "manual",  :null => false
    t.string   "payment_status",           :default => "unknown", :null => false
    t.integer  "quantity",                 :default => 1,         :null => false
    t.integer  "service_fee_amount_cents"
    t.string   "rejection_reason"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "unit_prices", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "price_cents"
    t.integer  "period"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "user_industries", :id => false, :force => true do |t|
    t.integer "industry_id"
    t.integer "user_id"
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
    t.string   "email",                                                :default => "",    :null => false
    t.string   "encrypted_password",                    :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                                        :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "admin"
    t.integer  "bookings_count",                                       :default => 0,     :null => false
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.datetime "locked_at"
    t.datetime "reset_password_sent_at"
    t.integer  "failed_attempts",                                      :default => 0
    t.string   "authentication_token"
    t.string   "avatar"
    t.string   "confirmation_token"
    t.string   "phone"
    t.string   "unconfirmed_email"
    t.string   "unlock_token"
    t.string   "stripe_id"
    t.string   "job_title"
    t.text     "biography"
    t.datetime "mailchimp_synchronized_at"
    t.boolean  "verified",                                             :default => false
    t.string   "country_name"
    t.string   "mobile_number"
    t.integer  "instance_id"
    t.datetime "notified_about_mobile_number_issue_at"
    t.text     "referer"
    t.string   "source"
    t.string   "campaign"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["instance_id"], :name => "index_users_on_instance_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
