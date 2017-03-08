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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170308155549) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "btree_gin"
  enable_extension "btree_gist"
  enable_extension "hstore"

  create_table "activity_feed_events", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "event"
    t.integer  "followed_id"
    t.string   "followed_type"
    t.text     "affected_objects_identifiers", default: [],                 array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_source_id"
    t.string   "event_source_type"
    t.boolean  "spam_ignored",                 default: false
    t.hstore   "flags",                        default: {},    null: false
  end

  add_index "activity_feed_events", ["event"], name: "index_activity_feed_events_on_event", using: :btree
  add_index "activity_feed_events", ["instance_id", "followed_id", "followed_type"], name: "activity_feed_events_instance_followed", using: :btree

  create_table "activity_feed_images", force: :cascade do |t|
    t.integer  "instance_id",                 null: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "uploader_id"
    t.string   "caption"
    t.string   "image"
    t.text     "image_transformation_data"
    t.integer  "image_original_width"
    t.integer  "image_original_height"
    t.datetime "image_versions_generated_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "activity_feed_subscriptions", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.string   "followed_type"
    t.string   "followed_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",              default: true
  end

  add_index "activity_feed_subscriptions", ["follower_id", "followed_id", "followed_type"], name: "afs_followers_followed", unique: true, using: :btree
  add_index "activity_feed_subscriptions", ["follower_id", "followed_identifier"], name: "index_subscriptions_on_folllower_and_followed_identifier", unique: true, using: :btree
  add_index "activity_feed_subscriptions", ["instance_id", "followed_id", "followed_type"], name: "activity_feed_subscriptions_instance_followed", using: :btree

  create_table "additional_charges", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.integer  "amount_cents"
    t.string   "currency",                  limit: 255
    t.string   "commission_receiver",       limit: 255
    t.string   "status",                    limit: 255
    t.integer  "additional_charge_type_id"
    t.integer  "instance_id"
    t.integer  "target_id"
    t.string   "target_type",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "additional_charges", ["additional_charge_type_id"], name: "index_additional_charges_on_additional_charge_type_id", using: :btree
  add_index "additional_charges", ["instance_id"], name: "index_additional_charges_on_instance_id", using: :btree
  add_index "additional_charges", ["target_id"], name: "index_additional_charges_on_target_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "address",            limit: 255
    t.string   "address2",           limit: 255
    t.string   "formatted_address",  limit: 255
    t.string   "street",             limit: 255
    t.string   "suburb",             limit: 255
    t.string   "city",               limit: 255
    t.string   "country",            limit: 255
    t.string   "state",              limit: 255
    t.string   "postcode",           limit: 10
    t.text     "address_components"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "entity_id"
    t.string   "entity_type",        limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "iso_country_code",   limit: 2
    t.boolean  "raw_address",                    default: false, null: false
  end

  add_index "addresses", ["instance_id", "entity_id", "entity_type", "address"], name: "index_addresses_on_entity_id_and_entity_type_and_address", unique: true, where: "(deleted_at IS NULL)", using: :btree

  create_table "amenities", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "amenity_type_id"
  end

  add_index "amenities", ["amenity_type_id"], name: "index_amenities_on_amenity_type_id", using: :btree

  create_table "amenity_holders", force: :cascade do |t|
    t.integer  "amenity_id"
    t.integer  "holder_id"
    t.string   "holder_type", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "deleted_at"
  end

  add_index "amenity_holders", ["amenity_id"], name: "index_amenity_holders_on_amenity_id", using: :btree
  add_index "amenity_holders", ["holder_id", "holder_type"], name: "index_amenity_holders_on_holder_id_and_holder_type", using: :btree

  create_table "amenity_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "position"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "instance_id"
    t.string   "type",        limit: 255
  end

  add_index "amenity_types", ["instance_id"], name: "index_amenity_types_on_instance_id", using: :btree
  add_index "amenity_types", ["name", "instance_id"], name: "index_amenity_types_on_name_and_instance_id", unique: true, using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.string   "token"
    t.datetime "expires_at"
  end

  add_index "api_keys", ["instance_id", "token"], name: "index_api_keys_on_instance_id_and_token", unique: true, using: :btree

  create_table "approval_request_attachment_templates", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "approval_request_template_id"
    t.boolean  "required",                                 default: false
    t.string   "label",                        limit: 255
    t.text     "hint"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_request_attachments", force: :cascade do |t|
    t.string   "caption",                                 limit: 255
    t.integer  "instance_id"
    t.integer  "uploader_id"
    t.string   "file",                                    limit: 255
    t.text     "comment"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "approval_request_id"
    t.integer  "approval_request_attachment_template_id"
    t.boolean  "required",                                            default: false
    t.string   "label",                                   limit: 255
    t.text     "hint"
  end

  add_index "approval_request_attachments", ["instance_id"], name: "index_approval_request_attachments_on_instance_id", using: :btree
  add_index "approval_request_attachments", ["uploader_id"], name: "index_approval_request_attachments_on_uploader_id", using: :btree

  create_table "approval_request_templates", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "owner_type",                    limit: 255
    t.boolean  "required_written_verification",             default: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_requests", force: :cascade do |t|
    t.string   "state",                         limit: 255
    t.string   "message",                       limit: 255
    t.text     "notes"
    t.integer  "instance_id"
    t.integer  "approval_request_template_id"
    t.integer  "owner_id"
    t.string   "owner_type",                    limit: 255
    t.boolean  "required_written_verification"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "draft_at"
  end

  add_index "approval_requests", ["owner_id", "owner_type"], name: "index_approval_requests_on_owner_id_and_owner_type", using: :btree

  create_table "assigned_waiver_agreement_templates", force: :cascade do |t|
    t.integer  "target_id"
    t.string   "target_type",                  limit: 255
    t.integer  "waiver_agreement_template_id"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assigned_waiver_agreement_templates", ["target_id", "target_type"], name: "awat_target_id_and_target_type", using: :btree
  add_index "assigned_waiver_agreement_templates", ["waiver_agreement_template_id"], name: "awat_wat_id", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "type",            limit: 255
    t.string   "file",            limit: 255
    t.integer  "attachable_id"
    t.string   "attachable_type", limit: 255
    t.integer  "instance_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type", using: :btree
  add_index "attachments", ["instance_id"], name: "index_attachments_on_instance_id", using: :btree
  add_index "attachments", ["user_id"], name: "index_attachments_on_user_id", using: :btree

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider",                 limit: 255
    t.string   "uid",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "secret",                   limit: 255
    t.string   "token",                    limit: 255
    t.text     "info"
    t.datetime "token_expires_at"
    t.boolean  "token_expired",                        default: true
    t.boolean  "token_expires",                        default: true
    t.text     "profile_url"
    t.integer  "total_social_connections",             default: 0
    t.integer  "instance_id"
    t.datetime "information_fetched"
  end

  add_index "authentications", ["instance_id", "provider", "user_id"], name: "one_provider_type_per_user_index", unique: true, using: :btree
  add_index "authentications", ["instance_id", "uid", "provider"], name: "one_active_provider_uid_pair_per_marketplace", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "availability_rules", force: :cascade do |t|
    t.string   "target_type",  limit: 255
    t.integer  "target_id"
    t.integer  "day"
    t.integer  "open_hour"
    t.integer  "open_minute"
    t.integer  "close_hour"
    t.integer  "close_minute"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.datetime "deleted_at"
    t.integer  "days",                     default: [],              array: true
    t.integer  "instance_id"
  end

  add_index "availability_rules", ["target_type", "target_id"], name: "index_availability_rules_on_target_type_and_target_id", using: :btree

  create_table "availability_templates", force: :cascade do |t|
    t.integer  "transactable_type_id"
    t.integer  "instance_id"
    t.string   "name",                 limit: 255
    t.string   "description",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "parent_id"
    t.string   "parent_type"
  end

  add_index "availability_templates", ["instance_id", "transactable_type_id"], name: "availability_templates_on_instance_id_and_tt_id", using: :btree
  add_index "availability_templates", ["parent_type", "parent_id"], name: "index_availability_templates_on_parent_type_and_parent_id", using: :btree

  create_table "aws_certificates", force: :cascade do |t|
    t.integer  "instance_id",      null: false
    t.string   "name",             null: false
    t.datetime "elb_uploaded_at"
    t.string   "status"
    t.string   "arn"
    t.string   "certificate_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.integer  "instance_client_id"
    t.integer  "instance_id",                          null: false
    t.datetime "deleted_at"
    t.text     "encrypted_response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_gateway_id"
    t.integer  "payment_method_id"
    t.boolean  "test_mode",             default: true
    t.string   "last4"
    t.string   "status"
    t.string   "bank_name"
    t.string   "encrypted_external_id"
  end

  create_table "billing_authorizations", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "reservation_id"
    t.string   "encrypted_token",                 limit: 255
    t.string   "encrypted_payment_gateway_class", limit: 255
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "payment_gateway_mode",            limit: 255
    t.string   "reference_type",                  limit: 255
    t.integer  "reference_id"
    t.boolean  "success",                                     default: false
    t.text     "encrypted_response"
    t.integer  "user_id"
    t.datetime "void_at"
    t.text     "void_response"
    t.integer  "payment_gateway_id"
    t.boolean  "immediate_payout",                            default: false
    t.integer  "merchant_account_id"
    t.integer  "payment_id"
  end

  add_index "billing_authorizations", ["payment_id"], name: "index_billing_authorizations_on_payment_id", using: :btree
  add_index "billing_authorizations", ["reference_id", "reference_type"], name: "index_billing_authorizations_on_reference_id_and_reference_type", using: :btree

  create_table "blog_instances", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "header",             limit: 255
    t.integer  "owner_id"
    t.string   "owner_type",         limit: 255
    t.string   "facebook_app_id",    limit: 255
    t.boolean  "enabled",                        default: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "header_logo",        limit: 255
    t.string   "header_icon",        limit: 255
    t.string   "header_text",        limit: 255
    t.string   "header_motto",       limit: 255
    t.boolean  "allow_video_embeds",             default: false
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string   "title",                               limit: 255
    t.text     "content"
    t.string   "header",                              limit: 255
    t.string   "author_name",                         limit: 255
    t.text     "author_biography"
    t.string   "author_avatar",                       limit: 255
    t.integer  "blog_instance_id"
    t.integer  "user_id"
    t.string   "slug",                                limit: 255
    t.datetime "published_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.text     "excerpt"
    t.datetime "author_avatar_versions_generated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.integer  "position",                             default: 0
    t.integer  "instance_id"
    t.integer  "partner_id"
    t.integer  "parent_id"
    t.string   "permalink",                limit: 255
    t.string   "categorizable_type",       limit: 255
    t.integer  "categorizable_id"
    t.datetime "deleted_at"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "multiple_root_categories"
    t.text     "display_options"
    t.text     "search_options"
    t.boolean  "mandatory"
    t.boolean  "shared_with_users"
  end

  add_index "categories", ["categorizable_id"], name: "index_categories_on_categorizable_id", using: :btree
  add_index "categories", ["instance_id"], name: "index_categories_on_instance_id", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["partner_id"], name: "index_categories_on_partner_id", using: :btree

  create_table "categories_categorizables", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "categorizable_id"
    t.string   "categorizable_type", limit: 255
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories_categorizables", ["category_id"], name: "index_categories_categorizables_on_category_id", using: :btree
  add_index "categories_categorizables", ["instance_id", "categorizable_id", "categorizable_type"], name: "poly_categorizables", using: :btree

  create_table "category_linkings", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "category_linkable_id"
    t.string   "category_linkable_type"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "category_linkings", ["instance_id", "category_linkable_id", "category_linkable_type", "category_id"], name: "index_category_linkings_on_instance_id_linkable_unique", unique: true, using: :btree

  create_table "charge_types", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.text     "description"
    t.integer  "amount_cents"
    t.string   "currency",                limit: 255
    t.string   "commission_receiver",     limit: 255
    t.string   "status",                  limit: 255
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "charge_type_target_id"
    t.string   "charge_type_target_type"
    t.integer  "percent"
    t.datetime "deleted_at"
    t.string   "type"
    t.string   "charge_event"
  end

  add_index "charge_types", ["charge_type_target_id", "charge_type_target_type"], name: "act_target", using: :btree
  add_index "charge_types", ["instance_id"], name: "index_charge_types_on_instance_id", using: :btree

  create_table "charges", force: :cascade do |t|
    t.integer  "payment_id"
    t.boolean  "success"
    t.integer  "amount"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "user_id"
    t.string   "currency",             limit: 255
    t.text     "encrypted_response"
    t.datetime "deleted_at"
    t.integer  "instance_id"
    t.integer  "payment_gateway_id"
    t.string   "payment_gateway_mode", limit: 4
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",             limit: 255, null: false
    t.string   "data_content_type",          limit: 255
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",             limit: 30
    t.string   "type",                       limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "instance_id"
    t.string   "access_level",               limit: 255
    t.integer  "user_id"
    t.string   "title"
    t.datetime "data_versions_generated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree
  add_index "ckeditor_assets", ["instance_id"], name: "index_ckeditor_assets_on_instance_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "body"
    t.string   "title"
    t.integer  "creator_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "spam_ignored",     default: false
  end

  add_index "comments", ["creator_id"], name: "index_comments_on_creator_id", using: :btree
  add_index "comments", ["instance_id", "commentable_id", "commentable_type"], name: "index_on_commentable", using: :btree

  create_table "communications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "provider_key"
    t.string   "phone_number"
    t.string   "phone_number_key"
    t.string   "request_key"
    t.boolean  "verified",         default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "community_reporting_aggregates", force: :cascade do |t|
    t.datetime "start_date",               null: false
    t.datetime "end_date",                 null: false
    t.integer  "instance_id",              null: false
    t.hstore   "statistics",  default: {}, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "community_reporting_aggregates", ["instance_id", "start_date", "end_date"], name: "index_community_reporting_aggregates_on_dates", unique: true, using: :btree

  create_table "companies", force: :cascade do |t|
    t.integer  "creator_id"
    t.string   "name",                limit: 255
    t.string   "email",               limit: 255
    t.text     "description"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.datetime "deleted_at"
    t.string   "url",                 limit: 255
    t.string   "paypal_email",        limit: 255
    t.text     "mailing_address"
    t.string   "external_id",         limit: 255
    t.integer  "instance_id"
    t.boolean  "white_label_enabled",             default: false
    t.boolean  "listings_public",                 default: true
    t.integer  "partner_id"
    t.text     "metadata"
    t.integer  "mailing_address_id"
  end

  add_index "companies", ["creator_id"], name: "index_companies_on_creator_id", using: :btree
  add_index "companies", ["external_id", "instance_id"], name: "companies_external_id_uni_idx", unique: true, where: "((external_id IS NOT NULL) AND (deleted_at IS NULL))", using: :btree
  add_index "companies", ["instance_id", "listings_public"], name: "index_companies_on_instance_id_and_listings_public", using: :btree
  add_index "companies", ["partner_id"], name: "index_companies_on_partner_id", using: :btree

  create_table "company_industries", force: :cascade do |t|
    t.integer  "industry_id"
    t.integer  "company_id"
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  add_index "company_industries", ["industry_id", "company_id"], name: "index_company_industries_on_industry_id_and_company_id", using: :btree

  create_table "company_users", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  add_index "company_users", ["company_id"], name: "index_company_users_on_company_id", using: :btree
  add_index "company_users", ["user_id"], name: "index_company_users_on_user_id", using: :btree

  create_table "content_holders", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "theme_id"
    t.integer  "instance_id"
    t.text     "content"
    t.boolean  "enabled",                  default: true
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "inject_pages",             default: [],   array: true
    t.string   "position",     limit: 255
  end

  add_index "content_holders", ["instance_id", "theme_id", "name"], name: "index_content_holders_on_instance_id_and_theme_id_and_name", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "iso_name",        limit: 255
    t.string   "iso",             limit: 255
    t.string   "iso3",            limit: 255
    t.string   "name",            limit: 255
    t.integer  "numcode"
    t.boolean  "states_required",             default: false
    t.datetime "updated_at"
    t.string   "calling_code"
  end

  add_index "countries", ["iso"], name: "index_countries_on_iso", unique: true, using: :btree
  add_index "countries", ["name"], name: "index_countries_on_name", using: :btree

  create_table "countries_shipping_rules", id: false, force: :cascade do |t|
    t.integer "country_id",       null: false
    t.integer "shipping_rule_id", null: false
  end

  add_index "countries_shipping_rules", ["country_id", "shipping_rule_id"], name: "country_shipping_rule_idx", using: :btree
  add_index "countries_shipping_rules", ["shipping_rule_id", "country_id"], name: "shipping_rule_country_idx", using: :btree

  create_table "country_payment_gateways", force: :cascade do |t|
    t.string   "country_alpha2_code", limit: 255
    t.integer  "payment_gateway_id"
    t.integer  "instance_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "credit_cards", force: :cascade do |t|
    t.integer  "instance_client_id"
    t.integer  "instance_id",                                   null: false
    t.datetime "deleted_at"
    t.string   "gateway_class",      limit: 255
    t.text     "encrypted_response"
    t.boolean  "default_card"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_gateway_id"
    t.boolean  "test_mode",                      default: true
    t.integer  "payment_method_id"
  end

  add_index "credit_cards", ["instance_client_id"], name: "index_credit_cards_on_instance_client_id", using: :btree
  add_index "credit_cards", ["instance_id"], name: "index_credit_cards_on_instance_id", using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string  "symbol"
    t.integer "priority"
    t.boolean "symbol_first"
    t.string  "thousands_separator"
    t.string  "html_entity"
    t.string  "decimal_mark"
    t.string  "name"
    t.integer "subunit_to_unit"
    t.float   "exponent"
    t.string  "iso_code"
    t.integer "iso_numeric"
    t.string  "subunit"
    t.integer "smallest_denomination"
  end

  add_index "currencies", ["iso_code"], name: "index_currencies_on_iso_code", using: :btree

  create_table "custom_attributes", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.integer  "instance_id"
    t.integer  "transactable_type_id"
    t.string   "attribute_type",            limit: 255
    t.string   "html_tag",                  limit: 255
    t.string   "prompt",                    limit: 255
    t.string   "default_value",             limit: 255
    t.boolean  "public",                                default: true
    t.text     "validation_rules"
    t.text     "valid_values"
    t.datetime "deleted_at"
    t.text     "label"
    t.text     "input_html_options"
    t.text     "wrapper_html_options"
    t.text     "hint"
    t.string   "placeholder",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "target_id"
    t.string   "target_type",               limit: 255
    t.boolean  "searchable",                            default: false
    t.boolean  "validation_only_on_update",             default: false
    t.boolean  "search_in_query",                       default: false, null: false
    t.hstore   "properties",                            default: {},    null: false
    t.boolean  "aggregate_in_search",                   default: false
    t.string   "placeholder_image"
    t.string   "type"
    t.text     "settings",                              default: "{}",  null: false
  end

  add_index "custom_attributes", ["instance_id", "transactable_type_id"], name: "index_tta_on_instance_id_and_transactable_type_id", using: :btree
  add_index "custom_attributes", ["name", "target_id", "target_type", "deleted_at"], name: "index_custom_attributes_on_name_and_target_and_type_and_deleted", unique: true, using: :btree
  add_index "custom_attributes", ["target_id", "target_type"], name: "index_custom_attributes_on_target_id_and_target_type", using: :btree

  create_table "custom_images", force: :cascade do |t|
    t.integer  "instance_id",                 null: false
    t.integer  "custom_attribute_id",         null: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "uploader_id"
    t.string   "image"
    t.text     "image_transformation_data"
    t.integer  "image_original_width"
    t.integer  "image_original_height"
    t.datetime "image_versions_generated_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "custom_images", ["instance_id", "custom_attribute_id"], name: "index_custom_images_on_instance_id_and_custom_attribute_id", using: :btree
  add_index "custom_images", ["owner_id", "owner_type"], name: "index_custom_images_on_owner_id_and_owner_type", using: :btree

  create_table "custom_model_type_linkings", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "custom_model_type_id"
    t.integer  "linkable_id"
    t.string   "linkable_type"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "custom_model_type_linkings", ["instance_id", "custom_model_type_id"], name: "instance_custom_model_index", using: :btree
  add_index "custom_model_type_linkings", ["instance_id", "linkable_id", "linkable_type"], name: "instance_linkable_index", using: :btree

  create_table "custom_model_types", force: :cascade do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "custom_model_types", ["deleted_at", "instance_id"], name: "index_custom_model_types_on_deleted_at_and_instance_id", using: :btree
  add_index "custom_model_types", ["name", "deleted_at", "instance_id"], name: "index_custom_model_types_on_name_and_deleted_at_and_instance_id", unique: true, using: :btree

  create_table "custom_theme_assets", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "custom_theme_id"
    t.string   "name"
    t.text     "comment"
    t.string   "file"
    t.string   "external_url"
    t.text     "body"
    t.datetime "deleted_at"
    t.hstore   "settings"
    t.string   "type"
    t.datetime "file_updated_at"
  end

  add_index "custom_theme_assets", ["instance_id", "custom_theme_id", "name"], name: "cta_on_instance_id_theme_and_name_uniq", unique: true, where: "(deleted_at IS NULL)", using: :btree

  create_table "custom_themes", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "themeable_id"
    t.string   "themeable_type"
    t.string   "name"
    t.boolean  "in_use",                     default: false
    t.datetime "deleted_at"
    t.boolean  "in_use_for_instance_admins"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_themes", ["instance_id", "themeable_id", "themeable_type"], name: "instance_id_and_themeable", using: :btree

  create_table "custom_validators", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "validatable_type",          limit: 255
    t.integer  "validatable_id"
    t.string   "field_name",                limit: 255
    t.text     "validation_rules"
    t.text     "valid_values"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "regex_validation",                      default: false, null: false
    t.string   "regex_expression"
    t.boolean  "validation_only_on_update",             default: false
  end

  add_index "custom_validators", ["instance_id", "validatable_type", "validatable_id"], name: "index_custom_validators_on_i_id_and_v_type_and_v_id", using: :btree

  create_table "customizations", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "custom_model_type_id"
    t.string   "customizable_type"
    t.integer  "customizable_id"
    t.hstore   "properties"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "customizations", ["instance_id", "customizable_id", "customizable_type"], name: "instance_customizable_index", using: :btree

  create_table "data_source_contents", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "data_source_id"
    t.hstore   "content"
    t.string   "external_id"
    t.datetime "externally_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "json_content",          default: {}
    t.text     "fields",                default: [],    array: true
    t.boolean  "mark_for_deletion",     default: false
  end

  add_index "data_source_contents", ["instance_id", "data_source_id"], name: "index_data_source_contents_on_instance_id_and_data_source_id", using: :btree

  create_table "data_sources", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "data_sourcable_id"
    t.string   "data_sourcable_type"
    t.string   "type"
    t.text     "settings"
    t.text     "fields",               default: [], array: true
    t.datetime "deleted_at"
    t.datetime "last_synchronized_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label"
  end

  add_index "data_sources", ["instance_id", "data_sourcable_id", "data_sourcable_type"], name: "index_data_sources_on_data_sourcable", using: :btree

  create_table "data_uploads", force: :cascade do |t|
    t.string   "csv_file",            limit: 255
    t.string   "xml_file",            limit: 255
    t.text     "options"
    t.text     "parsing_result_log"
    t.text     "encountered_error"
    t.text     "parse_summary"
    t.datetime "imported_at"
    t.integer  "instance_id"
    t.integer  "uploader_id"
    t.integer  "importable_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "target_id"
    t.string   "target_type",         limit: 255
    t.integer  "progress_percentage"
    t.string   "state",               limit: 255
    t.string   "importable_type",     limit: 255
  end

  add_index "data_uploads", ["importable_id", "importable_type"], name: "index_data_uploads_on_importable_id_and_importable_type", using: :btree
  add_index "data_uploads", ["instance_id"], name: "index_data_uploads_on_instance_id", using: :btree
  add_index "data_uploads", ["target_id", "target_type"], name: "index_data_uploads_on_target_id_and_target_type", using: :btree

  create_table "default_images", force: :cascade do |t|
    t.integer  "theme_id"
    t.integer  "instance_id"
    t.string   "photo_uploader"
    t.string   "photo_uploader_version"
    t.string   "photo_uploader_image"
    t.text     "photo_uploader_image_transformation_data"
    t.string   "photo_uploader_image_original_url"
    t.datetime "photo_uploader_image_versions_generated_at"
    t.integer  "photo_uploader_image_original_width"
    t.integer  "photo_uploader_image_original_height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "default_images", ["instance_id"], name: "index_default_images_on_instance_id", using: :btree
  add_index "default_images", ["theme_id"], name: "index_default_images_on_theme_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",                                 default: 20
    t.integer  "attempts",                                 default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",                    limit: 255
    t.string   "queue",                        limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "instance_id",                  limit: 255
    t.string   "platform_context_detail_type", limit: 255
    t.integer  "platform_context_detail_id"
    t.string   "i18n_locale",                  limit: 2
  end

  add_index "delayed_jobs", ["platform_context_detail_id", "platform_context_detail_type"], name: "index_delayed_jobs_on_platform_context_detail", using: :btree
  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deliveries", force: :cascade do |t|
    t.integer  "order_id",               null: false
    t.date     "pickup_date",            null: false
    t.integer  "sender_address_id",      null: false
    t.integer  "receiver_address_id",    null: false
    t.string   "courier"
    t.string   "state"
    t.string   "notes"
    t.string   "order_reference"
    t.string   "tracking_url"
    t.string   "tracking_reference"
    t.datetime "deleted_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "instance_id"
    t.integer  "dimensions_template_id"
  end

  add_index "deliveries", ["instance_id", "dimensions_template_id"], name: "index_deliveries_on_instance_id_and_dimensions_template_id", using: :btree

  create_table "deposits", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "deposit_amount_cents"
    t.datetime "authorized_at"
    t.datetime "voided_at"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "deposits", ["instance_id", "target_id", "target_type"], name: "index_deposits_on_instance_id_and_target_id_and_target_type", using: :btree
  add_index "deposits", ["instance_id"], name: "index_deposits_on_instance_id", using: :btree

  create_table "dimensions_templates", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.integer  "creator_id"
    t.integer  "instance_id"
    t.decimal  "weight",                           precision: 8, scale: 2
    t.decimal  "height",                           precision: 8, scale: 2
    t.decimal  "width",                            precision: 8, scale: 2
    t.decimal  "depth",                            precision: 8, scale: 2
    t.string   "unit_of_measure",      limit: 255,                         default: "imperial"
    t.string   "weight_unit",          limit: 255,                         default: "oz"
    t.string   "height_unit",          limit: 255,                         default: "in"
    t.string   "width_unit",           limit: 255,                         default: "in"
    t.string   "depth_unit",           limit: 255,                         default: "in"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "details"
    t.datetime "deleted_at"
    t.boolean  "use_as_default",                                           default: false
    t.integer  "entity_id"
    t.string   "entity_type",          limit: 255
    t.string   "shippo_id"
    t.string   "description"
    t.integer  "shipping_provider_id"
  end

  create_table "document_requirements", force: :cascade do |t|
    t.string   "label",       limit: 255
    t.text     "description"
    t.integer  "item_id"
    t.string   "item_type",   limit: 255
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "document_requirements", ["deleted_at"], name: "index_document_requirements_on_deleted_at", using: :btree
  add_index "document_requirements", ["instance_id"], name: "index_document_requirements_on_instance_id", using: :btree
  add_index "document_requirements", ["item_id", "item_type"], name: "index_document_requirements_on_item_id_and_item_type", using: :btree

  create_table "documents_uploads", force: :cascade do |t|
    t.boolean  "enabled",                 default: false
    t.string   "requirement", limit: 255
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", force: :cascade do |t|
    t.string   "name",                           limit: 255
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "target_id"
    t.string   "target_type",                    limit: 255
    t.datetime "deleted_at"
    t.boolean  "secured",                                    default: false
    t.string   "google_analytics_tracking_code", limit: 255
    t.string   "state",                          limit: 255
    t.string   "load_balancer_name",             limit: 255
    t.string   "server_certificate_name",        limit: 255
    t.string   "error_message",                  limit: 255
    t.string   "dns_name",                       limit: 255
    t.string   "redirect_to",                    limit: 255
    t.integer  "redirect_code"
    t.boolean  "use_as_default",                             default: false
    t.boolean  "sitemap_enabled",                            default: false
    t.string   "generated_sitemap",              limit: 255
    t.string   "uploaded_sitemap",               limit: 255
    t.string   "uploaded_robots_txt",            limit: 255
    t.integer  "instance_id"
    t.integer  "aws_certificate_id"
  end

  add_index "domains", ["deleted_at"], name: "index_domains_on_deleted_at", using: :btree
  add_index "domains", ["name"], name: "index_domains_on_name", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "domains", ["target_id", "target_type"], name: "index_domains_on_target_id_and_target_type", using: :btree

  create_table "external_api_requests", force: :cascade do |t|
    t.integer  "context_id"
    t.string   "context_type"
    t.text     "body"
    t.integer  "instance_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "external_api_requests", ["instance_id"], name: "index_external_api_requests_on_instance_id", using: :btree

  create_table "form_components", force: :cascade do |t|
    t.string   "name",                          limit: 255
    t.string   "form_type",                     limit: 255
    t.integer  "instance_id"
    t.integer  "form_componentable_id"
    t.text     "form_fields"
    t.datetime "deleted_at"
    t.integer  "rank"
    t.string   "form_componentable_type",       limit: 255
    t.boolean  "is_approval_request_surfacing",             default: false
    t.string   "ui_version"
  end

  add_index "form_components", ["instance_id", "form_componentable_id", "form_type"], name: "ttfs_instance_tt_form_type", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",               null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
    t.string   "scope",          limit: 255
    t.datetime "deleted_at"
  end

  add_index "friendly_id_slugs", ["deleted_at"], name: "index_friendly_id_slugs_on_deleted_at", using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "graph_queries", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "name"
    t.text     "query_string"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "graph_queries", ["instance_id"], name: "index_graph_queries_on_instance_id", using: :btree

  create_table "group_members", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "email"
    t.boolean  "moderator",            default: false
    t.datetime "approved_by_owner_at"
    t.datetime "approved_by_user_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id", using: :btree
  add_index "group_members", ["instance_id"], name: "index_group_members_on_instance_id", using: :btree
  add_index "group_members", ["user_id"], name: "index_group_members_on_user_id", using: :btree

  create_table "group_projects", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "group_id"
    t.integer  "project_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "group_transactables", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "group_id"
    t.integer  "transactable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.hstore   "properties",                        default: {}
    t.datetime "deleted_at"
    t.integer  "transactable_type_id"
    t.string   "cover_image"
    t.text     "image_transformation_data"
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.boolean  "featured",                          default: false
    t.datetime "draft_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "cover_image_versions_generated_at"
    t.integer  "members_count",                     default: 0,     null: false
  end

  add_index "groups", ["instance_id", "creator_id"], name: "index_groups_on_instance_id_and_creator_id", using: :btree

  create_table "help_contents", force: :cascade do |t|
    t.string   "slug",       null: false
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "help_contents", ["slug"], name: "index_help_contents_on_slug", unique: true, using: :btree

  create_table "host_fee_line_items", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "line_item_source_id"
    t.string   "line_item_source_type"
    t.integer  "line_itemable_id"
    t.string   "line_itemable_type"
    t.integer  "unit_price_cents",      default: 0
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "host_fee_line_items", ["instance_id"], name: "index_host_fee_line_items_on_instance_id", using: :btree
  add_index "host_fee_line_items", ["line_item_source_id"], name: "index_host_fee_line_items_on_line_item_source_id", using: :btree
  add_index "host_fee_line_items", ["line_itemable_id"], name: "index_host_fee_line_items_on_line_itemable_id", using: :btree

  create_table "host_line_items", force: :cascade do |t|
    t.integer  "instance_id"
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

  create_table "impressions", force: :cascade do |t|
    t.integer  "impressionable_id"
    t.string   "impressionable_type", limit: 255
    t.string   "ip_address",          limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "deleted_at"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "instance_id"
  end

  add_index "impressions", ["created_at"], name: "index_impressions_on_created_at", using: :btree
  add_index "impressions", ["instance_id", "impressionable_id", "impressionable_type"], name: "index_impressions_scope", using: :btree

  create_table "inappropriate_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "instance_id"
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.datetime "deleted_at"
    t.string   "ip_address"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.text     "reason"
  end

  add_index "inappropriate_reports", ["instance_id", "reportable_id", "reportable_type"], name: "inappropriate_reports_instance_reportable", using: :btree
  add_index "inappropriate_reports", ["reportable_id"], name: "index_inappropriate_reports_on_reportable_id", using: :btree
  add_index "inappropriate_reports", ["user_id"], name: "index_inappropriate_reports_on_user_id", using: :btree

  create_table "instance_admin_roles", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.integer  "instance_id"
    t.boolean  "permission_settings",                    default: false
    t.boolean  "permission_theme",                       default: false
    t.boolean  "permission_analytics",                   default: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "permission_manage",                      default: false
    t.boolean  "permission_blog",                        default: false
    t.boolean  "permission_support",                     default: false
    t.boolean  "permission_buysell",                     default: false
    t.boolean  "permission_shippingoptions",             default: false
    t.boolean  "permission_reports",                     default: false
    t.boolean  "permission_projects",                    default: false
    t.boolean  "permission_customtemplates",             default: true
    t.boolean  "permission_groups",                      default: false
  end

  add_index "instance_admin_roles", ["instance_id"], name: "index_instance_admin_roles_on_instance_id", using: :btree
  add_index "instance_admin_roles", ["name", "instance_id"], name: "index_instance_admin_roles_on_name_and_instance_id", unique: true, using: :btree

  create_table "instance_admins", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "instance_id"
    t.integer  "instance_admin_role_id"
    t.boolean  "instance_owner",         default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.datetime "deleted_at"
  end

  add_index "instance_admins", ["instance_admin_role_id"], name: "index_instance_admins_on_instance_admin_role_id", using: :btree
  add_index "instance_admins", ["instance_id"], name: "index_instance_admins_on_instance_id", using: :btree
  add_index "instance_admins", ["user_id", "instance_id"], name: "index_instance_admins_on_user_id_and_instance_id", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "instance_admins", ["user_id"], name: "index_instance_admins_on_user_id", using: :btree

  create_table "instance_billing_gateways", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "billing_gateway", limit: 255
    t.string   "currency",        limit: 255, default: "USD"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "instance_billing_gateways", ["instance_id"], name: "index_instance_billing_gateways_on_instance_id", using: :btree

  create_table "instance_clients", force: :cascade do |t|
    t.integer  "client_id"
    t.string   "client_type",                   limit: 255
    t.integer  "instance_id"
    t.string   "bank_account_last_four_digits", limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "gateway_class",                 limit: 255
    t.text     "encrypted_response"
    t.integer  "payment_gateway_id"
    t.integer  "merchant_account_id"
    t.integer  "user_id"
    t.boolean  "test_mode",                                 default: true
  end

  create_table "instance_creators", force: :cascade do |t|
    t.string   "email",            limit: 255
    t.boolean  "created_instance"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instance_creators", ["email"], name: "index_instance_creators_on_email", unique: true, using: :btree

  create_table "instance_profile_types", force: :cascade do |t|
    t.string   "name",                             limit: 255
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.string   "profile_type"
    t.boolean  "searchable"
    t.boolean  "show_categories"
    t.string   "category_search_type"
    t.integer  "position",                                     default: 0
    t.boolean  "must_have_verified_phone_number",              default: false
    t.boolean  "onboarding",                                   default: false
    t.boolean  "create_company_on_sign_up",                    default: false
    t.boolean  "search_only_enabled_profiles"
    t.string   "search_engine",                    limit: 255, default: "postgresql", null: false
    t.boolean  "admin_approval",                               default: false,        null: false
    t.string   "default_sort_by"
    t.integer  "default_availability_template_id"
  end

  add_index "instance_profile_types", ["instance_id", "profile_type"], name: "index_instance_profile_types_on_instance_id_and_profile_type", unique: true, using: :btree
  add_index "instance_profile_types", ["instance_id", "searchable"], name: "index_instance_profile_types_on_instance_id_and_searchable", using: :btree

  create_table "instance_views", force: :cascade do |t|
    t.integer  "instance_id"
    t.text     "body"
    t.string   "path",                 limit: 255
    t.string   "locale",               limit: 255
    t.string   "format",               limit: 255
    t.string   "handler",              limit: 255
    t.boolean  "partial",                          default: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "view_type",            limit: 255
    t.integer  "transactable_type_id"
    t.integer  "custom_theme_id"
    t.boolean  "draft",                            default: false
  end

  add_index "instance_views", ["instance_id", "path", "format", "handler", "draft"], name: "instance_path_with_format_and_handler", using: :btree

  create_table "instance_views_backup_20160926", id: false, force: :cascade do |t|
    t.integer  "id"
    t.integer  "instance_type_id"
    t.integer  "instance_id"
    t.text     "body"
    t.string   "path",                 limit: 255
    t.string   "locale",               limit: 255
    t.string   "format",               limit: 255
    t.string   "handler",              limit: 255
    t.boolean  "partial"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "view_type",            limit: 255
    t.integer  "transactable_type_id"
    t.integer  "custom_theme_id"
  end

  create_table "instances", force: :cascade do |t|
    t.string   "name",                                          limit: 255
    t.datetime "created_at",                                                                                                                   null: false
    t.datetime "updated_at",                                                                                                                   null: false
    t.string   "bookable_noun",                                 limit: 255,                         default: "Desk"
    t.decimal  "service_fee_guest_percent",                                 precision: 5, scale: 2, default: 0.0
    t.string   "lessor",                                        limit: 255
    t.string   "lessee",                                        limit: 255
    t.boolean  "skip_company",                                                                      default: false
    t.string   "encrypted_marketplace_password",                limit: 255
    t.boolean  "password_protected",                                                                default: false
    t.boolean  "test_mode",                                                                         default: false
    t.string   "encrypted_olark_api_key",                       limit: 255
    t.boolean  "olark_enabled",                                                                     default: false
    t.string   "encrypted_facebook_consumer_key",               limit: 255
    t.string   "encrypted_facebook_consumer_secret",            limit: 255
    t.string   "encrypted_linkedin_consumer_key",               limit: 255
    t.string   "encrypted_linkedin_consumer_secret",            limit: 255
    t.string   "encrypted_twitter_consumer_key",                limit: 255
    t.string   "encrypted_twitter_consumer_secret",             limit: 255
    t.string   "encrypted_instagram_consumer_key",              limit: 255
    t.string   "encrypted_instagram_consumer_secret",           limit: 255
    t.text     "metadata"
    t.string   "support_email",                                 limit: 255
    t.string   "encrypted_db_connection_string",                limit: 255
    t.boolean  "user_info_in_onboarding_flow",                                                      default: false
    t.string   "default_search_view",                           limit: 255,                         default: "mixed"
    t.boolean  "user_based_marketplace_views",                                                      default: false
    t.string   "searcher_type",                                 limit: 255,                         default: "geo"
    t.datetime "master_lock"
    t.boolean  "apply_text_filters",                                                                default: false
    t.boolean  "force_accepting_tos"
    t.text     "custom_sanitize_config"
    t.string   "payment_transfers_frequency",                   limit: 255,                         default: "fortnightly"
    t.text     "hidden_ui_controls"
    t.string   "encrypted_shippo_username",                     limit: 255
    t.string   "encrypted_shippo_password",                     limit: 255
    t.string   "twilio_from_number",                            limit: 255
    t.string   "test_twilio_from_number",                       limit: 255
    t.string   "encrypted_test_twilio_consumer_key",            limit: 255
    t.string   "encrypted_test_twilio_consumer_secret",         limit: 255
    t.string   "encrypted_twilio_consumer_key",                 limit: 255
    t.string   "encrypted_twilio_consumer_secret",              limit: 255
    t.boolean  "user_blogs_enabled",                                                                default: false
    t.boolean  "wish_lists_enabled",                                                                default: false
    t.string   "wish_lists_icon_set",                           limit: 255,                         default: "heart"
    t.boolean  "possible_manual_payment"
    t.string   "support_imap_username",                         limit: 255
    t.string   "encrypted_support_imap_password",               limit: 255
    t.string   "support_imap_server",                           limit: 255
    t.integer  "support_imap_port"
    t.boolean  "support_imap_ssl"
    t.hstore   "search_settings",                                                                   default: {},                               null: false
    t.string   "default_country",                               limit: 255
    t.text     "allowed_countries"
    t.string   "default_currency",                              limit: 255
    t.text     "allowed_currencies"
    t.string   "category_search_type",                          limit: 255,                         default: "AND"
    t.string   "search_engine",                                 limit: 255,                         default: "postgresql",                     null: false
    t.integer  "search_radius"
    t.string   "search_text",                                   limit: 255
    t.integer  "last_index_job_id"
    t.string   "context_cache_key",                             limit: 255
    t.string   "encrypted_shippo_api_token",                    limit: 255
    t.string   "encrypted_webhook_token"
    t.boolean  "is_community",                                                                      default: false
    t.string   "encrypted_github_consumer_key",                 limit: 255
    t.string   "encrypted_github_consumer_secret",              limit: 255
    t.string   "encrypted_google_consumer_key",                 limit: 255
    t.string   "encrypted_google_consumer_secret",              limit: 255
    t.string   "default_oauth_signin_provider"
    t.boolean  "custom_waiver_agreements",                                                          default: true
    t.string   "time_zone"
    t.string   "seller_attachments_access_level",               limit: 255,                         default: "disabled",                       null: false
    t.integer  "seller_attachments_documents_num",                                                  default: 10,                               null: false
    t.boolean  "enable_language_selector",                                                          default: false,                            null: false
    t.boolean  "click_to_call",                                                                     default: false
    t.boolean  "enable_reply_button_on_host_reservations",                                          default: false
    t.boolean  "split_registration",                                                                default: false
    t.boolean  "precise_search",                                                                    default: false,                            null: false
    t.boolean  "require_payout_information",                                                        default: false
    t.boolean  "enquirer_blogs_enabled",                                                            default: false
    t.boolean  "lister_blogs_enabled",                                                              default: false
    t.boolean  "tax_included_in_price",                                                             default: true
    t.boolean  "skip_meta_tags",                                                                    default: false
    t.string   "test_email"
    t.boolean  "enable_sms_and_api_workflow_alerts_on_staging",                                     default: false,                            null: false
    t.boolean  "use_cart",                                                                          default: false
    t.boolean  "expand_orders_list",                                                                default: true
    t.string   "orders_received_tabs"
    t.string   "my_orders_tabs"
    t.boolean  "enable_geo_localization",                                                           default: true
    t.boolean  "force_fill_in_wizard_form"
    t.boolean  "show_currency_symbol",                                                              default: true,                             null: false
    t.boolean  "show_currency_name",                                                                default: false,                            null: false
    t.boolean  "no_cents_if_whole",                                                                 default: true,                             null: false
    t.string   "encrypted_google_maps_api_key",                                                     default: "",                               null: false
    t.boolean  "debugging_mode_for_admins",                                                         default: true
    t.integer  "timeout_in_minutes",                                                                default: 0,                                null: false
    t.text     "password_validation_rules",                                                         default: "---\n:min_password_length: 6\n"
    t.string   "twilio_ring_tone"
    t.string   "prepend_view_path"
    t.boolean  "require_verified_user",                                                             default: false
    t.boolean  "only_first_name_as_user_slug",                                                      default: false,                            null: false
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.integer  "line_item_source_id"
    t.string   "line_item_source_type"
    t.integer  "line_itemable_id"
    t.string   "line_itemable_type"
    t.integer  "transactable_pricing_id"
    t.string   "name"
    t.string   "type",                             limit: 255
    t.integer  "unit_price_cents",                                                      default: 0
    t.float    "quantity",                                                              default: 0.0
    t.string   "receiver"
    t.boolean  "optional"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "additional_tax_total_rate",                    precision: 10, scale: 2, default: 0.0
    t.decimal  "additional_tax_price_cents",                   precision: 10, scale: 2, default: 0.0
    t.decimal  "included_tax_total_rate",                      precision: 10, scale: 2, default: 0.0
    t.decimal  "included_tax_price_cents",                     precision: 10, scale: 2, default: 0.0
    t.decimal  "service_fee_guest_percent",                    precision: 5,  scale: 2, default: 0.0
    t.decimal  "service_fee_host_percent",                     precision: 5,  scale: 2, default: 0.0
    t.text     "description"
    t.integer  "minimum_lister_service_fee_cents",                                      default: 0
    t.text     "properties"
  end

  add_index "line_items", ["instance_id"], name: "index_line_items_on_instance_id", using: :btree
  add_index "line_items", ["line_item_source_id"], name: "index_line_items_on_line_item_source_id", using: :btree
  add_index "line_items", ["line_itemable_id"], name: "index_line_items_on_line_itemable_id", using: :btree
  add_index "line_items", ["transactable_pricing_id"], name: "index_line_items_on_transactable_pricing_id", using: :btree
  add_index "line_items", ["user_id"], name: "index_line_items_on_user_id", using: :btree

  create_table "links", force: :cascade do |t|
    t.string   "url"
    t.string   "image"
    t.string   "text"
    t.integer  "instance_id"
    t.integer  "linkable_id"
    t.string   "linkable_type"
    t.datetime "deleted_at"
    t.datetime "image_versions_generated_at"
    t.integer  "creator_id"
  end

  add_index "links", ["creator_id"], name: "index_links_on_creator_id", using: :btree
  add_index "links", ["instance_id", "linkable_id", "linkable_type"], name: "index_links_on_instance_id_and_linkable_id_and_linkable_type", using: :btree

  create_table "locale_instance_views", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "instance_view_id"
    t.integer  "locale_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locale_instance_views", ["instance_id", "instance_view_id", "locale_id"], name: "index_tt_instance_views_on_instance_id_locale_view_unique", unique: true, using: :btree

  create_table "locales", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "code",        limit: 255
    t.string   "custom_name", limit: 255
    t.boolean  "primary",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locales", ["instance_id", "code"], name: "index_locales_on_instance_id_and_code", unique: true, using: :btree

  create_table "location_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "instance_id"
  end

  add_index "location_types", ["instance_id"], name: "index_location_types_on_instance_id", using: :btree
  add_index "location_types", ["name", "instance_id"], name: "index_location_types_on_name_and_instance_id", unique: true, using: :btree

  create_table "locations", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "email",                          limit: 255
    t.text     "description"
    t.string   "address",                        limit: 255
    t.float    "latitude"
    t.float    "longitude"
    t.text     "info"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.datetime "deleted_at"
    t.string   "formatted_address",              limit: 255
    t.string   "deprecated_currency",            limit: 255
    t.text     "special_notes"
    t.text     "address_components"
    t.string   "street",                         limit: 255
    t.string   "suburb",                         limit: 255
    t.string   "city",                           limit: 255
    t.string   "state",                          limit: 255
    t.string   "country",                        limit: 255
    t.string   "slug",                           limit: 255
    t.integer  "location_type_id"
    t.string   "custom_page",                    limit: 255
    t.string   "address2",                       limit: 255
    t.string   "postcode",                       limit: 255
    t.integer  "administrator_id"
    t.string   "name",                           limit: 255
    t.text     "metadata"
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.boolean  "listings_public",                            default: true
    t.integer  "partner_id"
    t.integer  "address_id"
    t.string   "external_id",                    limit: 255
    t.boolean  "mark_to_be_bulk_update_deleted",             default: false
    t.integer  "wish_list_items_count",                      default: 0
    t.integer  "opened_on_days",                             default: [],                 array: true
    t.string   "time_zone",                      limit: 255
    t.integer  "availability_template_id"
    t.integer  "impressions_count",                          default: 0,     null: false
  end

  add_index "locations", ["address_id"], name: "index_locations_on_address_id", using: :btree
  add_index "locations", ["administrator_id"], name: "index_locations_on_administrator_id", using: :btree
  add_index "locations", ["company_id"], name: "index_locations_on_company_id", using: :btree
  add_index "locations", ["creator_id"], name: "index_locations_on_creator_id", using: :btree
  add_index "locations", ["external_id", "company_id"], name: "index_locations_on_external_id_and_company_id", unique: true, using: :btree
  add_index "locations", ["instance_id"], name: "index_locations_on_instance_id", using: :btree
  add_index "locations", ["location_type_id"], name: "index_locations_on_location_type_id", using: :btree
  add_index "locations", ["opened_on_days"], name: "index_locations_on_opened_on_days", using: :gin
  add_index "locations", ["partner_id"], name: "index_locations_on_partner_id", using: :btree
  add_index "locations", ["slug"], name: "index_locations_on_slug", using: :btree

  create_table "mailer_unsubscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "mailer",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "mailer_unsubscriptions", ["user_id", "mailer"], name: "index_mailer_unsubscriptions_on_user_id_and_mailer", unique: true, using: :btree
  add_index "mailer_unsubscriptions", ["user_id"], name: "index_mailer_unsubscriptions_on_user_id", using: :btree

  create_table "marketplace_error_groups", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "error_type"
    t.text     "message"
    t.string   "message_digest"
    t.datetime "last_occurence"
    t.integer  "marketplace_errors_count", default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "marketplace_error_groups", ["instance_id", "error_type", "message_digest"], name: "meg_instance_type_digest", unique: true, where: "(deleted_at IS NULL)", using: :btree

  create_table "marketplace_errors", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "error_type",                 limit: 255
    t.text     "message"
    t.text     "stacktrace"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "message_digest"
    t.integer  "marketplace_error_group_id"
  end

  add_index "marketplace_errors", ["instance_id", "error_type", "message_digest"], name: "errors_type_digest_instance", using: :btree

  create_table "merchant_account_owners", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "merchant_account_id"
    t.text     "data"
    t.string   "document",            limit: 255
    t.string   "type",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "merchant_account_owners", ["instance_id"], name: "index_merchant_account_owners_on_instance_id", using: :btree
  add_index "merchant_account_owners", ["merchant_account_id"], name: "index_merchant_account_owners_on_merchant_account_id", using: :btree

  create_table "merchant_accounts", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "merchantable_id"
    t.string   "merchantable_type",                   limit: 255
    t.text     "encrypted_response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_gateway_id"
    t.text     "data"
    t.string   "type",                                limit: 255
    t.string   "state",                               limit: 255, default: "pending"
    t.string   "internal_payment_gateway_account_id", limit: 255
    t.boolean  "test",                                            default: false
    t.datetime "deleted_at"
    t.string   "external_id"
  end

  add_index "merchant_accounts", ["instance_id", "merchantable_id", "merchantable_type"], name: "index_on_merchant_accounts_on_merchant", using: :btree

  create_table "notification_preferences", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.boolean  "project_updates_enabled", default: true
    t.boolean  "group_updates_enabled",   default: true
    t.string   "email_frequency",         default: "immediately"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "notification_preferences", ["instance_id", "user_id"], name: "index_notification_preferences_on_instance_id_and_user_id", unique: true, using: :btree

  create_table "order_addresses", force: :cascade do |t|
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
    t.integer  "state_id"
    t.integer  "country_id"
    t.integer  "instance_id"
    t.integer  "user_id"
    t.string   "shippo_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "address"
    t.string   "local_geocoding"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "formatted_address"
  end

  add_index "order_addresses", ["country_id"], name: "index_order_addresses_on_country_id", using: :btree
  add_index "order_addresses", ["instance_id"], name: "index_order_addresses_on_instance_id", using: :btree
  add_index "order_addresses", ["state_id"], name: "index_order_addresses_on_state_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.integer  "owner_id"
    t.integer  "creator_id"
    t.integer  "company_id"
    t.integer  "transactable_id"
    t.integer  "transactable_pricing_id"
    t.integer  "reservation_type_id"
    t.integer  "shipping_address_id"
    t.integer  "billing_address_id"
    t.string   "currency"
    t.string   "state",                                         limit: 255
    t.string   "type",                                          limit: 255
    t.string   "time_zone"
    t.boolean  "use_billing",                                               default: false, null: false
    t.string   "rejection_reason",                              limit: 255
    t.string   "completed_form_component_ids",                  limit: 255
    t.integer  "cancellation_policy_hours_for_cancellation",                default: 0
    t.integer  "cancellation_policy_penalty_percentage",                    default: 0
    t.integer  "cancellation_policy_penalty_hours",                         default: 0
    t.integer  "minimum_booking_minutes",                                   default: 60
    t.integer  "book_it_out_discount"
    t.text     "guest_notes"
    t.hstore   "properties"
    t.datetime "pending_guest_confirmation"
    t.date     "paid_until"
    t.date     "next_charge_date"
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.datetime "ends_at"
    t.datetime "cancelled_at"
    t.datetime "confirmed_at"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.boolean  "insurance_enabled",                                         default: false, null: false
    t.string   "delivery_type",                                 limit: 255
    t.string   "confirmation_email",                            limit: 255
    t.text     "comment"
    t.datetime "request_guest_rating_email_sent_at"
    t.datetime "request_host_and_product_rating_email_sent_at"
    t.integer  "exclusive_price_cents"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "settings",                                                  default: {}
    t.boolean  "exclusive_price"
    t.boolean  "book_it_out"
    t.boolean  "is_free_booking",                                           default: false
    t.datetime "lister_confirmed_at"
    t.datetime "enquirer_confirmed_at"
    t.datetime "draft_at"
  end

  add_index "orders", ["billing_address_id"], name: "index_orders_on_billing_address_id", using: :btree
  add_index "orders", ["company_id"], name: "index_orders_on_company_id", using: :btree
  add_index "orders", ["creator_id"], name: "index_orders_on_creator_id", using: :btree
  add_index "orders", ["currency"], name: "index_orders_on_currency", using: :btree
  add_index "orders", ["instance_id"], name: "index_orders_on_instance_id", using: :btree
  add_index "orders", ["owner_id"], name: "index_orders_on_owner_id", using: :btree
  add_index "orders", ["reservation_type_id"], name: "index_orders_on_reservation_type_id", using: :btree
  add_index "orders", ["shipping_address_id"], name: "index_orders_on_shipping_address_id", using: :btree
  add_index "orders", ["transactable_id"], name: "index_orders_on_transactable_id", using: :btree
  add_index "orders", ["transactable_pricing_id"], name: "index_orders_on_transactable_pricing_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "page_data_source_contents", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "page_id"
    t.integer  "data_source_content_id"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_data_source_contents", ["instance_id", "page_id", "data_source_content_id", "slug"], name: "pdsc_on_foreign_keys", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "path",                      limit: 255,                         null: false
    t.text     "content"
    t.string   "hero_image",                limit: 255
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.integer  "theme_id"
    t.string   "slug",                      limit: 255
    t.integer  "position"
    t.text     "html_content"
    t.datetime "deleted_at"
    t.string   "redirect_url",              limit: 255
    t.boolean  "open_in_new_window",                    default: true
    t.integer  "instance_id"
    t.text     "css_content"
    t.boolean  "no_layout",                             default: false
    t.string   "metadata_title"
    t.string   "metadata_meta_description"
    t.integer  "redirect_code"
    t.string   "metadata_canonical_url"
    t.string   "layout_name",                           default: "application"
  end

  add_index "pages", ["instance_id"], name: "index_pages_on_instance_id", using: :btree
  add_index "pages", ["slug", "theme_id"], name: "index_pages_on_slug_and_theme_id", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "pages", ["theme_id"], name: "index_pages_on_theme_id", using: :btree

  create_table "partners", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.integer  "instance_id"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "search_scope_option", limit: 255, default: "no_scoping"
  end

  create_table "payment_document_infos", force: :cascade do |t|
    t.integer  "document_requirement_id"
    t.integer  "attachment_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_document_infos", ["attachment_id"], name: "index_payment_document_infos_on_attachment_id", using: :btree
  add_index "payment_document_infos", ["document_requirement_id"], name: "index_payment_document_infos_on_document_requirement_id", using: :btree
  add_index "payment_document_infos", ["instance_id"], name: "index_payment_document_infos_on_instance_id", using: :btree

  create_table "payment_gateways", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "payment_gateway_id"
    t.text     "encrypted_live_settings"
    t.text     "encrypted_test_settings"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "type",                    limit: 255
    t.boolean  "test_active"
    t.boolean  "live_active"
    t.datetime "deleted_at"
    t.text     "config"
  end

  create_table "payment_gateways_countries", force: :cascade do |t|
    t.integer  "country_id"
    t.integer  "payment_gateway_id"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_gateways_countries", ["country_id"], name: "index_payment_gateways_countries_on_country_id", using: :btree
  add_index "payment_gateways_countries", ["instance_id"], name: "index_payment_gateways_countries_on_instance_id", using: :btree
  add_index "payment_gateways_countries", ["payment_gateway_id"], name: "index_payment_gateways_countries_on_payment_gateway_id", using: :btree

  create_table "payment_gateways_currencies", force: :cascade do |t|
    t.integer  "currency_id"
    t.integer  "payment_gateway_id"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_gateways_currencies", ["currency_id"], name: "index_payment_gateways_currencies_on_currency_id", using: :btree
  add_index "payment_gateways_currencies", ["instance_id"], name: "index_payment_gateways_currencies_on_instance_id", using: :btree
  add_index "payment_gateways_currencies", ["payment_gateway_id"], name: "index_payment_gateways_currencies_on_payment_gateway_id", using: :btree

  create_table "payment_methods", force: :cascade do |t|
    t.integer  "payment_gateway_id"
    t.integer  "instance_id"
    t.string   "payment_method_type"
    t.boolean  "active",              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "type"
    t.text     "encrypted_settings"
  end

  add_index "payment_methods", ["instance_id"], name: "index_payment_methods_on_instance_id", using: :btree
  add_index "payment_methods", ["payment_gateway_id"], name: "index_payment_methods_on_payment_gateway_id", using: :btree

  create_table "payment_subscriptions", force: :cascade do |t|
    t.integer  "payment_method_id"
    t.integer  "payment_gateway_id"
    t.integer  "credit_card_id"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "subscriber_id"
    t.boolean  "test_mode"
    t.datetime "deleted_at"
    t.string   "subscriber_type"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "payer_id"
    t.datetime "expired_at"
    t.string   "payment_source_type"
    t.integer  "payment_source_id"
  end

  add_index "payment_subscriptions", ["company_id"], name: "index_payment_subscriptions_on_company_id", using: :btree
  add_index "payment_subscriptions", ["instance_id"], name: "index_payment_subscriptions_on_instance_id", using: :btree
  add_index "payment_subscriptions", ["payment_method_id"], name: "index_payment_subscriptions_on_payment_method_id", using: :btree
  add_index "payment_subscriptions", ["subscriber_id", "subscriber_type"], name: "subscriber_index", using: :btree

  create_table "payment_transfers", force: :cascade do |t|
    t.integer  "company_id"
    t.datetime "transferred_at"
    t.string   "currency",                       limit: 255
    t.integer  "amount_cents",                                                       default: 0,   null: false
    t.decimal  "service_fee_amount_guest_cents",             precision: 8, scale: 2, default: 0.0, null: false
    t.datetime "created_at",                                                                       null: false
    t.datetime "updated_at",                                                                       null: false
    t.decimal  "service_fee_amount_host_cents",              precision: 8, scale: 2, default: 0.0, null: false
    t.datetime "deleted_at"
    t.integer  "instance_id"
    t.integer  "partner_id"
    t.string   "payment_gateway_mode",           limit: 4
    t.integer  "payment_gateway_id"
    t.datetime "failed_at"
    t.string   "encrypted_token"
    t.integer  "payment_gateway_fee_cents",                                          default: 0
    t.integer  "merchant_account_id"
  end

  add_index "payment_transfers", ["company_id"], name: "index_payment_transfers_on_company_id", using: :btree
  add_index "payment_transfers", ["instance_id"], name: "index_payment_transfers_on_instance_id", using: :btree
  add_index "payment_transfers", ["partner_id"], name: "index_payment_transfers_on_partner_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "reservation_id"
    t.integer  "subtotal_amount_cents",                                                          default: 0
    t.decimal  "service_fee_amount_guest_cents",                         precision: 8, scale: 2
    t.datetime "paid_at"
    t.datetime "failed_at"
    t.datetime "created_at",                                                                                     null: false
    t.datetime "updated_at",                                                                                     null: false
    t.string   "currency",                                   limit: 255
    t.datetime "deleted_at"
    t.integer  "payment_transfer_id"
    t.decimal  "service_fee_amount_host_cents",                          precision: 8, scale: 2, default: 0.0,   null: false
    t.datetime "refunded_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "cancellation_policy_hours_for_cancellation",                                     default: 0
    t.integer  "cancellation_policy_penalty_percentage",                                         default: 0
    t.text     "recurring_booking_error"
    t.string   "payable_type",                               limit: 255
    t.integer  "payable_id"
    t.string   "external_transaction_id",                    limit: 255
    t.decimal  "service_additional_charges_cents",                                               default: 0.0
    t.decimal  "host_additional_charges_cents",                                                  default: 0.0
    t.string   "state"
    t.integer  "payment_gateway_id"
    t.string   "payment_gateway_mode"
    t.integer  "payment_method_id"
    t.string   "express_payer_id"
    t.string   "express_token"
    t.integer  "merchant_account_id"
    t.boolean  "offline",                                                                        default: false
    t.integer  "credit_card_id"
    t.integer  "payer_id"
    t.integer  "total_amount_cents",                                                             default: 0
    t.boolean  "exclude_from_payout",                                                            default: false
    t.string   "external_id"
    t.integer  "payment_gateway_fee_cents",                                                      default: 0
    t.integer  "payment_source_id"
    t.string   "payment_source_type"
    t.boolean  "direct_charge",                                                                  default: false
  end

  add_index "payments", ["company_id"], name: "index_payments_on_company_id", using: :btree
  add_index "payments", ["credit_card_id"], name: "index_payments_on_credit_card_id", using: :btree
  add_index "payments", ["instance_id"], name: "index_payments_on_instance_id", using: :btree
  add_index "payments", ["partner_id"], name: "index_payments_on_partner_id", using: :btree
  add_index "payments", ["payable_id", "payable_type"], name: "index_payments_on_payable_id_and_payable_type", using: :btree
  add_index "payments", ["payment_gateway_id"], name: "index_payments_on_payment_gateway_id", using: :btree
  add_index "payments", ["payment_method_id"], name: "index_payments_on_payment_method_id", using: :btree
  add_index "payments", ["payment_transfer_id"], name: "index_payments_on_payment_transfer_id", using: :btree
  add_index "payments", ["reservation_id"], name: "index_payments_on_reservation_id", using: :btree

  create_table "payouts", force: :cascade do |t|
    t.integer  "reference_id"
    t.string   "reference_type",       limit: 255
    t.boolean  "success"
    t.integer  "amount_cents"
    t.string   "currency",             limit: 255
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.text     "encrypted_response"
    t.datetime "deleted_at"
    t.boolean  "pending",                          default: false
    t.string   "payment_gateway_mode", limit: 4
    t.integer  "instance_id"
    t.integer  "payment_gateway_id"
  end

  add_index "payouts", ["instance_id", "payment_gateway_id"], name: "index_payouts_on_instance_id_and_payment_gateway_id", using: :btree

  create_table "paypal_accounts", force: :cascade do |t|
    t.string  "email"
    t.integer "instance_id",                       null: false
    t.integer "instance_client_id"
    t.integer "deleted_at"
    t.string  "encrypted_response"
    t.integer "payment_gateway_id"
    t.integer "payment_method_id"
    t.boolean "test_mode",          default: true
    t.string  "express_payer_id"
  end

  create_table "phone_calls", force: :cascade do |t|
    t.integer  "caller_id"
    t.string   "from"
    t.integer  "receiver_id"
    t.string   "to"
    t.string   "phone_call_key"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "photo_upload_versions", force: :cascade do |t|
    t.integer  "theme_id"
    t.integer  "instance_id"
    t.string   "apply_transform"
    t.integer  "width"
    t.integer  "height"
    t.string   "photo_uploader"
    t.string   "version_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "photo_upload_versions", ["instance_id"], name: "index_photo_upload_versions_on_instance_id", using: :btree
  add_index "photo_upload_versions", ["theme_id", "version_name", "photo_uploader"], name: "uniq_puv_theme_version_uploader", unique: true, using: :btree
  add_index "photo_upload_versions", ["theme_id"], name: "index_photo_upload_versions_on_theme_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "transactable_id"
    t.string   "image",                          limit: 255
    t.string   "caption",                        limit: 255
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
    t.string   "image_original_url",             limit: 255
    t.datetime "image_versions_generated_at"
    t.integer  "image_original_height"
    t.integer  "image_original_width"
    t.integer  "instance_id"
    t.boolean  "mark_to_be_bulk_update_deleted",             default: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "photo_role"
  end

  add_index "photos", ["creator_id"], name: "index_photos_on_creator_id", using: :btree
  add_index "photos", ["instance_id", "owner_id", "owner_type"], name: "index_photos_on_owner", using: :btree
  add_index "photos", ["instance_id"], name: "index_photos_on_instance_id", using: :btree
  add_index "photos", ["transactable_id"], name: "index_photos_on_listing_id", using: :btree

  create_table "rating_answers", force: :cascade do |t|
    t.integer  "rating"
    t.integer  "rating_question_id"
    t.integer  "review_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  add_index "rating_answers", ["deleted_at"], name: "index_rating_answers_on_deleted_at", using: :btree
  add_index "rating_answers", ["instance_id"], name: "index_rating_answers_on_instance_id", using: :btree
  add_index "rating_answers", ["rating_question_id"], name: "index_rating_answers_on_rating_question_id", using: :btree
  add_index "rating_answers", ["review_id"], name: "index_rating_answers_on_review_id", using: :btree

  create_table "rating_hints", force: :cascade do |t|
    t.string   "value",            limit: 255
    t.string   "description",      limit: 255
    t.integer  "rating_system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  add_index "rating_hints", ["deleted_at"], name: "index_rating_hints_on_deleted_at", using: :btree
  add_index "rating_hints", ["instance_id"], name: "index_rating_hints_on_instance_id", using: :btree
  add_index "rating_hints", ["rating_system_id"], name: "index_rating_hints_on_rating_system_id", using: :btree

  create_table "rating_questions", force: :cascade do |t|
    t.text     "text"
    t.integer  "rating_system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  add_index "rating_questions", ["deleted_at"], name: "index_rating_questions_on_deleted_at", using: :btree
  add_index "rating_questions", ["instance_id"], name: "index_rating_questions_on_instance_id", using: :btree
  add_index "rating_questions", ["rating_system_id"], name: "index_rating_questions_on_rating_system_id", using: :btree

  create_table "rating_systems", force: :cascade do |t|
    t.string   "subject",              limit: 255
    t.integer  "transactable_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.boolean  "active",                           default: false
    t.datetime "deleted_at"
  end

  add_index "rating_systems", ["deleted_at"], name: "index_rating_systems_on_deleted_at", using: :btree
  add_index "rating_systems", ["instance_id"], name: "index_rating_systems_on_instance_id", using: :btree
  add_index "rating_systems", ["transactable_type_id"], name: "index_rating_systems_on_transactable_type_id", using: :btree

  create_table "recurring_booking_periods", force: :cascade do |t|
    t.integer  "recurring_booking_id"
    t.integer  "instance_id",                        null: false
    t.date     "period_start_date"
    t.date     "period_end_date"
    t.integer  "old_subtotal_amount_cents"
    t.integer  "old_service_fee_amount_guest_cents"
    t.integer  "old_service_fee_amount_host_cents"
    t.integer  "credit_card_id"
    t.string   "currency"
    t.datetime "deleted_at"
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
    t.text     "comment"
    t.string   "state"
    t.text     "rejection_reason"
    t.datetime "approve_at"
  end

  create_table "refunds", force: :cascade do |t|
    t.integer  "payment_id"
    t.boolean  "success"
    t.text     "encrypted_response"
    t.integer  "amount_cents"
    t.string   "currency",             limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "instance_id"
    t.integer  "payment_gateway_id"
    t.string   "payment_gateway_mode", limit: 4
    t.string   "receiver"
    t.string   "external_id"
  end

  create_table "reservation_periods", force: :cascade do |t|
    t.integer  "old_reservation_id"
    t.date     "date"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "deleted_at"
    t.integer  "start_minute"
    t.integer  "end_minute"
    t.integer  "instance_id"
    t.string   "description"
    t.integer  "reservation_id"
  end

  add_index "reservation_periods", ["old_reservation_id"], name: "index_reservation_periods_on_old_reservation_id", using: :btree

  create_table "reservation_types", force: :cascade do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.hstore   "settings",                        default: {}
    t.boolean  "step_checkout",                   default: false
    t.boolean  "require_merchant_account",        default: false
    t.boolean  "withdraw_invitation_when_reject"
    t.boolean  "reverse_immediate_payment"
  end

  add_index "reservation_types", ["instance_id"], name: "index_reservation_types_on_instance_id", using: :btree

  create_table "reverse_proxies", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "domain_id"
    t.string   "path"
    t.string   "destination_domain"
    t.string   "environment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "headers",            default: "{}"
  end

  add_index "reverse_proxies", ["instance_id", "domain_id", "path"], name: "index_reverse_proxies_on_instance_id_and_domain_id_and_path", unique: true, using: :btree

  create_table "reverse_proxy_links", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "use_on_path"
    t.string   "name"
    t.string   "destination_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "rating"
    t.text     "comment"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reviewable_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.integer  "transactable_type_id"
    t.string   "reviewable_type",      limit: 255
    t.integer  "rating_system_id"
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.boolean  "displayable",                      default: true
    t.string   "subject",              limit: 255
  end

  add_index "reviews", ["deleted_at"], name: "index_reviews_on_deleted_at", using: :btree
  add_index "reviews", ["instance_id"], name: "index_reviews_on_instance_id", using: :btree
  add_index "reviews", ["rating_system_id", "reviewable_id", "reviewable_type", "deleted_at"], name: "index_reviews_on_rating_system_id_and_reviewable_and_deleted_at", unique: true, using: :btree
  add_index "reviews", ["reviewable_id", "reviewable_type"], name: "index_reviews_on_reviewable_id_and_reviewable_type", using: :btree
  add_index "reviews", ["transactable_type_id"], name: "index_reviews_on_transactable_type_id", using: :btree
  add_index "reviews", ["user_id", "reviewable_id", "reviewable_type", "subject", "instance_id"], name: "index_reviews_on_user_reviewable_and_type_and_subject", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "saved_search_alert_logs", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "saved_search_id"
    t.integer  "results_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saved_search_alert_logs", ["instance_id"], name: "index_saved_search_alert_logs_on_instance_id", using: :btree
  add_index "saved_search_alert_logs", ["saved_search_id", "created_at"], name: "index_saved_search_alert_logs_on_saved_search_id_and_created_at", using: :btree

  create_table "saved_searches", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.integer  "user_id"
    t.text     "query"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "new_results",                default: 0
    t.datetime "last_viewed_at"
  end

  add_index "saved_searches", ["title", "user_id"], name: "index_saved_searches_on_title_and_user_id", unique: true, using: :btree

  create_table "schedule_exception_rules", force: :cascade do |t|
    t.string   "label",                    limit: 255
    t.datetime "duration_range_start"
    t.datetime "duration_range_end"
    t.integer  "schedule_id"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "availability_template_id"
  end

  add_index "schedule_exception_rules", ["availability_template_id"], name: "index_schedule_exception_rules_on_availability_template_id", using: :btree
  add_index "schedule_exception_rules", ["instance_id", "schedule_id"], name: "index_schedule_exception_rules_on_instance_id_and_schedule_id", using: :btree

  create_table "schedule_rules", force: :cascade do |t|
    t.string   "run_hours_mode"
    t.decimal  "every_hours",    precision: 8, scale: 2
    t.datetime "time_start"
    t.datetime "time_end"
    t.datetime "times",                                  default: [], array: true
    t.string   "run_dates_mode"
    t.integer  "week_days",                              default: [], array: true
    t.datetime "dates",                                  default: [], array: true
    t.datetime "date_start"
    t.datetime "date_end"
    t.integer  "instance_id"
    t.integer  "schedule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedule_rules", ["instance_id", "schedule_id"], name: "index_schedule_rules_on_instance_id_and_schedule_id", using: :btree

  create_table "scheduled_uploaders_regenerations", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "photo_uploader"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "scheduled_uploaders_regenerations", ["instance_id", "photo_uploader"], name: "uniq_sur_instance_photo_uploader", unique: true, using: :btree
  add_index "scheduled_uploaders_regenerations", ["instance_id"], name: "index_scheduled_uploaders_regenerations_on_instance_id", using: :btree

  create_table "schedules", force: :cascade do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "schedule"
    t.string   "scheduable_type",            limit: 255
    t.integer  "scheduable_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.boolean  "exception",                              default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "simple_rules"
    t.datetime "sr_start_datetime"
    t.time     "sr_from_hour"
    t.time     "sr_to_hour"
    t.integer  "sr_every_hours"
    t.text     "sr_days_of_week",                        default: [],    array: true
    t.boolean  "use_simple_schedule",                    default: true
    t.boolean  "unavailable_period_enabled",             default: false
  end

  add_index "schedules", ["instance_id", "scheduable_id", "scheduable_type"], name: "index_schedules_scheduable", using: :btree

  create_table "shipments", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "reservation_id"
    t.boolean  "is_insured",            default: false
    t.integer  "price"
    t.string   "price_currency"
    t.integer  "insurance_value"
    t.string   "insurance_currency"
    t.string   "label_url"
    t.string   "tracking_number"
    t.string   "tracking_url_provider"
    t.string   "shippo_rate_id"
    t.string   "shippo_transaction_id"
    t.text     "shippo_errors"
    t.string   "direction",             default: "outbound"
    t.datetime "deleted_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "order_id"
    t.string   "name"
    t.string   "state"
    t.integer  "shipping_rule_id"
  end

  add_index "shipments", ["instance_id", "reservation_id"], name: "index_shipments_on_instance_id_and_reservation_id", using: :btree

  create_table "shipping_addresses", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "shipment_id"
    t.integer  "user_id"
    t.string   "shippo_id"
    t.string   "name"
    t.string   "company"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "phone"
    t.string   "email"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "shipping_addresses", ["instance_id", "shipment_id"], name: "index_shipping_addresses_on_instance_id_and_shipment_id", using: :btree
  add_index "shipping_addresses", ["instance_id", "user_id"], name: "index_shipping_addresses_on_instance_id_and_user_id", using: :btree

  create_table "shipping_profiles", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "name"
    t.datetime "deleted_at"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.boolean  "global"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "shipping_type", default: "predefined"
  end

  add_index "shipping_profiles", ["instance_id", "company_id"], name: "index_shipping_profiles_on_instance_id_and_company_id", using: :btree
  add_index "shipping_profiles", ["instance_id"], name: "index_shipping_profiles_on_instance_id", using: :btree

  create_table "shipping_rules", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "name"
    t.integer  "shipping_profile_id"
    t.integer  "price_cents",          default: 0
    t.string   "processing_time"
    t.boolean  "is_worldwide",         default: true
    t.datetime "deleted_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "is_pickup"
    t.boolean  "use_shippo_for_price"
  end

  add_index "shipping_rules", ["instance_id", "shipping_profile_id"], name: "index_shipping_rules_on_instance_id_and_shipping_profile_id", using: :btree
  add_index "shipping_rules", ["instance_id"], name: "index_shipping_rules_on_instance_id", using: :btree
  add_index "shipping_rules", ["shipping_profile_id"], name: "index_shipping_rules_on_shipping_profile_id", using: :btree

  create_table "shippings_delivery_external_states", force: :cascade do |t|
    t.integer  "delivery_id", null: false
    t.text     "body",        null: false
    t.integer  "instance_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "shippings_delivery_external_states", ["delivery_id"], name: "index_shippings_delivery_external_states_on_delivery_id", using: :btree
  add_index "shippings_delivery_external_states", ["instance_id"], name: "index_shippings_delivery_external_states_on_instance_id", using: :btree

  create_table "shippings_shipping_providers", force: :cascade do |t|
    t.integer  "instance_id",                        null: false
    t.string   "shipping_provider_name",             null: false
    t.string   "encrypted_settings"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "mpo_extra_shipping_fee", default: 0
  end

  create_table "spam_reports", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "spamable_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "spamable_type"
    t.string   "ip_address"
  end

  add_index "spam_reports", ["instance_id"], name: "index_spam_reports_on_instance_id", using: :btree
  add_index "spam_reports", ["spamable_id"], name: "index_spam_reports_on_spamable_id", using: :btree
  add_index "spam_reports", ["user_id"], name: "index_spam_reports_on_user_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "abbr",       limit: 255
    t.integer  "country_id"
    t.datetime "updated_at"
  end

  add_index "states", ["country_id"], name: "index_states_on_country_id", using: :btree

  create_table "support_faqs", force: :cascade do |t|
    t.integer  "instance_id"
    t.text     "question",      null: false
    t.text     "answer",        null: false
    t.integer  "position",      null: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "deleted_by_id"
    t.datetime "deleted_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "support_faqs", ["created_by_id"], name: "index_support_faqs_on_created_by_id", using: :btree
  add_index "support_faqs", ["deleted_at"], name: "index_support_faqs_on_deleted_at", using: :btree
  add_index "support_faqs", ["deleted_by_id"], name: "index_support_faqs_on_deleted_by_id", using: :btree
  add_index "support_faqs", ["instance_id"], name: "index_support_faqs_on_instance_id", using: :btree
  add_index "support_faqs", ["updated_by_id"], name: "index_support_faqs_on_updated_by_id", using: :btree

  create_table "support_ticket_message_attachments", force: :cascade do |t|
    t.string   "tag",               limit: 255
    t.integer  "instance_id"
    t.integer  "uploader_id"
    t.integer  "ticket_message_id"
    t.integer  "ticket_id"
    t.string   "file",              limit: 255
    t.string   "file_type",         limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "support_ticket_messages", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.integer  "ticket_id"
    t.string   "full_name",   limit: 255, null: false
    t.string   "email",       limit: 255, null: false
    t.string   "subject",     limit: 255, null: false
    t.text     "message",                 null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "support_ticket_messages", ["instance_id"], name: "index_support_ticket_messages_on_instance_id", using: :btree
  add_index "support_ticket_messages", ["ticket_id"], name: "index_support_ticket_messages_on_ticket_id", using: :btree
  add_index "support_ticket_messages", ["user_id"], name: "index_support_ticket_messages_on_user_id", using: :btree

  create_table "support_tickets", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.integer  "assigned_to_id"
    t.string   "state",               limit: 255, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "target_id"
    t.string   "target_type",         limit: 255
    t.text     "reservation_details"
  end

  add_index "support_tickets", ["assigned_to_id"], name: "index_support_tickets_on_assigned_to_id", using: :btree
  add_index "support_tickets", ["instance_id"], name: "index_support_tickets_on_instance_id", using: :btree
  add_index "support_tickets", ["target_id", "target_type"], name: "index_support_tickets_on_target_id_and_target_type", using: :btree
  add_index "support_tickets", ["user_id"], name: "index_support_tickets_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id"
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.integer  "instance_id"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.string  "slug",           limit: 255
    t.integer "instance_id"
    t.integer "taggings_count",             default: 0
  end

  add_index "tags", ["name", "instance_id"], name: "tags_idx", unique: true, using: :btree

  create_table "tax_rates", force: :cascade do |t|
    t.datetime "deleted_at"
    t.integer  "instance_id"
    t.integer  "state_id"
    t.integer  "value"
    t.boolean  "included_in_price", default: true
    t.string   "name"
    t.string   "admin_name"
    t.string   "calculate_with"
    t.integer  "tax_region_id"
    t.boolean  "default",           default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "tax_rates", ["instance_id"], name: "index_tax_rates_on_instance_id", using: :btree
  add_index "tax_rates", ["state_id"], name: "index_tax_rates_on_state_id", using: :btree
  add_index "tax_rates", ["tax_region_id"], name: "index_tax_rates_on_tax_region_id", using: :btree

  create_table "tax_regions", force: :cascade do |t|
    t.datetime "deleted_at"
    t.integer  "instance_id"
    t.integer  "country_id"
    t.integer  "state_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tax_regions", ["country_id"], name: "index_tax_regions_on_country_id", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "tax_regions", ["instance_id"], name: "index_tax_regions_on_instance_id", using: :btree
  add_index "tax_regions", ["state_id"], name: "index_tax_regions_on_state_id", using: :btree

  create_table "text_filters", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "regexp",           limit: 255
    t.string   "replacement_text", limit: 255
    t.integer  "flags"
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "theme_fonts", force: :cascade do |t|
    t.integer  "theme_id"
    t.string   "regular_eot",  limit: 255
    t.string   "regular_svg",  limit: 255
    t.string   "regular_ttf",  limit: 255
    t.string   "regular_woff", limit: 255
    t.string   "medium_eot",   limit: 255
    t.string   "medium_svg",   limit: 255
    t.string   "medium_ttf",   limit: 255
    t.string   "medium_woff",  limit: 255
    t.string   "bold_eot",     limit: 255
    t.string   "bold_svg",     limit: 255
    t.string   "bold_ttf",     limit: 255
    t.string   "bold_woff",    limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "theme_fonts", ["theme_id"], name: "index_theme_fonts_on_theme_id", using: :btree

  create_table "themes", force: :cascade do |t|
    t.string   "name",                                    limit: 255
    t.string   "compiled_stylesheet",                     limit: 255
    t.string   "icon_image",                              limit: 255
    t.string   "icon_retina_image",                       limit: 255
    t.string   "logo_image",                              limit: 255
    t.string   "logo_retina_image",                       limit: 255
    t.string   "hero_image",                              limit: 255
    t.string   "color_blue",                              limit: 255
    t.string   "color_red",                               limit: 255
    t.string   "color_orange",                            limit: 255
    t.string   "color_green",                             limit: 255
    t.string   "color_gray",                              limit: 255
    t.string   "color_black",                             limit: 255
    t.string   "color_white",                             limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "owner_id"
    t.string   "owner_type",                              limit: 255
    t.string   "site_name",                               limit: 255
    t.string   "description",                             limit: 255
    t.string   "tagline",                                 limit: 255
    t.string   "support_email",                           limit: 255
    t.string   "contact_email",                           limit: 255
    t.string   "address",                                 limit: 255
    t.string   "meta_title",                              limit: 255
    t.string   "phone_number",                            limit: 255
    t.string   "support_url",                             limit: 255
    t.string   "blog_url",                                limit: 255
    t.string   "twitter_url",                             limit: 255
    t.string   "facebook_url",                            limit: 255
    t.string   "gplus_url",                               limit: 255
    t.text     "homepage_content"
    t.string   "call_to_action",                          limit: 255
    t.string   "favicon_image",                           limit: 255
    t.text     "homepage_css"
    t.datetime "deleted_at"
    t.text     "icon_image_transformation_data"
    t.string   "icon_image_original_url",                 limit: 255
    t.datetime "icon_image_versions_generated_at"
    t.integer  "icon_image_original_width"
    t.integer  "icon_image_original_height"
    t.text     "icon_retina_image_transformation_data"
    t.string   "icon_retina_image_original_url",          limit: 255
    t.datetime "icon_retina_image_versions_generated_at"
    t.integer  "icon_retina_image_original_width"
    t.integer  "icon_retina_image_original_height"
    t.text     "favicon_image_transformation_data"
    t.string   "favicon_image_original_url",              limit: 255
    t.datetime "favicon_image_versions_generated_at"
    t.integer  "favicon_image_original_width"
    t.integer  "favicon_image_original_height"
    t.text     "logo_image_transformation_data"
    t.string   "logo_image_original_url",                 limit: 255
    t.datetime "logo_image_versions_generated_at"
    t.integer  "logo_image_original_width"
    t.integer  "logo_image_original_height"
    t.text     "logo_retina_image_transformation_data"
    t.string   "logo_retina_image_original_url",          limit: 255
    t.datetime "logo_retina_image_versions_generated_at"
    t.integer  "logo_retina_image_original_width"
    t.integer  "logo_retina_image_original_height"
    t.text     "hero_image_transformation_data"
    t.string   "hero_image_original_url",                 limit: 255
    t.datetime "hero_image_versions_generated_at"
    t.integer  "hero_image_original_width"
    t.integer  "hero_image_original_height"
    t.string   "compiled_dashboard_stylesheet",           limit: 255
    t.string   "theme_digest",                            limit: 40
    t.string   "theme_dashboard_digest",                  limit: 40
    t.string   "compiled_new_dashboard_stylesheet"
    t.string   "theme_new_dashboard_digest"
    t.string   "instagram_url"
    t.integer  "instance_id"
    t.string   "youtube_url"
    t.string   "rss_url"
    t.string   "linkedin_url"
  end

  add_index "themes", ["owner_id", "owner_type"], name: "index_themes_on_owner_id_and_owner_type", using: :btree

  create_table "third_party_integrations", force: :cascade do |t|
    t.integer "instance_id",                null: false
    t.string  "type",                       null: false
    t.string  "environment",                null: false
    t.text    "settings",    default: "{}", null: false
  end

  add_index "third_party_integrations", ["instance_id", "type", "environment"], name: "unique", unique: true, using: :btree

  create_table "topics", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "category_id"
    t.string   "name"
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",                          default: false
    t.string   "cover_image"
    t.integer  "cover_image_original_height"
    t.integer  "cover_image_original_width"
    t.text     "cover_image_transformation_data"
    t.string   "cover_image_original_url"
    t.datetime "cover_image_versions_generated_at"
    t.string   "image"
    t.integer  "image_original_height"
    t.integer  "image_original_width"
    t.text     "image_transformation_data"
    t.string   "image_original_url"
    t.datetime "image_versions_generated_at"
    t.integer  "followers_count",                   default: 0,     null: false
  end

  add_index "topics", ["instance_id", "category_id"], name: "index_topics_on_instance_id_and_category_id", using: :btree

  create_table "topics_user_status_updates", id: false, force: :cascade do |t|
    t.integer "topic_id",              null: false
    t.integer "user_status_update_id", null: false
  end

  add_index "topics_user_status_updates", ["topic_id", "user_status_update_id"], name: "topic_usu_id", using: :btree
  add_index "topics_user_status_updates", ["user_status_update_id", "topic_id"], name: "usu_topic_id", using: :btree

  create_table "transactable_action_types", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "transactable_id"
    t.integer  "transactable_type_action_type_id"
    t.integer  "availability_template_id"
    t.boolean  "enabled"
    t.string   "type"
    t.integer  "minimum_booking_minutes"
    t.boolean  "no_action"
    t.boolean  "action_rfq"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactable_action_types", ["instance_id", "transactable_id", "type"], name: "transactable_action_types_main_idx", using: :btree
  add_index "transactable_action_types", ["instance_id"], name: "index_transactable_action_types_on_instance_id", using: :btree

  create_table "transactable_collaborators", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.integer  "transactable_id"
    t.datetime "approved_by_user_at"
    t.datetime "approved_by_owner_at"
    t.string   "email"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "rejected_by_owner_at"
  end

  add_index "transactable_collaborators", ["instance_id"], name: "index_transactable_collaborators_on_instance_id", using: :btree
  add_index "transactable_collaborators", ["transactable_id"], name: "index_transactable_collaborators_on_transactable_id", using: :btree
  add_index "transactable_collaborators", ["user_id"], name: "index_transactable_collaborators_on_user_id", using: :btree

  create_table "transactable_dimensions_templates", force: :cascade do |t|
    t.integer  "transactable_id",        null: false
    t.integer  "dimensions_template_id", null: false
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  create_table "transactable_pricings", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "transactable_type_pricing_id"
    t.string   "action_type"
    t.integer  "action_id"
    t.integer  "number_of_units"
    t.string   "unit"
    t.integer  "price_cents",                  default: 0
    t.boolean  "has_exclusive_price"
    t.integer  "exclusive_price_cents"
    t.boolean  "has_book_it_out_discount"
    t.integer  "book_it_out_discount"
    t.integer  "book_it_out_minimum_qty"
    t.boolean  "is_free_booking"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pro_rated",                    default: false
  end

  add_index "transactable_pricings", ["instance_id", "action_type", "action_id"], name: "transactable_pricings_main_index", using: :btree
  add_index "transactable_pricings", ["instance_id"], name: "index_transactable_pricings_on_instance_id", using: :btree

  create_table "transactable_topics", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "transactable_id"
    t.integer  "topic_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "transactable_type_action_types", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "transactable_type_id"
    t.boolean  "enabled",                                    default: true
    t.datetime "deleted_at"
    t.string   "type"
    t.integer  "minimum_booking_minutes",                    default: 60
    t.boolean  "action_continuous_dates_booking"
    t.integer  "hours_to_expiration",                        default: 24
    t.datetime "cancellation_policy_enabled"
    t.integer  "cancellation_policy_hours_for_cancellation", default: 0
    t.integer  "cancellation_policy_penalty_percentage",     default: 0
    t.integer  "cancellation_policy_penalty_hours",          default: 0
    t.float    "service_fee_guest_percent",                  default: 0.0
    t.float    "service_fee_host_percent",                   default: 0.0
    t.boolean  "favourable_pricing_rate"
    t.boolean  "allow_custom_pricings"
    t.boolean  "allow_no_action"
    t.boolean  "allow_action_rfq"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confirm_reservations",                       default: true
    t.boolean  "send_alert_hours_before_expiry",             default: false, null: false
    t.integer  "send_alert_hours_before_expiry_hours",       default: 0,     null: false
    t.integer  "minimum_lister_service_fee_cents",           default: 0
    t.boolean  "both_side_confirmation",                     default: false
    t.boolean  "allow_drafts",                               default: false, null: false
    t.integer  "hours_to_order_item_approval"
  end

  add_index "transactable_type_action_types", ["instance_id", "transactable_type_id", "deleted_at"], name: "instance_tt_deleted_at_idx", using: :btree
  add_index "transactable_type_action_types", ["instance_id"], name: "index_transactable_type_action_types_on_instance_id", using: :btree

  create_table "transactable_type_instance_views", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "instance_view_id"
    t.integer  "transactable_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactable_type_instance_views", ["instance_id", "instance_view_id", "transactable_type_id"], name: "index_tt_instance_views_on_instance_id_tt_view_unique", unique: true, using: :btree

  create_table "transactable_type_pricings", force: :cascade do |t|
    t.integer  "instance_id"
    t.string   "action_type"
    t.integer  "action_id"
    t.integer  "number_of_units"
    t.string   "unit"
    t.integer  "min_price_cents",            default: 0
    t.integer  "max_price_cents",            default: 0
    t.boolean  "allow_exclusive_price"
    t.boolean  "allow_book_it_out_discount"
    t.boolean  "allow_free_booking"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "order_class_name"
    t.boolean  "allow_nil_price_cents",      default: false
    t.integer  "fixed_price_cents"
    t.boolean  "pro_rated",                  default: false
  end

  add_index "transactable_type_pricings", ["instance_id", "action_type", "action_id"], name: "action_type_pricings_main_index", using: :btree
  add_index "transactable_type_pricings", ["instance_id"], name: "index_transactable_type_pricings_on_instance_id", using: :btree

  create_table "transactable_types", force: :cascade do |t|
    t.string   "name",                                       limit: 255
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.text     "pricing_options"
    t.text     "pricing_validation"
    t.text     "availability_options"
    t.boolean  "favourable_pricing_rate",                                                        default: true
    t.integer  "days_for_monthly_rate",                                                          default: 0
    t.datetime "cancellation_policy_enabled"
    t.integer  "cancellation_policy_hours_for_cancellation",                                     default: 0
    t.integer  "cancellation_policy_penalty_percentage",                                         default: 0
    t.boolean  "action_recurring_booking",                                                       default: false,      null: false
    t.boolean  "show_page_enabled",                                                              default: false
    t.text     "custom_csv_fields"
    t.boolean  "action_overnight_booking",                                                       default: false,      null: false
    t.text     "onboarding_form_fields"
    t.decimal  "service_fee_guest_percent",                              precision: 5, scale: 2, default: 0.0
    t.decimal  "service_fee_host_percent",                               precision: 5, scale: 2, default: 0.0
    t.string   "bookable_noun",                              limit: 255
    t.string   "lessor",                                     limit: 255
    t.string   "lessee",                                     limit: 255
    t.boolean  "groupable_with_others",                                                          default: true
    t.boolean  "enable_reviews"
    t.boolean  "action_rfq",                                                                     default: false
    t.boolean  "action_hourly_booking",                                                          default: false
    t.boolean  "action_free_booking",                                                            default: false
    t.boolean  "action_daily_booking",                                                           default: false
    t.boolean  "action_monthly_booking",                                                         default: false
    t.boolean  "action_weekly_booking",                                                          default: false
    t.boolean  "action_schedule_booking"
    t.integer  "min_daily_price_cents"
    t.integer  "max_daily_price_cents"
    t.integer  "min_weekly_price_cents"
    t.integer  "max_weekly_price_cents"
    t.integer  "min_monthly_price_cents"
    t.integer  "max_monthly_price_cents"
    t.integer  "min_hourly_price_cents"
    t.integer  "max_hourly_price_cents"
    t.boolean  "manual_payment",                                                                 default: false
    t.boolean  "buyable",                                                                        default: false
    t.boolean  "show_reviews_if_both_completed",                                                 default: false
    t.boolean  "enable_photo_required",                                                          default: true
    t.integer  "hours_to_expiration",                                                            default: 24
    t.integer  "minimum_booking_minutes",                                                        default: 60
    t.boolean  "action_na",                                                                      default: false
    t.boolean  "action_book_it_out"
    t.boolean  "skip_location"
    t.string   "default_currency",                           limit: 255
    t.text     "allowed_currencies"
    t.string   "default_country",                            limit: 255
    t.text     "allowed_countries"
    t.boolean  "action_exclusive_price",                                                         default: false
    t.boolean  "action_price_per_unit",                                                          default: false
    t.string   "type",                                       limit: 255
    t.boolean  "searchable",                                                                     default: true
    t.boolean  "action_regular_booking",                                                         default: true
    t.boolean  "action_continuous_dates_booking",                                                default: false
    t.boolean  "rental_shipping",                                                                default: false
    t.boolean  "search_location_type_filter",                                                    default: true
    t.boolean  "show_company_name",                                                              default: true
    t.string   "slug"
    t.string   "default_search_view"
    t.string   "search_engine"
    t.string   "searcher_type"
    t.integer  "search_radius"
    t.boolean  "show_categories"
    t.string   "category_search_type"
    t.boolean  "allow_save_search"
    t.boolean  "show_price_slider"
    t.boolean  "search_price_types_filter"
    t.boolean  "show_date_pickers"
    t.boolean  "date_pickers_use_availability_rules"
    t.string   "date_pickers_mode"
    t.integer  "position",                                                                       default: 0
    t.string   "timezone_rule",                                                                  default: "location"
    t.boolean  "action_weekly_subscription_booking"
    t.boolean  "action_monthly_subscription_booking"
    t.integer  "default_availability_template_id"
    t.string   "show_path_format"
    t.integer  "reservation_type_id"
    t.boolean  "skip_payment_authorization",                                                     default: false
    t.integer  "hours_for_guest_to_confirm_payment",                                             default: 0
    t.boolean  "single_transactable",                                                            default: false
    t.decimal  "cancellation_policy_penalty_hours",                      precision: 8, scale: 2, default: 0.0
    t.boolean  "display_additional_charges",                                                     default: true
    t.boolean  "single_location",                                                                default: false,      null: false
    t.boolean  "hide_additional_charges_on_listing_page",                                        default: false,      null: false
    t.hstore   "custom_settings",                                                                default: {},         null: false
    t.boolean  "auto_accept_invitation_as_collaborator",                                         default: false
    t.boolean  "require_transactable_during_onboarding",                                         default: true
    t.boolean  "access_restricted_to_invited"
    t.boolean  "auto_seek_collaborators",                                                        default: false
    t.string   "default_sort_by"
  end

  add_index "transactable_types", ["instance_id"], name: "index_transactable_types_on_instance_id", using: :btree
  add_index "transactable_types", ["slug"], name: "index_transactable_types_on_slug", using: :btree

  create_table "transactables", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "partner_id"
    t.integer  "creator_id"
    t.integer  "company_id"
    t.integer  "location_id"
    t.integer  "administrator_id"
    t.hstore   "properties"
    t.datetime "deleted_at"
    t.datetime "draft"
    t.datetime "activated_at"
    t.boolean  "listings_public"
    t.boolean  "enabled",                                                               default: true
    t.text     "metadata"
    t.datetime "created_at",                                                                                null: false
    t.datetime "updated_at",                                                                                null: false
    t.integer  "transactable_type_id"
    t.string   "external_id",                       limit: 255
    t.boolean  "mark_to_be_bulk_update_deleted",                                        default: false
    t.boolean  "action_rfq",                                                            default: false
    t.boolean  "action_hourly_booking",                                                 default: false
    t.boolean  "action_free_booking",                                                   default: false
    t.boolean  "action_recurring_booking",                                              default: false
    t.boolean  "action_daily_booking",                                                  default: false
    t.boolean  "action_schedule_booking"
    t.float    "average_rating",                                                        default: 0.0,       null: false
    t.string   "booking_type",                      limit: 255,                         default: "regular"
    t.boolean  "manual_payment",                                                        default: false
    t.integer  "wish_list_items_count",                                                 default: 0
    t.integer  "quantity",                                                              default: 1
    t.integer  "opened_on_days",                                                        default: [],                     array: true
    t.integer  "minimum_booking_minutes",                                               default: 60
    t.string   "currency",                          limit: 255
    t.string   "name",                              limit: 255
    t.text     "description"
    t.boolean  "confirm_reservations",                                                  default: true
    t.datetime "last_request_photos_sent_at"
    t.string   "capacity",                          limit: 255
    t.string   "rental_shipping_type"
    t.integer  "insurance_value_cents"
    t.boolean  "action_subscription_booking"
    t.string   "slug"
    t.integer  "availability_template_id"
    t.boolean  "featured",                                                              default: false
    t.decimal  "cancellation_policy_penalty_hours",             precision: 8, scale: 2, default: 0.0
    t.boolean  "possible_payout",                                                       default: false
    t.integer  "action_type_id"
    t.string   "available_actions",                                                     default: [],                     array: true
    t.integer  "shipping_profile_id"
    t.boolean  "seek_collaborators",                                                    default: false
    t.integer  "followers_count",                                                       default: 0,         null: false
    t.string   "state"
    t.integer  "impressions_count",                                                     default: 0,         null: false
  end

  add_index "transactables", ["external_id", "location_id"], name: "index_transactables_on_external_id_and_location_id", unique: true, using: :btree
  add_index "transactables", ["opened_on_days"], name: "index_transactables_on_opened_on_days", using: :gin
  add_index "transactables", ["slug"], name: "index_transactables_on_slug", using: :btree
  add_index "transactables", ["transactable_type_id"], name: "index_transactables_on_transactable_type_id", using: :btree

  create_table "transactables_user_status_updates", force: :cascade do |t|
    t.integer "transactable_id"
    t.integer "user_status_update_id"
  end

  add_index "transactables_user_status_updates", ["transactable_id", "user_status_update_id"], name: "transactable_usu_id", using: :btree

  create_table "translations", force: :cascade do |t|
    t.string   "locale",         limit: 255
    t.string   "key",            limit: 255
    t.text     "value"
    t.text     "interpolations"
    t.boolean  "is_proc",                    default: false
    t.integer  "instance_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "translations", ["instance_id", "locale", "key"], name: "index_translations_on_instance_id_and_locale_and_key", unique: true, using: :btree
  add_index "translations", ["instance_id", "updated_at"], name: "index_translations_on_instance_id_and_updated_at", using: :btree

  create_table "unit_prices", force: :cascade do |t|
    t.integer  "transactable_id"
    t.integer  "price_cents"
    t.integer  "period"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "unit_prices", ["transactable_id"], name: "index_unit_prices_on_listing_id", using: :btree

  create_table "upload_obligations", force: :cascade do |t|
    t.string   "level",       limit: 255
    t.integer  "item_id"
    t.string   "item_type",   limit: 255
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "upload_obligations", ["deleted_at"], name: "index_upload_obligations_on_deleted_at", using: :btree
  add_index "upload_obligations", ["instance_id"], name: "index_upload_obligations_on_instance_id", using: :btree
  add_index "upload_obligations", ["item_id", "item_type"], name: "index_upload_obligations_on_item_id_and_item_type", using: :btree

  create_table "user_bans", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_blog_posts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title",                                   limit: 255
    t.string   "slug",                                    limit: 255
    t.string   "hero_image",                              limit: 255
    t.text     "content"
    t.text     "excerpt"
    t.datetime "published_at"
    t.string   "author_name",                             limit: 255
    t.text     "author_biography"
    t.string   "author_avatar_img",                       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "highlighted",                                         default: false
    t.integer  "instance_id"
    t.datetime "author_avatar_img_versions_generated_at"
    t.datetime "hero_image_versions_generated_at"
  end

  create_table "user_blogs", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "enabled",                  default: false
    t.string   "name",         limit: 255
    t.string   "header_logo",  limit: 255
    t.string   "header_icon",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.string   "header_image", limit: 255
  end

  create_table "user_messages", force: :cascade do |t|
    t.integer  "thread_owner_id"
    t.integer  "author_id",                                           null: false
    t.integer  "thread_recipient_id"
    t.integer  "thread_context_id"
    t.string   "thread_context_type",     limit: 255
    t.text     "body"
    t.boolean  "archived_for_owner",                  default: false
    t.boolean  "archived_for_recipient",              default: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "read_for_owner",                      default: false
    t.boolean  "read_for_recipient",                  default: false
    t.datetime "deleted_at"
    t.integer  "instance_id"
    t.datetime "unread_last_reminded_at"
  end

  add_index "user_messages", ["instance_id"], name: "index_user_messages_on_instance_id", using: :btree

  create_table "user_profiles", force: :cascade do |t|
    t.hstore   "properties"
    t.integer  "user_id"
    t.integer  "instance_profile_type_id"
    t.integer  "instance_id"
    t.string   "profile_type"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",                  default: false
    t.datetime "onboarded_at"
    t.boolean  "approved",                 default: false, null: false
    t.integer  "availability_template_id"
  end

  add_index "user_profiles", ["instance_id", "user_id", "profile_type"], name: "index_user_profiles_on_instance_id_and_user_id_and_profile_type", unique: true, using: :btree
  add_index "user_profiles", ["instance_profile_type_id"], name: "index_user_profiles_on_instance_profile_type_id", using: :btree

  create_table "user_relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "deleted_at"
    t.integer  "authentication_id"
    t.integer  "instance_id"
  end

  add_index "user_relationships", ["authentication_id"], name: "index_user_relationships_on_authentication_id", using: :btree
  add_index "user_relationships", ["followed_id"], name: "index_user_relationships_on_followed_id", using: :btree
  add_index "user_relationships", ["follower_id", "followed_id", "deleted_at"], name: "index_user_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "user_relationships", ["follower_id"], name: "index_user_relationships_on_follower_id", using: :btree

  create_table "user_status_updates", force: :cascade do |t|
    t.text     "text"
    t.integer  "user_id"
    t.integer  "instance_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "updateable_id"
    t.string   "updateable_type"
  end

  add_index "user_status_updates", ["instance_id"], name: "index_user_status_updates_on_instance_id", using: :btree
  add_index "user_status_updates", ["updateable_id", "updateable_type"], name: "usu_updateable", using: :btree

  create_table "user_topics", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_topics", ["instance_id", "user_id", "topic_id"], name: "index_user_topics_on_instance_id_and_user_id_and_topic_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                                  limit: 255, default: "",                                                                                  null: false
    t.string   "encrypted_password",                     limit: 128, default: "",                                                                                  null: false
    t.string   "password_salt",                          limit: 255, default: "",                                                                                  null: false
    t.string   "reset_password_token",                   limit: 255
    t.string   "remember_token",                         limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",                     limit: 255
    t.string   "last_sign_in_ip",                        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                                   limit: 255
    t.boolean  "admin"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.datetime "reset_password_sent_at"
    t.integer  "failed_attempts",                                    default: 0
    t.string   "authentication_token",                   limit: 255
    t.string   "avatar",                                 limit: 255
    t.string   "confirmation_token",                     limit: 255
    t.string   "phone",                                  limit: 255
    t.string   "country_name",                           limit: 255
    t.string   "mobile_number",                          limit: 255
    t.datetime "notified_about_mobile_number_issue_at"
    t.text     "referer"
    t.string   "source",                                 limit: 255
    t.string   "campaign",                               limit: 255
    t.datetime "verified_at"
    t.string   "google_analytics_id",                    limit: 255
    t.string   "browser",                                limit: 255
    t.string   "browser_version",                        limit: 255
    t.string   "platform",                               limit: 255
    t.text     "avatar_transformation_data"
    t.string   "avatar_original_url",                    limit: 255
    t.datetime "avatar_versions_generated_at"
    t.integer  "avatar_original_height"
    t.integer  "avatar_original_width"
    t.text     "current_location"
    t.text     "company_name"
    t.string   "slug",                                   limit: 255
    t.float    "last_geolocated_location_longitude"
    t.float    "last_geolocated_location_latitude"
    t.integer  "partner_id"
    t.integer  "instance_id"
    t.integer  "domain_id"
    t.string   "time_zone"
    t.boolean  "sms_notifications_enabled",                          default: true
    t.string   "sms_preferences",                        limit: 255, default: "---\nuser_message: true\nreservation_state_changed: true\nnew_reservation: true\n"
    t.text     "instance_unread_messages_threads_count",             default: "--- {}\n"
    t.text     "metadata"
    t.string   "payment_token",                          limit: 255
    t.boolean  "sso_log_out",                                        default: false
    t.string   "first_name",                             limit: 255
    t.string   "middle_name",                            limit: 255
    t.string   "last_name",                              limit: 255
    t.integer  "billing_address_id"
    t.integer  "shipping_address_id"
    t.float    "seller_average_rating",                              default: 0.0,                                                                                 null: false
    t.datetime "banned_at"
    t.integer  "instance_profile_type_id"
    t.hstore   "properties"
    t.integer  "reservations_count",                                 default: 0
    t.integer  "transactables_count",                                default: 0
    t.float    "buyer_average_rating",                               default: 0.0,                                                                                 null: false
    t.boolean  "public_profile",                                     default: false
    t.boolean  "accept_emails",                                      default: true
    t.string   "saved_searches_alerts_frequency",        limit: 255, default: "daily"
    t.string   "language",                               limit: 2,   default: "en"
    t.integer  "saved_searches_count",                               default: 0
    t.datetime "saved_searches_alert_sent_at"
    t.float    "left_by_seller_average_rating",                      default: 0.0
    t.float    "left_by_buyer_average_rating",                       default: 0.0
    t.boolean  "featured",                                           default: false
    t.boolean  "onboarding_completed",                               default: false
    t.string   "cover_image"
    t.integer  "cover_image_original_height"
    t.integer  "cover_image_original_width"
    t.text     "cover_image_transformation_data"
    t.string   "cover_image_original_url"
    t.datetime "cover_image_versions_generated_at"
    t.boolean  "tutorial_displayed",                                 default: false
    t.integer  "followers_count",                                    default: 0,                                                                                   null: false
    t.integer  "following_count",                                    default: 0,                                                                                   null: false
    t.string   "external_id"
    t.integer  "project_collborations_count",                        default: 0,                                                                                   null: false
    t.boolean  "click_to_call",                                      default: false
    t.integer  "orders_count",                                       default: 0
    t.integer  "transactable_collaborators_count",                   default: 0,                                                                                   null: false
    t.integer  "wish_list_items_count",                              default: 0
    t.float    "product_average_rating",                             default: 0.0
    t.datetime "expires_at"
    t.text     "ui_settings",                                        default: "{}"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["domain_id"], name: "index_users_on_domain_id", using: :btree
  add_index "users", ["instance_id", "email", "external_id"], name: "index_users_on_instance_id_and_email_and_external_id", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "users", ["instance_id", "email"], name: "index_users_on_instance_id_and_email", unique: true, where: "((external_id IS NULL) AND (deleted_at IS NULL))", using: :btree
  add_index "users", ["instance_id", "reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["instance_id", "slug"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["instance_id"], name: "index_users_on_instance_id", using: :btree
  add_index "users", ["instance_profile_type_id"], name: "index_users_on_instance_profile_type_id", using: :btree
  add_index "users", ["partner_id"], name: "index_users_on_partner_id", using: :btree
  add_index "users", ["saved_searches_alerts_frequency", "saved_searches_count", "saved_searches_alert_sent_at"], name: "index_users_on_saved_search_attrs", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255, null: false
    t.integer  "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "waiver_agreement_templates", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "content"
    t.integer  "target_id"
    t.string   "target_type", limit: 255
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "waiver_agreement_templates", ["target_id", "target_type"], name: "index_waiver_agreement_templates_on_target_id_and_target_type", using: :btree

  create_table "waiver_agreements", force: :cascade do |t|
    t.string   "vendor_name",                  limit: 255
    t.string   "guest_name",                   limit: 255
    t.string   "name",                         limit: 255
    t.text     "content"
    t.integer  "target_id"
    t.string   "target_type",                  limit: 255
    t.integer  "waiver_agreement_template_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "waiver_agreements", ["target_id", "target_type"], name: "index_waiver_agreements_on_target_id_and_target_type", using: :btree
  add_index "waiver_agreements", ["waiver_agreement_template_id"], name: "index_waiver_agreements_on_waiver_agreement_template_id", using: :btree

  create_table "webhooks", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "webhookable_id"
    t.string   "webhookable_type",     limit: 255
    t.text     "encrypted_response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "payment_gateway_id"
    t.integer  "merchant_account_id"
    t.string   "type"
    t.string   "state"
    t.text     "error"
    t.string   "payment_gateway_mode"
    t.integer  "retry_count",                      default: 0
    t.string   "external_id"
  end

  add_index "webhooks", ["instance_id", "webhookable_id", "webhookable_type"], name: "index_webhooks_on_instance_id_and_webhookable", using: :btree

  create_table "wish_list_items", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "wish_list_id"
    t.integer  "wishlistable_id"
    t.string   "wishlistable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wish_list_items", ["instance_id", "wish_list_id"], name: "index_wish_list_items_on_instance_id_and_wish_list_id", using: :btree
  add_index "wish_list_items", ["wishlistable_id", "wishlistable_type"], name: "index_wish_list_items_on_wishlistable_id_and_wishlistable_type", using: :btree

  create_table "wish_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "instance_id"
    t.string   "name",        limit: 255
    t.boolean  "default",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wish_lists", ["instance_id", "user_id"], name: "index_wish_lists_on_instance_id_and_user_id", using: :btree

  create_table "workflow_alert_logs", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "workflow_alert_id"
    t.integer  "workflow_alert_weekly_aggregated_log_id"
    t.integer  "workflow_alert_monthly_aggregated_log_id"
    t.string   "alert_type",                               limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_alert_logs", ["instance_id", "alert_type"], name: "index_workflow_alert_logs_on_instance_id_and_alert_type", using: :btree

  create_table "workflow_alert_monthly_aggregated_logs", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "year"
    t.integer  "month"
    t.integer  "email_count",    default: 0, null: false
    t.integer  "sms_count",      default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "api_call_count"
  end

  add_index "workflow_alert_monthly_aggregated_logs", ["instance_id", "year", "month"], name: "wamal_instance_id_year_month_index", unique: true, using: :btree

  create_table "workflow_alert_weekly_aggregated_logs", force: :cascade do |t|
    t.integer  "instance_id"
    t.integer  "year"
    t.integer  "week_number"
    t.integer  "email_count",    default: 0, null: false
    t.integer  "sms_count",      default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "api_call_count"
  end

  add_index "workflow_alert_weekly_aggregated_logs", ["instance_id", "year", "week_number"], name: "wamal_instance_id_year_week_number_index", unique: true, using: :btree

  create_table "workflow_alerts", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.string   "alert_type",                limit: 255
    t.string   "recipient_type",            limit: 255
    t.string   "template_path",             limit: 255
    t.integer  "workflow_step_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delay",                                 default: 0
    t.text     "subject"
    t.string   "layout_path",               limit: 255
    t.text     "custom_options"
    t.string   "from",                      limit: 255
    t.string   "reply_to",                  limit: 255
    t.string   "cc",                        limit: 255
    t.string   "bcc",                       limit: 255
    t.string   "recipient",                 limit: 255
    t.string   "from_type",                 limit: 255
    t.string   "reply_to_type",             limit: 255
    t.text     "endpoint"
    t.string   "request_type"
    t.boolean  "use_ssl"
    t.text     "payload_data",                          default: "{}"
    t.text     "headers",                               default: "{}"
    t.text     "prevent_trigger_condition",             default: "",   null: false
    t.string   "bcc_type"
    t.boolean  "enabled",                               default: true
  end

  add_index "workflow_alerts", ["instance_id", "workflow_step_id"], name: "index_workflow_alerts_on_instance_id_and_workflow_step_id", using: :btree
  add_index "workflow_alerts", ["template_path", "workflow_step_id", "recipient_type", "alert_type", "deleted_at"], name: "index_workflows_alerts_on_templ_step_recipient_alert_and_del", unique: true, using: :btree

  create_table "workflow_alerts_backup_20160926", id: false, force: :cascade do |t|
    t.integer  "id"
    t.string   "name",                      limit: 255
    t.string   "alert_type",                limit: 255
    t.string   "recipient_type",            limit: 255
    t.string   "template_path",             limit: 255
    t.integer  "workflow_step_id"
    t.integer  "instance_id"
    t.text     "options"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delay"
    t.text     "subject"
    t.string   "layout_path",               limit: 255
    t.text     "custom_options"
    t.string   "from",                      limit: 255
    t.string   "reply_to",                  limit: 255
    t.string   "cc",                        limit: 255
    t.string   "bcc",                       limit: 255
    t.string   "recipient",                 limit: 255
    t.string   "from_type",                 limit: 255
    t.string   "reply_to_type",             limit: 255
    t.text     "endpoint"
    t.string   "request_type"
    t.boolean  "use_ssl"
    t.text     "payload_data"
    t.text     "headers"
    t.text     "prevent_trigger_condition"
    t.string   "bcc_type"
  end

  create_table "workflow_steps", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "associated_class", limit: 255
    t.integer  "instance_id"
    t.integer  "workflow_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_steps", ["associated_class", "instance_id", "deleted_at"], name: "index_workflow_steps_on_assoc_class_and_instance_and_deleted", unique: true, using: :btree

  create_table "workflows", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "events_metadata"
    t.string   "workflow_type",   limit: 255
  end

end
