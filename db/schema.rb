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

ActiveRecord::Schema.define(:version => 20140328093851) do



  create_table "amenities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "amenity_type_id"
  end

  add_index "amenities", ["amenity_type_id"], :name => "index_amenities_on_amenity_type_id"

  create_table "amenity_holders", :force => true do |t|
    t.integer  "amenity_id"
    t.integer  "holder_id"
    t.string   "holder_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "deleted_at"
  end

  add_index "amenity_holders", ["amenity_id"], :name => "index_amenity_holders_on_amenity_id"
  add_index "amenity_holders", ["holder_id", "holder_type"], :name => "index_amenity_holders_on_holder_id_and_holder_type"

  create_table "amenity_types", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "instance_id"
    t.string   "type"
  end

  add_index "amenity_types", ["instance_id"], :name => "index_amenity_types_on_instance_id"

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
    t.datetime "token_expires_at"
    t.boolean  "token_expired",            :default => true
    t.boolean  "token_expires",            :default => true
    t.text     "profile_url"
    t.integer  "total_social_connections", :default => 0
    t.integer  "instance_id"
    t.datetime "information_fetched"
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

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
    t.datetime "deleted_at"
  end

  add_index "availability_rules", ["target_type", "target_id"], :name => "index_availability_rules_on_target_type_and_target_id"

  create_table "blog_instances", :force => true do |t|
    t.string   "name"
    t.string   "header"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "facebook_app_id"
    t.boolean  "enabled",         :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "blog_posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "header"
    t.string   "author_name"
    t.text     "author_biography"
    t.string   "author_avatar"
    t.integer  "blog_instance_id"
    t.integer  "user_id"
    t.string   "slug"
    t.datetime "published_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "excerpt"
  end

  create_table "charges", :force => true do |t|
    t.integer  "reference_id"
    t.boolean  "success"
    t.integer  "amount"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "user_id"
    t.string   "reference_type"
    t.string   "currency"
    t.text     "encrypted_response"
    t.datetime "deleted_at"
  end

  add_index "charges", ["reference_id", "reference_type"], :name => "index_charges_on_reference_id_and_reference_type"

  create_table "companies", :force => true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.string   "email"
    t.text     "description"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.datetime "deleted_at"
    t.string   "url"
    t.string   "paypal_email"
    t.text     "mailing_address"
    t.string   "external_id"
    t.integer  "instance_id"
    t.boolean  "white_label_enabled", :default => false
    t.boolean  "listings_public",     :default => true
    t.integer  "partner_id"
    t.text     "metadata"
  end

  add_index "companies", ["creator_id"], :name => "index_companies_on_creator_id"
  add_index "companies", ["instance_id", "listings_public"], :name => "index_companies_on_instance_id_and_listings_public"
  add_index "companies", ["partner_id"], :name => "index_companies_on_partner_id"

  create_table "company_industries", :force => true do |t|
    t.integer  "industry_id"
    t.integer  "company_id"
    t.datetime "deleted_at"
  end

  add_index "company_industries", ["industry_id", "company_id"], :name => "index_company_industries_on_industry_id_and_company_id"

  create_table "company_users", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "deleted_at"
  end

  add_index "company_users", ["company_id"], :name => "index_company_users_on_company_id"
  add_index "company_users", ["user_id"], :name => "index_company_users_on_user_id"

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
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "deleted_at"
    t.boolean  "secured",     :default => false
  end

  add_index "domains", ["target_id", "target_type"], :name => "index_domains_on_target_id_and_target_type"

  create_table "email_templates", :force => true do |t|
    t.text     "html_body"
    t.text     "text_body"
    t.string   "path"
    t.string   "from"
    t.string   "to"
    t.string   "bcc"
    t.string   "reply_to"
    t.string   "subject"
    t.boolean  "partial",    :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "theme_id"
  end

  add_index "email_templates", ["theme_id"], :name => "index_email_templates_on_theme_id"

  create_table "footer_templates", :force => true do |t|
    t.text     "body"
    t.string   "path"
    t.boolean  "partial"
    t.integer  "theme_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "footer_templates", ["path", "partial", "theme_id"], :name => "index_footer_templates_on_path_and_partial_and_theme_id"
  add_index "footer_templates", ["theme_id"], :name => "index_footer_templates_on_theme_id"

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "guest_ratings", :force => true do |t|
    t.integer  "author_id",      :null => false
    t.integer  "subject_id"
    t.integer  "reservation_id"
    t.integer  "value"
    t.text     "comment"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "deleted_at"
  end

  add_index "guest_ratings", ["author_id"], :name => "index_guest_ratings_on_author_id"
  add_index "guest_ratings", ["reservation_id"], :name => "index_guest_ratings_on_reservation_id"
  add_index "guest_ratings", ["subject_id"], :name => "index_guest_ratings_on_subject_id"

  create_table "host_ratings", :force => true do |t|
    t.integer  "author_id",      :null => false
    t.integer  "subject_id"
    t.integer  "reservation_id"
    t.integer  "value"
    t.text     "comment"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "deleted_at"
  end

  add_index "host_ratings", ["author_id"], :name => "index_host_ratings_on_author_id"
  add_index "host_ratings", ["reservation_id"], :name => "index_host_ratings_on_reservation_id"
  add_index "host_ratings", ["subject_id"], :name => "index_host_ratings_on_subject_id"

  create_table "impressions", :force => true do |t|
    t.integer  "impressionable_id"
    t.string   "impressionable_type"
    t.string   "ip_address"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.datetime "deleted_at"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "instance_id"
  end

  add_index "impressions", ["company_id"], :name => "index_impressions_on_company_id"
  add_index "impressions", ["impressionable_type", "impressionable_id"], :name => "index_impressions_on_impressionable_type_and_impressionable_id"
  add_index "impressions", ["instance_id"], :name => "index_impressions_on_instance_id"
  add_index "impressions", ["partner_id"], :name => "index_impressions_on_partner_id"

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

  add_index "inquiries", ["inquiring_user_id"], :name => "index_inquiries_on_inquiring_user_id"
  add_index "inquiries", ["listing_id"], :name => "index_inquiries_on_listing_id"

  create_table "instance_admin_roles", :force => true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.boolean  "permission_settings",  :default => false
    t.boolean  "permission_theme",     :default => false
    t.boolean  "permission_analytics", :default => true
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.boolean  "permission_manage",    :default => false
    t.boolean  "permission_blog",      :default => false
  end

  add_index "instance_admin_roles", ["instance_id"], :name => "index_instance_admin_roles_on_instance_id"

  create_table "instance_admins", :force => true do |t|
    t.integer  "user_id"
    t.integer  "instance_id"
    t.integer  "instance_admin_role_id"
    t.boolean  "instance_owner",         :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.datetime "deleted_at"
  end

  add_index "instance_admins", ["instance_admin_role_id"], :name => "index_instance_admins_on_instance_admin_role_id"
  add_index "instance_admins", ["instance_id"], :name => "index_instance_admins_on_instance_id"
  add_index "instance_admins", ["user_id"], :name => "index_instance_admins_on_user_id"

  create_table "instance_billing_gateways", :force => true do |t|
    t.integer  "instance_id"
    t.string   "billing_gateway"
    t.string   "currency",        :default => "USD"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "instance_billing_gateways", ["instance_id"], :name => "index_instance_billing_gateways_on_instance_id"

  create_table "instance_clients", :force => true do |t|
    t.integer  "client_id"
    t.string   "client_type"
    t.integer  "instance_id"
    t.string   "encrypted_stripe_id"
    t.string   "encrypted_paypal_id"
    t.string   "encrypted_balanced_user_id"
    t.string   "encrypted_balanced_credit_card_id"
    t.string   "bank_account_last_four_digits"
    t.datetime "deleted_at"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "instance_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "instance_views", :force => true do |t|
    t.integer  "instance_type_id"
    t.integer  "instance_id"
    t.text     "body"
    t.string   "path"
    t.string   "locale"
    t.string   "format"
    t.string   "handler"
    t.boolean  "partial",          :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "instance_views", ["instance_type_id", "instance_id", "path", "locale", "format", "handler"], :name => "instance_path_with_format_and_handler"

  create_table "instances", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                                                            :null => false
    t.datetime "updated_at",                                                                            :null => false
    t.string   "bookable_noun",                                                     :default => "Desk"
    t.decimal  "service_fee_guest_percent",           :precision => 5, :scale => 2, :default => 0.0
    t.string   "lessor"
    t.string   "lessee"
    t.boolean  "skip_company",                                                      :default => false
    t.text     "pricing_options"
    t.boolean  "default_instance",                                                  :default => false
    t.decimal  "service_fee_host_percent",            :precision => 5, :scale => 2, :default => 0.0
    t.string   "live_stripe_public_key"
    t.string   "paypal_email"
    t.string   "encrypted_live_paypal_username"
    t.string   "encrypted_live_paypal_password"
    t.string   "encrypted_live_paypal_signature"
    t.string   "encrypted_live_paypal_app_id"
    t.string   "encrypted_live_paypal_client_id"
    t.string   "encrypted_live_paypal_client_secret"
    t.string   "encrypted_live_stripe_api_key"
    t.string   "encrypted_live_balanced_api_key"
    t.string   "encrypted_marketplace_password"
    t.integer  "min_hourly_price_cents"
    t.integer  "max_hourly_price_cents"
    t.integer  "min_daily_price_cents"
    t.integer  "max_daily_price_cents"
    t.integer  "min_weekly_price_cents"
    t.integer  "max_weekly_price_cents"
    t.integer  "min_monthly_price_cents"
    t.integer  "max_monthly_price_cents"
    t.boolean  "password_protected",                                                :default => false
    t.boolean  "test_mode",                                                         :default => false
    t.string   "encrypted_test_paypal_username"
    t.string   "encrypted_test_paypal_password"
    t.string   "encrypted_test_paypal_signature"
    t.string   "encrypted_test_paypal_app_id"
    t.string   "encrypted_test_paypal_client_id"
    t.string   "encrypted_test_paypal_client_secret"
    t.string   "encrypted_test_stripe_api_key"
    t.string   "test_stripe_public_key"
    t.string   "encrypted_test_balanced_api_key"
    t.string   "encrypted_olark_api_key"
    t.boolean  "olark_enabled",                                                     :default => false
    t.string   "encrypted_facebook_consumer_key"
    t.string   "encrypted_facebook_consumer_secret"
    t.string   "encrypted_linkedin_consumer_key"
    t.string   "encrypted_linkedin_consumer_secret"
    t.string   "encrypted_twitter_consumer_key"
    t.string   "encrypted_twitter_consumer_secret"
    t.string   "encrypted_instagram_consumer_key"
    t.string   "encrypted_instagram_consumer_secret"
    t.integer  "instance_type_id"
  end

  add_index "instances", ["instance_type_id"], :name => "index_instances_on_instance_type_id"

  create_table "listing_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "instance_id"
  end

  add_index "listing_types", ["instance_id"], :name => "index_listing_types_on_instance_id"

  create_table "listings", :force => true do |t|
    t.integer  "location_id"
    t.string   "name"
    t.text     "description"
    t.integer  "quantity",                    :default => 1
    t.text     "availability_rules_text"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.datetime "deleted_at"
    t.boolean  "confirm_reservations",        :default => true,  :null => false
    t.boolean  "delta",                       :default => true,  :null => false
    t.integer  "listing_type_id"
    t.integer  "daily_price_cents"
    t.integer  "weekly_price_cents"
    t.integer  "monthly_price_cents"
    t.boolean  "hourly_reservations"
    t.integer  "hourly_price_cents"
    t.integer  "minimum_booking_minutes"
    t.string   "external_id"
    t.boolean  "free",                        :default => false
    t.datetime "draft"
    t.boolean  "enabled",                     :default => true
    t.datetime "last_request_photos_sent_at"
    t.datetime "activated_at"
    t.integer  "rank",                        :default => 0
    t.integer  "capacity"
    t.integer  "photos_count",                :default => 0
    t.text     "metadata"
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.integer  "administrator_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.boolean  "listings_public",             :default => true
  end

  add_index "listings", ["administrator_id"], :name => "index_listings_on_administrator_id"
  add_index "listings", ["company_id"], :name => "index_listings_on_company_id"
  add_index "listings", ["creator_id"], :name => "index_listings_on_creator_id"
  add_index "listings", ["instance_id"], :name => "index_listings_on_instance_id"
  add_index "listings", ["listing_type_id"], :name => "index_listings_on_listing_type_id"
  add_index "listings", ["location_id"], :name => "index_listings_on_location_id"
  add_index "listings", ["partner_id"], :name => "index_listings_on_partner_id"

  create_table "location_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "instance_id"
  end

  add_index "location_types", ["instance_id"], :name => "index_location_types_on_instance_id"

  create_table "locations", :force => true do |t|
    t.integer  "company_id"
    t.string   "email"
    t.text     "description"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "info"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
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
    t.integer  "administrator_id"
    t.string   "name"
    t.text     "metadata"
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.boolean  "listings_public",    :default => true
    t.integer  "partner_id"
  end

  add_index "locations", ["administrator_id"], :name => "index_locations_on_administrator_id"
  add_index "locations", ["company_id"], :name => "index_locations_on_company_id"
  add_index "locations", ["creator_id"], :name => "index_locations_on_creator_id"
  add_index "locations", ["instance_id"], :name => "index_locations_on_instance_id"
  add_index "locations", ["location_type_id"], :name => "index_locations_on_location_type_id"
  add_index "locations", ["partner_id"], :name => "index_locations_on_partner_id"
  add_index "locations", ["slug"], :name => "index_locations_on_slug"

  create_table "mailer_unsubscriptions", :force => true do |t|
    t.integer  "user_id"
    t.string   "mailer"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "mailer_unsubscriptions", ["user_id", "mailer"], :name => "index_mailer_unsubscriptions_on_user_id_and_mailer", :unique => true
  add_index "mailer_unsubscriptions", ["user_id"], :name => "index_mailer_unsubscriptions_on_user_id"

  create_table "pages", :force => true do |t|
    t.string   "path",                                 :null => false
    t.text     "content"
    t.string   "hero_image"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "theme_id"
    t.string   "slug"
    t.integer  "position"
    t.text     "html_content"
    t.datetime "deleted_at"
    t.string   "redirect_url"
    t.boolean  "open_in_new_window", :default => true
  end

  add_index "pages", ["theme_id"], :name => "index_pages_on_theme_id"

  create_table "partner_inquiries", :force => true do |t|
    t.string   "name"
    t.string   "company_name"
    t.string   "email"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "partners", :force => true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "search_scope_option", :default => "no_scoping"
  end

  create_table "payment_transfers", :force => true do |t|
    t.integer  "company_id"
    t.datetime "transferred_at"
    t.string   "currency"
    t.integer  "amount_cents",                   :default => 0, :null => false
    t.integer  "service_fee_amount_guest_cents", :default => 0, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "service_fee_amount_host_cents",  :default => 0, :null => false
    t.datetime "deleted_at"
    t.integer  "instance_id"
    t.integer  "partner_id"
  end

  add_index "payment_transfers", ["company_id"], :name => "index_payment_transfers_on_company_id"
  add_index "payment_transfers", ["instance_id"], :name => "index_payment_transfers_on_instance_id"
  add_index "payment_transfers", ["partner_id"], :name => "index_payment_transfers_on_partner_id"

  create_table "payouts", :force => true do |t|
    t.integer  "reference_id"
    t.string   "reference_type"
    t.boolean  "success"
    t.text     "response"
    t.integer  "amount"
    t.string   "currency"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.text     "encrypted_response"
    t.datetime "deleted_at"
    t.boolean  "pending",            :default => false
  end

  create_table "photos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "listing_id"
    t.string   "image"
    t.string   "caption"
    t.integer  "position"
    t.datetime "deleted_at"
    t.integer  "creator_id"
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_h"
    t.integer  "crop_w"
    t.integer  "rotation_angle"
    t.integer  "width"
    t.integer  "height"
    t.text     "image_transformation_data"
    t.string   "image_original_url"
    t.datetime "image_versions_generated_at"
    t.integer  "image_original_height"
    t.integer  "image_original_width"
  end

  add_index "photos", ["creator_id"], :name => "index_photos_on_creator_id"
  add_index "photos", ["listing_id"], :name => "index_photos_on_listing_id"

  create_table "platform_contacts", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "subject"
    t.text     "comments"
    t.boolean  "subscribed", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "platform_demo_requests", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "company"
    t.string   "phone"
    t.text     "comments"
    t.boolean  "subscribed", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "platform_emails", :force => true do |t|
    t.string   "email"
    t.datetime "notified_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "platform_inquiries", :force => true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "industry"
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "refunds", :force => true do |t|
    t.integer  "reference_id"
    t.string   "reference_type"
    t.boolean  "success"
    t.text     "encrypted_response"
    t.integer  "amount"
    t.string   "currency"
    t.datetime "deleted_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "reservation_charges", :force => true do |t|
    t.integer  "reservation_id"
    t.integer  "subtotal_amount_cents"
    t.integer  "service_fee_amount_guest_cents"
    t.datetime "paid_at"
    t.datetime "failed_at"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "currency"
    t.datetime "deleted_at"
    t.integer  "payment_transfer_id"
    t.integer  "service_fee_amount_host_cents",  :default => 0, :null => false
    t.datetime "refunded_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
  end

  add_index "reservation_charges", ["company_id"], :name => "index_reservation_charges_on_company_id"
  add_index "reservation_charges", ["instance_id"], :name => "index_reservation_charges_on_instance_id"
  add_index "reservation_charges", ["partner_id"], :name => "index_reservation_charges_on_partner_id"
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

  add_index "reservation_periods", ["reservation_id"], :name => "index_reservation_periods_on_reservation_id"

  create_table "reservation_seats", :force => true do |t|
    t.integer  "reservation_period_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.datetime "deleted_at"
  end

  add_index "reservation_seats", ["reservation_period_id"], :name => "index_reservation_seats_on_reservation_period_id"
  add_index "reservation_seats", ["user_id"], :name => "index_reservation_seats_on_user_id"

  create_table "reservations", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "owner_id"
    t.string   "state"
    t.string   "confirmation_email"
    t.integer  "subtotal_amount_cents"
    t.string   "currency"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.datetime "deleted_at"
    t.text     "comment"
    t.boolean  "create_charge"
    t.string   "payment_method",                     :default => "manual",  :null => false
    t.string   "payment_status",                     :default => "unknown", :null => false
    t.integer  "quantity",                           :default => 1,         :null => false
    t.integer  "service_fee_amount_guest_cents"
    t.string   "rejection_reason"
    t.datetime "request_guest_rating_email_sent_at"
    t.datetime "request_host_rating_email_sent_at"
    t.integer  "service_fee_amount_host_cents",      :default => 0,         :null => false
    t.integer  "platform_context_detail_id"
    t.string   "platform_context_detail_type"
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.integer  "administrator_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.boolean  "listings_public",                    :default => true
  end

  add_index "reservations", ["administrator_id"], :name => "index_reservations_on_administrator_id"
  add_index "reservations", ["company_id"], :name => "index_reservations_on_company_id"
  add_index "reservations", ["creator_id"], :name => "index_reservations_on_creator_id"
  add_index "reservations", ["instance_id"], :name => "index_reservations_on_instance_id"
  add_index "reservations", ["listing_id"], :name => "index_reservations_on_listing_id"
  add_index "reservations", ["owner_id"], :name => "index_reservations_on_owner_id"
  add_index "reservations", ["partner_id"], :name => "index_reservations_on_partner_id"
  add_index "reservations", ["platform_context_detail_id"], :name => "index_reservations_on_platform_context_detail_id"

  create_table "search_notifications", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.string   "query"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "notified",   :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "search_notifications", ["user_id"], :name => "index_search_notifications_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "theme_fonts", :force => true do |t|
    t.integer  "theme_id"
    t.string   "regular_eot"
    t.string   "regular_svg"
    t.string   "regular_ttf"
    t.string   "regular_woff"
    t.string   "medium_eot"
    t.string   "medium_svg"
    t.string   "medium_ttf"
    t.string   "medium_woff"
    t.string   "bold_eot"
    t.string   "bold_svg"
    t.string   "bold_ttf"
    t.string   "bold_woff"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "theme_fonts", ["theme_id"], :name => "index_theme_fonts_on_theme_id"

  create_table "themes", :force => true do |t|
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
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "site_name"
    t.string   "description"
    t.string   "tagline"
    t.string   "support_email"
    t.string   "contact_email"
    t.string   "address"
    t.string   "meta_title"
    t.string   "phone_number"
    t.string   "support_url"
    t.string   "blog_url"
    t.string   "twitter_url"
    t.string   "facebook_url"
    t.string   "gplus_url"
    t.text     "homepage_content"
    t.string   "call_to_action"
    t.string   "favicon_image"
    t.text     "homepage_css"
    t.datetime "deleted_at"
    t.text     "icon_image_transformation_data"
    t.string   "icon_image_original_url"
    t.datetime "icon_image_versions_generated_at"
    t.integer  "icon_image_original_width"
    t.integer  "icon_image_original_height"
    t.text     "icon_retina_image_transformation_data"
    t.string   "icon_retina_image_original_url"
    t.datetime "icon_retina_image_versions_generated_at"
    t.integer  "icon_retina_image_original_width"
    t.integer  "icon_retina_image_original_height"
    t.text     "favicon_image_transformation_data"
    t.string   "favicon_image_original_url"
    t.datetime "favicon_image_versions_generated_at"
    t.integer  "favicon_image_original_width"
    t.integer  "favicon_image_original_height"
    t.text     "logo_image_transformation_data"
    t.string   "logo_image_original_url"
    t.datetime "logo_image_versions_generated_at"
    t.integer  "logo_image_original_width"
    t.integer  "logo_image_original_height"
    t.text     "logo_retina_image_transformation_data"
    t.string   "logo_retina_image_original_url"
    t.datetime "logo_retina_image_versions_generated_at"
    t.integer  "logo_retina_image_original_width"
    t.integer  "logo_retina_image_original_height"
    t.text     "hero_image_transformation_data"
    t.string   "hero_image_original_url"
    t.datetime "hero_image_versions_generated_at"
    t.integer  "hero_image_original_width"
    t.integer  "hero_image_original_height"
  end

  add_index "themes", ["owner_id", "owner_type"], :name => "index_themes_on_owner_id_and_owner_type"

  create_table "translations", :force => true do |t|
    t.string   "locale"
    t.string   "key"
    t.text     "value"
    t.text     "interpolations"
    t.boolean  "is_proc",        :default => false
    t.integer  "instance_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "translations", ["instance_id", "updated_at"], :name => "index_translations_on_instance_id_and_updated_at"

  create_table "unit_prices", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "price_cents"
    t.integer  "period"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "unit_prices", ["listing_id"], :name => "index_unit_prices_on_listing_id"

  create_table "user_industries", :force => true do |t|
    t.integer  "industry_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
  end

  add_index "user_industries", ["industry_id", "user_id"], :name => "index_user_industries_on_industry_id_and_user_id"

  create_table "user_messages", :force => true do |t|
    t.integer  "thread_owner_id"
    t.integer  "author_id",                                 :null => false
    t.integer  "thread_recipient_id"
    t.integer  "thread_context_id"
    t.string   "thread_context_type"
    t.text     "body"
    t.boolean  "archived_for_owner",     :default => false
    t.boolean  "archived_for_recipient", :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "read_for_owner",         :default => false
    t.boolean  "read_for_recipient",     :default => false
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  add_index "user_messages", ["instance_id"], :name => "index_user_messages_on_instance_id"

  create_table "user_relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.datetime "deleted_at"
    t.integer  "authentication_id"
  end

  add_index "user_relationships", ["authentication_id"], :name => "index_user_relationships_on_authentication_id"
  add_index "user_relationships", ["followed_id"], :name => "index_user_relationships_on_followed_id"
  add_index "user_relationships", ["follower_id", "followed_id", "deleted_at"], :name => "index_user_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "user_relationships", ["follower_id"], :name => "index_user_relationships_on_follower_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                                 :default => "",                                                                                  :null => false
    t.string   "encrypted_password",                     :limit => 128, :default => "",                                                                                  :null => false
    t.string   "password_salt",                                         :default => "",                                                                                  :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "admin"
    t.integer  "bookings_count",                                        :default => 0,                                                                                   :null => false
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.datetime "locked_at"
    t.datetime "reset_password_sent_at"
    t.integer  "failed_attempts",                                       :default => 0
    t.string   "authentication_token"
    t.string   "avatar"
    t.string   "confirmation_token"
    t.string   "phone"
    t.string   "unconfirmed_email"
    t.string   "unlock_token"
    t.string   "job_title"
    t.text     "biography"
    t.datetime "mailchimp_synchronized_at"
    t.string   "country_name"
    t.string   "mobile_number"
    t.datetime "notified_about_mobile_number_issue_at"
    t.text     "referer"
    t.string   "source"
    t.string   "campaign"
    t.datetime "verified_at"
    t.string   "google_analytics_id"
    t.string   "browser"
    t.string   "browser_version"
    t.string   "platform"
    t.float    "guest_rating_average"
    t.integer  "guest_rating_count"
    t.float    "host_rating_average"
    t.integer  "host_rating_count"
    t.text     "avatar_transformation_data"
    t.string   "avatar_original_url"
    t.datetime "avatar_versions_generated_at"
    t.integer  "avatar_original_height"
    t.integer  "avatar_original_width"
    t.text     "current_location"
    t.text     "company_name"
    t.text     "skills_and_interests"
    t.string   "slug"
    t.float    "last_geolocated_location_longitude"
    t.float    "last_geolocated_location_latitude"
    t.integer  "partner_id"
    t.integer  "instance_id"
    t.integer  "domain_id"
    t.string   "time_zone",                                             :default => "Pacific Time (US & Canada)"
    t.boolean  "sms_notifications_enabled",                             :default => true
    t.string   "sms_preferences",                                       :default => "---\nuser_message: true\nreservation_state_changed: true\nnew_reservation: true\n"
    t.text     "instance_unread_messages_threads_count",                :default => "--- {}\n"
    t.text     "metadata"
    t.string   "payment_token"
    t.boolean  "sso_log_out",                                           :default => false
  end

  add_index "users", ["deleted_at"], :name => "index_users_on_deleted_at"
  add_index "users", ["domain_id"], :name => "index_users_on_domain_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true, :where => "(deleted_at IS NULL)"
  add_index "users", ["instance_id"], :name => "index_users_on_instance_id"
  add_index "users", ["partner_id"], :name => "index_users_on_partner_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

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
