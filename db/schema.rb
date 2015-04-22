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

ActiveRecord::Schema.define(version: 20150422084454) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "btree_gin"
  enable_extension "btree_gist"
  enable_extension "hstore"

  create_table "action_types", force: true do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "additional_charge_types", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "amount_cents"
    t.string   "currency"
    t.string   "commission_receiver"
    t.integer  "provider_commission_percentage"
    t.string   "status"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "additional_charge_types", ["instance_id"], name: "index_additional_charge_types_on_instance_id", using: :btree

  create_table "additional_charges", force: true do |t|
    t.string   "name"
    t.integer  "amount_cents"
    t.string   "currency"
    t.string   "commission_receiver"
    t.string   "status"
    t.integer  "additional_charge_type_id"
    t.integer  "instance_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "additional_charges", ["additional_charge_type_id"], name: "index_additional_charges_on_additional_charge_type_id", using: :btree
  add_index "additional_charges", ["instance_id"], name: "index_additional_charges_on_instance_id", using: :btree
  add_index "additional_charges", ["target_id"], name: "index_additional_charges_on_target_id", using: :btree

  create_table "addresses", force: true do |t|
    t.integer  "instance_id"
    t.string   "address"
    t.string   "address2"
    t.string   "formatted_address"
    t.string   "street"
    t.string   "suburb"
    t.string   "city"
    t.string   "country"
    t.string   "state"
    t.string   "postcode",           limit: 10
    t.text     "address_components"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "entity_id"
    t.string   "entity_type"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "iso_country_code",   limit: 2
  end

  add_index "addresses", ["entity_id", "entity_type", "address"], name: "index_addresses_on_entity_id_and_entity_type_and_address", unique: true, using: :btree

  create_table "amenities", force: true do |t|
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "amenity_type_id"
  end

  add_index "amenities", ["amenity_type_id"], name: "index_amenities_on_amenity_type_id", using: :btree

  create_table "amenity_holders", force: true do |t|
    t.integer  "amenity_id"
    t.integer  "holder_id"
    t.string   "holder_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted_at"
  end

  add_index "amenity_holders", ["amenity_id"], name: "index_amenity_holders_on_amenity_id", using: :btree
  add_index "amenity_holders", ["holder_id", "holder_type"], name: "index_amenity_holders_on_holder_id_and_holder_type", using: :btree

  create_table "amenity_types", force: true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "instance_id"
    t.string   "type"
  end

  add_index "amenity_types", ["instance_id"], name: "index_amenity_types_on_instance_id", using: :btree

  create_table "approval_request_attachment_templates", force: true do |t|
    t.integer  "instance_id"
    t.integer  "approval_request_template_id"
    t.boolean  "required",                     default: false
    t.string   "label"
    t.text     "hint"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_request_attachments", force: true do |t|
    t.string   "caption"
    t.integer  "instance_id"
    t.integer  "uploader_id"
    t.string   "file"
    t.text     "comment"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "approval_request_id"
    t.integer  "approval_request_attachment_template_id"
    t.boolean  "required",                                default: false
    t.string   "label"
    t.text     "hint"
  end

  add_index "approval_request_attachments", ["instance_id"], name: "index_approval_request_attachments_on_instance_id", using: :btree
  add_index "approval_request_attachments", ["uploader_id"], name: "index_approval_request_attachments_on_uploader_id", using: :btree

  create_table "approval_request_templates", force: true do |t|
    t.integer  "instance_id"
    t.string   "owner_type"
    t.boolean  "required_written_verification", default: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_requests", force: true do |t|
    t.string   "state"
    t.string   "message"
    t.string   "notes"
    t.integer  "instance_id"
    t.integer  "approval_request_template_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.boolean  "required_written_verification"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "approval_requests", ["owner_id", "owner_type"], name: "index_approval_requests_on_owner_id_and_owner_type", using: :btree

  create_table "assigned_waiver_agreement_templates", force: true do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "waiver_agreement_template_id"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assigned_waiver_agreement_templates", ["target_id", "target_type"], name: "awat_target_id_and_target_type", using: :btree
  add_index "assigned_waiver_agreement_templates", ["waiver_agreement_template_id"], name: "awat_wat_id", using: :btree

  create_table "attachments", force: true do |t|
    t.string   "type"
    t.string   "file"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.integer  "instance_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachments", ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type", using: :btree
  add_index "attachments", ["instance_id"], name: "index_attachments_on_instance_id", using: :btree
  add_index "attachments", ["user_id"], name: "index_attachments_on_user_id", using: :btree

  create_table "authentications", force: true do |t|
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
    t.boolean  "token_expired",            default: true
    t.boolean  "token_expires",            default: true
    t.text     "profile_url"
    t.integer  "total_social_connections", default: 0
    t.integer  "instance_id"
    t.datetime "information_fetched"
  end

  add_index "authentications", ["instance_id", "provider", "user_id"], name: "one_provider_type_per_user_index", unique: true, using: :btree
  add_index "authentications", ["instance_id", "uid", "provider"], name: "one_active_provider_uid_pair_per_marketplace", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "availability_rules", force: true do |t|
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "day"
    t.integer  "open_hour"
    t.integer  "open_minute"
    t.integer  "close_hour"
    t.integer  "close_minute"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
  end

  add_index "availability_rules", ["target_type", "target_id"], name: "index_availability_rules_on_target_type_and_target_id", using: :btree

  create_table "availability_templates", force: true do |t|
    t.integer  "transactable_type_id"
    t.integer  "instance_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "availability_templates", ["instance_id", "transactable_type_id"], name: "availability_templates_on_instance_id_and_tt_id", using: :btree

  create_table "billing_authorizations", force: true do |t|
    t.integer  "instance_id"
    t.integer  "reservation_id"
    t.string   "encrypted_token"
    t.string   "encrypted_payment_gateway_class"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "payment_gateway_mode"
    t.string   "reference_type"
    t.integer  "reference_id"
    t.boolean  "success",                         default: false
    t.text     "encrypted_response"
    t.integer  "user_id"
    t.datetime "void_at"
    t.text     "void_response"
  end

  add_index "billing_authorizations", ["reference_id", "reference_type"], name: "index_billing_authorizations_on_reference_id_and_reference_type", using: :btree

  create_table "blog_instances", force: true do |t|
    t.string   "name"
    t.string   "header"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "facebook_app_id"
    t.boolean  "enabled",         default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "header_logo"
    t.string   "header_icon"
    t.string   "header_text"
    t.string   "header_motto"
  end

  create_table "blog_posts", force: true do |t|
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
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "excerpt"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.integer  "position",                default: 0
    t.integer  "instance_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "permalink"
    t.text     "description"
    t.string   "meta_title"
    t.string   "meta_description"
    t.string   "meta_keywords"
    t.boolean  "in_top_nav",              default: false
    t.integer  "top_nav_positions"
    t.string   "categorable_type"
    t.integer  "categorable_id"
    t.datetime "deleted_at"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "multiple_root_categries"
  end

  add_index "categories", ["categorable_id"], name: "index_categories_on_categorable_id", using: :btree
  add_index "categories", ["instance_id"], name: "index_categories_on_instance_id", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["partner_id"], name: "index_categories_on_partner_id", using: :btree
  add_index "categories", ["user_id"], name: "index_categories_on_user_id", using: :btree

  create_table "categories_transactables", force: true do |t|
    t.integer  "category_id"
    t.integer  "transactable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories_transactables", ["category_id"], name: "index_categories_transactables_on_category_id", using: :btree
  add_index "categories_transactables", ["transactable_id"], name: "index_categories_transactables_on_transactable_id", using: :btree

  create_table "charges", force: true do |t|
    t.integer  "payment_id"
    t.boolean  "success"
    t.integer  "amount"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
    t.string   "currency"
    t.text     "encrypted_response"
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "instance_id"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree
  add_index "ckeditor_assets", ["instance_id"], name: "index_ckeditor_assets_on_instance_id", using: :btree

  create_table "companies", force: true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.string   "email"
    t.text     "description"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.datetime "deleted_at"
    t.string   "url"
    t.string   "paypal_email"
    t.text     "mailing_address"
    t.string   "external_id"
    t.integer  "instance_id"
    t.boolean  "white_label_enabled", default: false
    t.boolean  "listings_public",     default: true
    t.integer  "partner_id"
    t.text     "metadata"
    t.integer  "mailing_address_id"
  end

  add_index "companies", ["creator_id"], name: "index_companies_on_creator_id", using: :btree
  add_index "companies", ["external_id", "instance_id"], name: "companies_external_id_uni_idx", unique: true, where: "((external_id IS NOT NULL) AND (deleted_at IS NULL))", using: :btree
  add_index "companies", ["instance_id", "listings_public"], name: "index_companies_on_instance_id_and_listings_public", using: :btree
  add_index "companies", ["partner_id"], name: "index_companies_on_partner_id", using: :btree

  create_table "company_industries", force: true do |t|
    t.integer  "industry_id"
    t.integer  "company_id"
    t.datetime "deleted_at"
  end

  add_index "company_industries", ["industry_id", "company_id"], name: "index_company_industries_on_industry_id_and_company_id", using: :btree

  create_table "company_users", force: true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "company_users", ["company_id"], name: "index_company_users_on_company_id", using: :btree
  add_index "company_users", ["user_id"], name: "index_company_users_on_user_id", using: :btree

  create_table "content_holders", force: true do |t|
    t.string   "name"
    t.integer  "theme_id"
    t.integer  "instance_id"
    t.text     "content"
    t.boolean  "enabled",     default: true
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_holders", ["instance_id", "theme_id", "name"], name: "index_content_holders_on_instance_id_and_theme_id_and_name", using: :btree

  create_table "country_instance_payment_gateways", force: true do |t|
    t.string   "country_alpha2_code"
    t.integer  "instance_payment_gateway_id"
    t.integer  "instance_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "credit_cards", force: true do |t|
    t.integer  "instance_client_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.string   "gateway_class"
    t.text     "encrypted_response"
    t.boolean  "default_card"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_cards", ["instance_client_id"], name: "index_credit_cards_on_instance_client_id", using: :btree
  add_index "credit_cards", ["instance_id"], name: "index_credit_cards_on_instance_id", using: :btree

  create_table "custom_attributes", force: true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.integer  "transactable_type_id"
    t.string   "attribute_type"
    t.string   "html_tag"
    t.string   "prompt"
    t.string   "default_value"
    t.boolean  "public",               default: true
    t.text     "validation_rules"
    t.text     "valid_values"
    t.datetime "deleted_at"
    t.string   "label"
    t.text     "input_html_options"
    t.text     "wrapper_html_options"
    t.text     "hint"
    t.string   "placeholder"
    t.boolean  "internal",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "target_id"
    t.string   "target_type"
    t.boolean  "searchable",           default: false
  end

  add_index "custom_attributes", ["instance_id", "transactable_type_id"], name: "index_tta_on_instance_id_and_transactable_type_id", using: :btree
  add_index "custom_attributes", ["target_id", "target_type"], name: "index_custom_attributes_on_target_id_and_target_type", using: :btree

  create_table "data_uploads", force: true do |t|
    t.string   "csv_file"
    t.string   "xml_file"
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
    t.string   "target_type"
    t.integer  "progress_percentage"
    t.string   "state"
    t.string   "importable_type"
  end

  add_index "data_uploads", ["importable_id", "importable_type"], name: "index_data_uploads_on_importable_id_and_importable_type", using: :btree
  add_index "data_uploads", ["instance_id"], name: "index_data_uploads_on_instance_id", using: :btree
  add_index "data_uploads", ["target_id", "target_type"], name: "index_data_uploads_on_target_id_and_target_type", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",    default: 20
    t.integer  "attempts",    default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "instance_id"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dimensions_templates", force: true do |t|
    t.string   "name"
    t.integer  "creator_id"
    t.integer  "instance_id"
    t.decimal  "weight",          precision: 8, scale: 2
    t.decimal  "height",          precision: 8, scale: 2
    t.decimal  "width",           precision: 8, scale: 2
    t.decimal  "depth",           precision: 8, scale: 2
    t.string   "unit_of_measure",                         default: "imperial"
    t.string   "weight_unit",                             default: "oz"
    t.string   "height_unit",                             default: "in"
    t.string   "width_unit",                              default: "in"
    t.string   "depth_unit",                              default: "in"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "details"
    t.datetime "deleted_at"
    t.boolean  "use_as_default",                          default: false
  end

  create_table "document_requirements", force: true do |t|
    t.string   "label"
    t.text     "description"
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "document_requirements", ["deleted_at"], name: "index_document_requirements_on_deleted_at", using: :btree
  add_index "document_requirements", ["instance_id"], name: "index_document_requirements_on_instance_id", using: :btree
  add_index "document_requirements", ["item_id", "item_type"], name: "index_document_requirements_on_item_id_and_item_type", using: :btree

  create_table "documents_uploads", force: true do |t|
    t.boolean  "enabled",     default: false
    t.string   "requirement"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "deleted_at"
    t.boolean  "secured",                        default: false
    t.string   "google_analytics_tracking_code"
    t.string   "state"
    t.string   "load_balancer_name"
    t.string   "server_certificate_name"
    t.string   "error_message"
    t.string   "dns_name"
    t.string   "redirect_to"
    t.integer  "redirect_code"
    t.boolean  "use_as_default",                 default: false
  end

  add_index "domains", ["deleted_at"], name: "index_domains_on_deleted_at", using: :btree
  add_index "domains", ["name"], name: "index_domains_on_name", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "domains", ["target_id", "target_type"], name: "index_domains_on_target_id_and_target_type", using: :btree

  create_table "email_templates", force: true do |t|
    t.text     "html_body"
    t.text     "text_body"
    t.string   "path"
    t.string   "from"
    t.string   "to"
    t.string   "bcc"
    t.string   "reply_to"
    t.string   "subject"
    t.boolean  "partial",      default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "theme_id"
    t.boolean  "custom_email", default: false
  end

  add_index "email_templates", ["theme_id"], name: "index_email_templates_on_theme_id", using: :btree

  create_table "form_components", force: true do |t|
    t.string   "name"
    t.string   "form_type"
    t.integer  "instance_id"
    t.integer  "form_componentable_id"
    t.text     "form_fields"
    t.datetime "deleted_at"
    t.integer  "rank"
    t.string   "form_componentable_type"
    t.boolean  "is_approval_request_surfacing", default: false
  end

  add_index "form_components", ["instance_id", "form_componentable_id", "form_type"], name: "ttfs_instance_tt_form_type", using: :btree

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
    t.string   "scope"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "impressions", force: true do |t|
    t.integer  "impressionable_id"
    t.string   "impressionable_type"
    t.string   "ip_address"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.datetime "deleted_at"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "instance_id"
  end

  add_index "impressions", ["company_id"], name: "index_impressions_on_company_id", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id"], name: "index_impressions_on_impressionable_type_and_impressionable_id", using: :btree
  add_index "impressions", ["instance_id"], name: "index_impressions_on_instance_id", using: :btree
  add_index "impressions", ["partner_id"], name: "index_impressions_on_partner_id", using: :btree

  create_table "industries", force: true do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "instance_id"
  end

  create_table "inquiries", force: true do |t|
    t.integer  "transactable_id"
    t.integer  "inquiring_user_id"
    t.text     "message"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "inquiries", ["inquiring_user_id"], name: "index_inquiries_on_inquiring_user_id", using: :btree
  add_index "inquiries", ["transactable_id"], name: "index_inquiries_on_listing_id", using: :btree

  create_table "instance_admin_roles", force: true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.boolean  "permission_settings",        default: false
    t.boolean  "permission_theme",           default: false
    t.boolean  "permission_analytics",       default: true
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "permission_manage",          default: false
    t.boolean  "permission_blog",            default: false
    t.boolean  "permission_support",         default: false
    t.boolean  "permission_buysell",         default: false
    t.boolean  "permission_shippingoptions", default: false
  end

  add_index "instance_admin_roles", ["instance_id"], name: "index_instance_admin_roles_on_instance_id", using: :btree

  create_table "instance_admins", force: true do |t|
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
  add_index "instance_admins", ["user_id"], name: "index_instance_admins_on_user_id", using: :btree

  create_table "instance_billing_gateways", force: true do |t|
    t.integer  "instance_id"
    t.string   "billing_gateway"
    t.string   "currency",        default: "USD"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "instance_billing_gateways", ["instance_id"], name: "index_instance_billing_gateways_on_instance_id", using: :btree

  create_table "instance_clients", force: true do |t|
    t.integer  "client_id"
    t.string   "client_type"
    t.integer  "instance_id"
    t.string   "encrypted_balanced_user_id"
    t.string   "bank_account_last_four_digits"
    t.datetime "deleted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "gateway_class"
    t.text     "encrypted_response"
  end

  create_table "instance_creators", force: true do |t|
    t.string   "email"
    t.boolean  "created_instance"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instance_creators", ["email"], name: "index_instance_creators_on_email", using: :btree

  create_table "instance_payment_gateways", force: true do |t|
    t.integer  "instance_id"
    t.integer  "payment_gateway_id"
    t.text     "encrypted_live_settings"
    t.text     "encrypted_test_settings"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "instance_profile_types", force: true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "deleted_at"
  end

  create_table "instance_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "product_type"
  end

  create_table "instance_views", force: true do |t|
    t.integer  "instance_type_id"
    t.integer  "instance_id"
    t.text     "body"
    t.string   "path"
    t.string   "locale"
    t.string   "format"
    t.string   "handler"
    t.boolean  "partial",              default: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "view_type"
    t.integer  "transactable_type_id"
  end

  add_index "instance_views", ["instance_id", "transactable_type_id", "path", "locale", "format", "handler"], name: "instance_path_with_format_and_handler", unique: true, using: :btree

  create_table "instances", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                                                                            null: false
    t.datetime "updated_at",                                                                            null: false
    t.string   "bookable_noun",                                                 default: "Desk"
    t.decimal  "service_fee_guest_percent",             precision: 5, scale: 2, default: 0.0
    t.string   "lessor"
    t.string   "lessee"
    t.boolean  "skip_company",                                                  default: false
    t.text     "pricing_options"
    t.decimal  "service_fee_host_percent",              precision: 5, scale: 2, default: 0.0
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
    t.boolean  "password_protected",                                            default: false
    t.boolean  "test_mode",                                                     default: false
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
    t.boolean  "olark_enabled",                                                 default: false
    t.string   "encrypted_facebook_consumer_key"
    t.string   "encrypted_facebook_consumer_secret"
    t.string   "encrypted_linkedin_consumer_key"
    t.string   "encrypted_linkedin_consumer_secret"
    t.string   "encrypted_twitter_consumer_key"
    t.string   "encrypted_twitter_consumer_secret"
    t.string   "encrypted_instagram_consumer_key"
    t.string   "encrypted_instagram_consumer_secret"
    t.integer  "instance_type_id"
    t.text     "metadata"
    t.string   "support_email"
    t.string   "encrypted_db_connection_string"
    t.string   "stripe_currency",                                               default: "USD"
    t.boolean  "user_info_in_onboarding_flow",                                  default: false
    t.string   "default_search_view",                                           default: "mixed"
    t.boolean  "user_based_marketplace_views",                                  default: false
    t.string   "searcher_type",                                                 default: "geo"
    t.datetime "master_lock"
    t.boolean  "apply_text_filters",                                            default: false
    t.text     "user_required_fields"
    t.boolean  "force_accepting_tos"
    t.text     "custom_sanitize_config"
    t.string   "payment_transfers_frequency",                                   default: "fortnightly"
    t.text     "hidden_ui_controls"
    t.string   "encrypted_shippo_username"
    t.string   "encrypted_shippo_password"
    t.string   "twilio_from_number"
    t.string   "test_twilio_from_number"
    t.string   "encrypted_test_twilio_consumer_key"
    t.string   "encrypted_test_twilio_consumer_secret"
    t.string   "encrypted_twilio_consumer_key"
    t.string   "encrypted_twilio_consumer_secret"
    t.boolean  "user_blogs_enabled",                                            default: false
    t.boolean  "wish_lists_enabled",                                            default: false
    t.string   "wish_lists_icon_set",                                           default: "heart"
    t.boolean  "possible_manual_payment"
    t.string   "support_imap_username"
    t.string   "encrypted_support_imap_password"
    t.string   "support_imap_server"
    t.integer  "support_imap_port"
    t.boolean  "support_imap_ssl"
    t.hstore   "search_settings",                                               default: {},            null: false
    t.string   "default_country"
    t.text     "allowed_countries"
  end

  add_index "instances", ["instance_type_id"], name: "index_instances_on_instance_type_id", using: :btree

  create_table "listing_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "instance_id"
  end

  add_index "listing_types", ["instance_id"], name: "index_listing_types_on_instance_id", using: :btree

  create_table "locales", force: true do |t|
    t.integer  "instance_id"
    t.string   "code"
    t.string   "custom_name"
    t.boolean  "primary",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locales", ["instance_id", "code"], name: "index_locales_on_instance_id_and_code", unique: true, using: :btree

  create_table "location_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "instance_id"
  end

  add_index "location_types", ["instance_id"], name: "index_location_types_on_instance_id", using: :btree

  create_table "locations", force: true do |t|
    t.integer  "company_id"
    t.string   "email"
    t.text     "description"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "info"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
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
    t.boolean  "listings_public",                default: true
    t.integer  "partner_id"
    t.integer  "address_id"
    t.string   "external_id"
    t.boolean  "mark_to_be_bulk_update_deleted", default: false
    t.integer  "wish_list_items_count",          default: 0
    t.integer  "opened_on_days",                 default: [],                 array: true
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

  create_table "mailer_unsubscriptions", force: true do |t|
    t.integer  "user_id"
    t.string   "mailer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "mailer_unsubscriptions", ["user_id", "mailer"], name: "index_mailer_unsubscriptions_on_user_id_and_mailer", unique: true, using: :btree
  add_index "mailer_unsubscriptions", ["user_id"], name: "index_mailer_unsubscriptions_on_user_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "path",                              null: false
    t.text     "content"
    t.string   "hero_image"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "theme_id"
    t.string   "slug"
    t.integer  "position"
    t.text     "html_content"
    t.datetime "deleted_at"
    t.string   "redirect_url"
    t.boolean  "open_in_new_window", default: true
    t.integer  "instance_id"
    t.text     "css_content"
  end

  add_index "pages", ["instance_id"], name: "index_pages_on_instance_id", using: :btree
  add_index "pages", ["theme_id"], name: "index_pages_on_theme_id", using: :btree

  create_table "partner_inquiries", force: true do |t|
    t.string   "name"
    t.string   "company_name"
    t.string   "email"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "partners", force: true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "search_scope_option", default: "no_scoping"
  end

  create_table "payment_document_infos", force: true do |t|
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

  create_table "payment_gateways", force: true do |t|
    t.string   "name"
    t.string   "method_name"
    t.text     "settings"
    t.string   "active_merchant_class"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "payment_transfers", force: true do |t|
    t.integer  "company_id"
    t.datetime "transferred_at"
    t.string   "currency"
    t.integer  "amount_cents",                   default: 0, null: false
    t.integer  "service_fee_amount_guest_cents", default: 0, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "service_fee_amount_host_cents",  default: 0, null: false
    t.datetime "deleted_at"
    t.integer  "instance_id"
    t.integer  "partner_id"
  end

  add_index "payment_transfers", ["company_id"], name: "index_payment_transfers_on_company_id", using: :btree
  add_index "payment_transfers", ["instance_id"], name: "index_payment_transfers_on_instance_id", using: :btree
  add_index "payment_transfers", ["partner_id"], name: "index_payment_transfers_on_partner_id", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "reservation_id"
    t.integer  "subtotal_amount_cents"
    t.integer  "service_fee_amount_guest_cents"
    t.datetime "paid_at"
    t.datetime "failed_at"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "currency"
    t.datetime "deleted_at"
    t.integer  "payment_transfer_id"
    t.integer  "service_fee_amount_host_cents",              default: 0, null: false
    t.datetime "refunded_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "cancellation_policy_hours_for_cancellation", default: 0
    t.integer  "cancellation_policy_penalty_percentage",     default: 0
    t.text     "recurring_booking_error"
    t.string   "payable_type"
    t.integer  "payable_id"
  end

  add_index "payments", ["company_id"], name: "index_payments_on_company_id", using: :btree
  add_index "payments", ["instance_id"], name: "index_payments_on_instance_id", using: :btree
  add_index "payments", ["partner_id"], name: "index_payments_on_partner_id", using: :btree
  add_index "payments", ["payable_id", "payable_type"], name: "index_payments_on_payable_id_and_payable_type", using: :btree
  add_index "payments", ["payment_transfer_id"], name: "index_payments_on_payment_transfer_id", using: :btree
  add_index "payments", ["reservation_id"], name: "index_payments_on_reservation_id", using: :btree

  create_table "payouts", force: true do |t|
    t.integer  "reference_id"
    t.string   "reference_type"
    t.boolean  "success"
    t.integer  "amount"
    t.string   "currency"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.text     "encrypted_response"
    t.datetime "deleted_at"
    t.boolean  "pending",            default: false
  end

  create_table "photos", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "transactable_id"
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
    t.integer  "instance_id"
    t.boolean  "mark_to_be_bulk_update_deleted", default: false
  end

  add_index "photos", ["creator_id"], name: "index_photos_on_creator_id", using: :btree
  add_index "photos", ["instance_id"], name: "index_photos_on_instance_id", using: :btree
  add_index "photos", ["transactable_id"], name: "index_photos_on_listing_id", using: :btree

  create_table "platform_contacts", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "subject"
    t.text     "comments"
    t.boolean  "subscribed",        default: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "company"
    t.string   "marketplace_type"
    t.string   "referer"
    t.string   "lead_source"
    t.string   "location"
    t.string   "previous_research"
    t.string   "phone"
  end

  create_table "platform_demo_requests", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "company"
    t.string   "phone"
    t.text     "comments"
    t.boolean  "subscribed", default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "platform_emails", force: true do |t|
    t.string   "email"
    t.datetime "notified_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "platform_inquiries", force: true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "industry"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rating_answers", force: true do |t|
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

  create_table "rating_hints", force: true do |t|
    t.string   "value"
    t.string   "description"
    t.integer  "rating_system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  add_index "rating_hints", ["deleted_at"], name: "index_rating_hints_on_deleted_at", using: :btree
  add_index "rating_hints", ["instance_id"], name: "index_rating_hints_on_instance_id", using: :btree
  add_index "rating_hints", ["rating_system_id"], name: "index_rating_hints_on_rating_system_id", using: :btree

  create_table "rating_questions", force: true do |t|
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

  create_table "rating_systems", force: true do |t|
    t.string   "subject"
    t.integer  "transactable_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.boolean  "active",               default: false
    t.datetime "deleted_at"
  end

  add_index "rating_systems", ["deleted_at"], name: "index_rating_systems_on_deleted_at", using: :btree
  add_index "rating_systems", ["instance_id"], name: "index_rating_systems_on_instance_id", using: :btree
  add_index "rating_systems", ["transactable_type_id"], name: "index_rating_systems_on_transactable_type_id", using: :btree

  create_table "recurring_bookings", force: true do |t|
    t.integer  "transactable_id"
    t.integer  "owner_id"
    t.integer  "creator_id"
    t.integer  "administrator_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "instance_id"
    t.boolean  "listings_public"
    t.datetime "deleted_at"
    t.date     "start_on"
    t.date     "end_on"
    t.integer  "quantity"
    t.integer  "start_minute"
    t.integer  "end_minute"
    t.text     "schedule_params"
    t.string   "state"
    t.string   "currency"
    t.string   "payment_method",                     default: "manual", null: false
    t.integer  "platform_context_detail_id"
    t.string   "platform_context_detail_type"
    t.integer  "service_fee_amount_guest_cents",     default: 0,        null: false
    t.integer  "service_fee_amount_host_cents",      default: 0,        null: false
    t.integer  "subtotal_amount_cents"
    t.string   "rejection_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "credit_card_id"
    t.integer  "hours_before_reservation_to_charge", default: 24
    t.integer  "occurrences"
  end

  add_index "recurring_bookings", ["administrator_id"], name: "index_recurring_bookings_on_administrator_id", using: :btree
  add_index "recurring_bookings", ["company_id"], name: "index_recurring_bookings_on_company_id", using: :btree
  add_index "recurring_bookings", ["creator_id"], name: "index_recurring_bookings_on_creator_id", using: :btree
  add_index "recurring_bookings", ["instance_id"], name: "index_recurring_bookings_on_instance_id", using: :btree
  add_index "recurring_bookings", ["owner_id"], name: "index_recurring_bookings_on_owner_id", using: :btree
  add_index "recurring_bookings", ["transactable_id"], name: "index_recurring_bookings_on_transactable_id", using: :btree

  create_table "refunds", force: true do |t|
    t.integer  "payment_id"
    t.boolean  "success"
    t.text     "encrypted_response"
    t.integer  "amount"
    t.string   "currency"
    t.datetime "deleted_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "instance_id"
  end

  create_table "reservation_periods", force: true do |t|
    t.integer  "reservation_id"
    t.date     "date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "deleted_at"
    t.integer  "start_minute"
    t.integer  "end_minute"
  end

  add_index "reservation_periods", ["reservation_id"], name: "index_reservation_periods_on_reservation_id", using: :btree

  create_table "reservation_seats", force: true do |t|
    t.integer  "reservation_period_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.datetime "deleted_at"
  end

  add_index "reservation_seats", ["reservation_period_id"], name: "index_reservation_seats_on_reservation_period_id", using: :btree
  add_index "reservation_seats", ["user_id"], name: "index_reservation_seats_on_user_id", using: :btree

  create_table "reservations", force: true do |t|
    t.integer  "transactable_id"
    t.integer  "owner_id"
    t.string   "state"
    t.string   "confirmation_email"
    t.integer  "subtotal_amount_cents"
    t.string   "currency"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.datetime "deleted_at"
    t.text     "comment"
    t.boolean  "create_charge"
    t.string   "payment_method",                                default: "manual",  null: false
    t.string   "payment_status",                                default: "unknown", null: false
    t.integer  "quantity",                                      default: 1,         null: false
    t.integer  "service_fee_amount_guest_cents"
    t.string   "rejection_reason"
    t.integer  "service_fee_amount_host_cents",                 default: 0,         null: false
    t.integer  "platform_context_detail_id"
    t.string   "platform_context_detail_type"
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.integer  "administrator_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.boolean  "listings_public",                               default: true
    t.datetime "confirmed_at"
    t.datetime "cancelled_at"
    t.integer  "cancellation_policy_hours_for_cancellation",    default: 0
    t.integer  "cancellation_policy_penalty_percentage",        default: 0
    t.integer  "recurring_booking_id"
    t.integer  "credit_card_id"
    t.datetime "request_guest_rating_email_sent_at"
    t.datetime "request_host_and_product_rating_email_sent_at"
    t.string   "type"
    t.string   "reservation_type"
    t.integer  "hours_to_expiration",                           default: 24,        null: false
    t.integer  "minimum_booking_minutes",                       default: 60
    t.integer  "book_it_out_discount"
  end

  add_index "reservations", ["administrator_id"], name: "index_reservations_on_administrator_id", using: :btree
  add_index "reservations", ["company_id"], name: "index_reservations_on_company_id", using: :btree
  add_index "reservations", ["creator_id"], name: "index_reservations_on_creator_id", using: :btree
  add_index "reservations", ["instance_id"], name: "index_reservations_on_instance_id", using: :btree
  add_index "reservations", ["owner_id"], name: "index_reservations_on_owner_id", using: :btree
  add_index "reservations", ["partner_id"], name: "index_reservations_on_partner_id", using: :btree
  add_index "reservations", ["platform_context_detail_id"], name: "index_reservations_on_platform_context_detail_id", using: :btree
  add_index "reservations", ["recurring_booking_id"], name: "index_reservations_on_recurring_booking_id", using: :btree
  add_index "reservations", ["transactable_id"], name: "index_reservations_on_listing_id", using: :btree

  create_table "reviews", force: true do |t|
    t.integer  "rating"
    t.string   "object"
    t.text     "comment"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reviewable_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.integer  "transactable_type_id"
    t.string   "reviewable_type"
  end

  add_index "reviews", ["deleted_at"], name: "index_reviews_on_deleted_at", using: :btree
  add_index "reviews", ["instance_id"], name: "index_reviews_on_instance_id", using: :btree
  add_index "reviews", ["reviewable_id", "reviewable_type"], name: "index_reviews_on_reviewable_id_and_reviewable_type", using: :btree
  add_index "reviews", ["reviewable_id"], name: "index_reviews_on_reviewable_id", using: :btree
  add_index "reviews", ["reviewable_type"], name: "index_reviews_on_reviewable_type", using: :btree
  add_index "reviews", ["transactable_type_id"], name: "index_reviews_on_transactable_type_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "saved_search_alert_logs", force: true do |t|
    t.integer  "instance_id"
    t.integer  "saved_search_id"
    t.integer  "results_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saved_search_alert_logs", ["instance_id"], name: "index_saved_search_alert_logs_on_instance_id", using: :btree
  add_index "saved_search_alert_logs", ["saved_search_id", "created_at"], name: "index_saved_search_alert_logs_on_saved_search_id_and_created_at", using: :btree

  create_table "saved_searches", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.text     "query"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "new_results", default: 0
    t.datetime "last_viewed_at"
  end

  add_index "saved_searches", ["title", "user_id"], name: "index_saved_searches_on_title_and_user_id", unique: true, using: :btree

  create_table "schedules", force: true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "schedule"
    t.string   "scheduable_type"
    t.integer  "scheduable_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.boolean  "exception",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schedules", ["instance_id", "scheduable_id", "scheduable_type"], name: "index_schedules_scheduable", using: :btree

  create_table "spree_addresses", force: true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "zipcode"
    t.string   "phone"
    t.string   "state_name"
    t.string   "alternative_phone"
    t.string   "company"
    t.integer  "state_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_addresses", ["country_id"], name: "index_spree_addresses_on_country_id", using: :btree
  add_index "spree_addresses", ["firstname"], name: "index_addresses_on_firstname", using: :btree
  add_index "spree_addresses", ["lastname"], name: "index_addresses_on_lastname", using: :btree
  add_index "spree_addresses", ["state_id"], name: "index_spree_addresses_on_state_id", using: :btree

  create_table "spree_adjustments", force: true do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "adjustable_id"
    t.string   "adjustable_type"
    t.decimal  "amount",          precision: 10, scale: 2
    t.string   "label"
    t.boolean  "mandatory"
    t.boolean  "eligible",                                 default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.integer  "order_id"
    t.boolean  "included",                                 default: false
  end

  add_index "spree_adjustments", ["adjustable_id", "adjustable_type"], name: "index_spree_adjustments_on_adjustable_id_and_adjustable_type", using: :btree
  add_index "spree_adjustments", ["adjustable_id"], name: "index_adjustments_on_order_id", using: :btree
  add_index "spree_adjustments", ["eligible"], name: "index_spree_adjustments_on_eligible", using: :btree
  add_index "spree_adjustments", ["order_id"], name: "index_spree_adjustments_on_order_id", using: :btree
  add_index "spree_adjustments", ["source_id", "source_type"], name: "index_spree_adjustments_on_source_id_and_source_type", using: :btree

  create_table "spree_assets", force: true do |t|
    t.integer  "viewable_id"
    t.string   "viewable_type"
    t.integer  "attachment_width"
    t.integer  "attachment_height"
    t.integer  "attachment_file_size"
    t.integer  "position"
    t.string   "attachment_content_type"
    t.string   "attachment_file_name"
    t.string   "type",                        limit: 75
    t.datetime "attachment_updated_at"
    t.text     "alt"
    t.string   "image"
    t.string   "image_original_url"
    t.datetime "image_versions_generated_at"
    t.text     "image_transformation_data"
    t.integer  "image_original_height"
    t.integer  "image_original_width"
    t.string   "remote_image_url"
    t.integer  "uploader_id"
    t.integer  "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_assets", ["viewable_id"], name: "index_assets_on_viewable_id", using: :btree
  add_index "spree_assets", ["viewable_type", "type"], name: "index_assets_on_viewable_type_and_type", using: :btree

  create_table "spree_calculators", force: true do |t|
    t.string   "type"
    t.integer  "calculable_id"
    t.string   "calculable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.text     "preferences"
  end

  add_index "spree_calculators", ["calculable_id", "calculable_type"], name: "index_spree_calculators_on_calculable_id_and_calculable_type", using: :btree
  add_index "spree_calculators", ["company_id"], name: "index_spree_calculators_on_company_id", using: :btree
  add_index "spree_calculators", ["id", "type"], name: "index_spree_calculators_on_id_and_type", using: :btree
  add_index "spree_calculators", ["instance_id"], name: "index_spree_calculators_on_instance_id", using: :btree
  add_index "spree_calculators", ["partner_id"], name: "index_spree_calculators_on_partner_id", using: :btree
  add_index "spree_calculators", ["user_id"], name: "index_spree_calculators_on_user_id", using: :btree

  create_table "spree_configurations", force: true do |t|
    t.string   "name"
    t.string   "type",       limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_configurations", ["name", "type"], name: "index_spree_configurations_on_name_and_type", using: :btree

  create_table "spree_countries", force: true do |t|
    t.string   "iso_name"
    t.string   "iso"
    t.string   "iso3"
    t.string   "name"
    t.integer  "numcode"
    t.boolean  "states_required", default: false
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_countries", ["company_id"], name: "index_spree_countries_on_company_id", using: :btree
  add_index "spree_countries", ["instance_id"], name: "index_spree_countries_on_instance_id", using: :btree
  add_index "spree_countries", ["partner_id"], name: "index_spree_countries_on_partner_id", using: :btree
  add_index "spree_countries", ["user_id"], name: "index_spree_countries_on_user_id", using: :btree

  create_table "spree_credit_cards", force: true do |t|
    t.string   "month"
    t.string   "year"
    t.string   "cc_type"
    t.string   "last_digits"
    t.integer  "address_id"
    t.string   "gateway_customer_profile_id"
    t.string   "gateway_payment_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "user_id"
    t.integer  "payment_method_id"
  end

  add_index "spree_credit_cards", ["address_id"], name: "index_spree_credit_cards_on_address_id", using: :btree
  add_index "spree_credit_cards", ["payment_method_id"], name: "index_spree_credit_cards_on_payment_method_id", using: :btree
  add_index "spree_credit_cards", ["user_id"], name: "index_spree_credit_cards_on_user_id", using: :btree

  create_table "spree_gateways", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.boolean  "active",      default: true
    t.string   "environment", default: "development"
    t.string   "server",      default: "test"
    t.boolean  "test_mode",   default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "preferences"
  end

  add_index "spree_gateways", ["active"], name: "index_spree_gateways_on_active", using: :btree
  add_index "spree_gateways", ["test_mode"], name: "index_spree_gateways_on_test_mode", using: :btree

  create_table "spree_inventory_units", force: true do |t|
    t.string   "state"
    t.integer  "variant_id"
    t.integer  "order_id"
    t.integer  "shipment_id"
    t.integer  "return_authorization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pending",                 default: true
    t.integer  "line_item_id"
  end

  add_index "spree_inventory_units", ["line_item_id"], name: "index_spree_inventory_units_on_line_item_id", using: :btree
  add_index "spree_inventory_units", ["order_id"], name: "index_inventory_units_on_order_id", using: :btree
  add_index "spree_inventory_units", ["return_authorization_id"], name: "index_spree_inventory_units_on_return_authorization_id", using: :btree
  add_index "spree_inventory_units", ["shipment_id"], name: "index_inventory_units_on_shipment_id", using: :btree
  add_index "spree_inventory_units", ["variant_id"], name: "index_inventory_units_on_variant_id", using: :btree

  create_table "spree_line_items", force: true do |t|
    t.integer  "variant_id"
    t.integer  "order_id"
    t.integer  "quantity",                                                                             null: false
    t.decimal  "price",                                         precision: 10, scale: 2,               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.decimal  "cost_price",                                    precision: 10, scale: 2
    t.integer  "tax_category_id"
    t.decimal  "adjustment_total",                              precision: 10, scale: 2, default: 0.0
    t.decimal  "additional_tax_total",                          precision: 10, scale: 2, default: 0.0
    t.decimal  "promo_total",                                   precision: 10, scale: 2, default: 0.0
    t.decimal  "included_tax_total",                            precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "pre_tax_amount",                                precision: 8,  scale: 2, default: 0.0
    t.integer  "payment_transfer_id"
    t.decimal  "service_fee_amount_guest_cents",                precision: 5,  scale: 2, default: 0.0
    t.decimal  "service_fee_amount_host_cents",                 precision: 5,  scale: 2, default: 0.0
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.datetime "request_guest_rating_email_sent_at"
    t.datetime "request_host_and_product_rating_email_sent_at"
  end

  add_index "spree_line_items", ["company_id"], name: "index_spree_line_items_on_company_id", using: :btree
  add_index "spree_line_items", ["instance_id"], name: "index_spree_line_items_on_instance_id", using: :btree
  add_index "spree_line_items", ["order_id"], name: "index_spree_line_items_on_order_id", using: :btree
  add_index "spree_line_items", ["partner_id"], name: "index_spree_line_items_on_partner_id", using: :btree
  add_index "spree_line_items", ["tax_category_id"], name: "index_spree_line_items_on_tax_category_id", using: :btree
  add_index "spree_line_items", ["user_id"], name: "index_spree_line_items_on_user_id", using: :btree
  add_index "spree_line_items", ["variant_id"], name: "index_spree_line_items_on_variant_id", using: :btree

  create_table "spree_log_entries", force: true do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_log_entries", ["company_id"], name: "index_spree_log_entries_on_company_id", using: :btree
  add_index "spree_log_entries", ["instance_id"], name: "index_spree_log_entries_on_instance_id", using: :btree
  add_index "spree_log_entries", ["partner_id"], name: "index_spree_log_entries_on_partner_id", using: :btree
  add_index "spree_log_entries", ["source_id", "source_type"], name: "index_spree_log_entries_on_source_id_and_source_type", using: :btree
  add_index "spree_log_entries", ["user_id"], name: "index_spree_log_entries_on_user_id", using: :btree

  create_table "spree_option_types", force: true do |t|
    t.string   "name",         limit: 100
    t.string   "presentation", limit: 100
    t.integer  "position",                 default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_option_types", ["company_id"], name: "index_spree_option_types_on_company_id", using: :btree
  add_index "spree_option_types", ["instance_id"], name: "index_spree_option_types_on_instance_id", using: :btree
  add_index "spree_option_types", ["partner_id"], name: "index_spree_option_types_on_partner_id", using: :btree
  add_index "spree_option_types", ["position"], name: "index_spree_option_types_on_position", using: :btree
  add_index "spree_option_types", ["user_id"], name: "index_spree_option_types_on_user_id", using: :btree

  create_table "spree_option_types_prototypes", id: false, force: true do |t|
    t.integer "prototype_id"
    t.integer "option_type_id"
  end

  create_table "spree_option_values", force: true do |t|
    t.integer  "position"
    t.string   "name"
    t.string   "presentation"
    t.integer  "option_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_option_values", ["company_id"], name: "index_spree_option_values_on_company_id", using: :btree
  add_index "spree_option_values", ["instance_id"], name: "index_spree_option_values_on_instance_id", using: :btree
  add_index "spree_option_values", ["option_type_id"], name: "index_spree_option_values_on_option_type_id", using: :btree
  add_index "spree_option_values", ["partner_id"], name: "index_spree_option_values_on_partner_id", using: :btree
  add_index "spree_option_values", ["position"], name: "index_spree_option_values_on_position", using: :btree
  add_index "spree_option_values", ["user_id"], name: "index_spree_option_values_on_user_id", using: :btree

  create_table "spree_option_values_variants", id: false, force: true do |t|
    t.integer "variant_id"
    t.integer "option_value_id"
  end

  add_index "spree_option_values_variants", ["variant_id", "option_value_id"], name: "index_option_values_variants_on_variant_id_and_option_value_id", using: :btree
  add_index "spree_option_values_variants", ["variant_id"], name: "index_spree_option_values_variants_on_variant_id", using: :btree

  create_table "spree_orders", force: true do |t|
    t.string   "number",                         limit: 32
    t.decimal  "item_total",                                precision: 10, scale: 2, default: 0.0,     null: false
    t.decimal  "total",                                     precision: 10, scale: 2, default: 0.0,     null: false
    t.string   "state"
    t.decimal  "adjustment_total",                          precision: 10, scale: 2, default: 0.0,     null: false
    t.integer  "user_id"
    t.datetime "completed_at"
    t.integer  "bill_address_id"
    t.integer  "ship_address_id"
    t.decimal  "payment_total",                             precision: 10, scale: 2, default: 0.0
    t.integer  "shipping_method_id"
    t.string   "shipment_state"
    t.string   "payment_state"
    t.string   "email"
    t.text     "special_instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.string   "last_ip_address"
    t.integer  "created_by_id"
    t.decimal  "shipment_total",                            precision: 10, scale: 2, default: 0.0,     null: false
    t.decimal  "additional_tax_total",                      precision: 10, scale: 2, default: 0.0
    t.decimal  "promo_total",                               precision: 10, scale: 2, default: 0.0
    t.string   "channel",                                                            default: "spree"
    t.decimal  "included_tax_total",                        precision: 10, scale: 2, default: 0.0,     null: false
    t.integer  "item_count",                                                         default: 0
    t.integer  "approver_id"
    t.datetime "approved_at"
    t.boolean  "confirmation_delivered",                                             default: false
    t.boolean  "considered_risky",                                                   default: false
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.decimal  "service_fee_buyer_percent",                 precision: 5,  scale: 2, default: 0.0
    t.decimal  "service_fee_seller_percent",                precision: 5,  scale: 2, default: 0.0
    t.datetime "shippo_rate_purchased_at"
    t.string   "guest_token"
    t.integer  "state_lock_version",                                                 default: 0,       null: false
    t.integer  "platform_context_detail_id"
    t.string   "platform_context_detail_type"
    t.integer  "service_fee_amount_guest_cents",                                     default: 0
    t.integer  "service_fee_amount_host_cents",                                      default: 0
    t.string   "payment_method"
  end

  add_index "spree_orders", ["approver_id"], name: "index_spree_orders_on_approver_id", using: :btree
  add_index "spree_orders", ["bill_address_id"], name: "index_spree_orders_on_bill_address_id", using: :btree
  add_index "spree_orders", ["company_id"], name: "index_spree_orders_on_company_id", using: :btree
  add_index "spree_orders", ["completed_at"], name: "index_spree_orders_on_completed_at", using: :btree
  add_index "spree_orders", ["confirmation_delivered"], name: "index_spree_orders_on_confirmation_delivered", using: :btree
  add_index "spree_orders", ["considered_risky"], name: "index_spree_orders_on_considered_risky", using: :btree
  add_index "spree_orders", ["created_by_id"], name: "index_spree_orders_on_created_by_id", using: :btree
  add_index "spree_orders", ["guest_token"], name: "index_spree_orders_on_guest_token", using: :btree
  add_index "spree_orders", ["instance_id"], name: "index_spree_orders_on_instance_id", using: :btree
  add_index "spree_orders", ["number"], name: "index_spree_orders_on_number", using: :btree
  add_index "spree_orders", ["partner_id"], name: "index_spree_orders_on_partner_id", using: :btree
  add_index "spree_orders", ["platform_context_detail_id", "platform_context_detail_type"], name: "index_spree_orders_on_platform_context_detail", using: :btree
  add_index "spree_orders", ["ship_address_id"], name: "index_spree_orders_on_ship_address_id", using: :btree
  add_index "spree_orders", ["shipping_method_id"], name: "index_spree_orders_on_shipping_method_id", using: :btree
  add_index "spree_orders", ["user_id", "created_by_id"], name: "index_spree_orders_on_user_id_and_created_by_id", using: :btree
  add_index "spree_orders", ["user_id"], name: "index_spree_orders_on_user_id", using: :btree

  create_table "spree_orders_promotions", id: false, force: true do |t|
    t.integer "order_id"
    t.integer "promotion_id"
  end

  add_index "spree_orders_promotions", ["order_id", "promotion_id"], name: "index_spree_orders_promotions_on_order_id_and_promotion_id", using: :btree

  create_table "spree_payment_capture_events", force: true do |t|
    t.decimal  "amount",     precision: 10, scale: 2, default: 0.0
    t.integer  "payment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_payment_capture_events", ["payment_id"], name: "index_spree_payment_capture_events_on_payment_id", using: :btree

  create_table "spree_payment_methods", force: true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.boolean  "active",       default: true
    t.string   "environment",  default: "development"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_on"
    t.boolean  "auto_capture"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.text     "preferences"
  end

  add_index "spree_payment_methods", ["company_id"], name: "index_spree_payment_methods_on_company_id", using: :btree
  add_index "spree_payment_methods", ["id", "type"], name: "index_spree_payment_methods_on_id_and_type", using: :btree
  add_index "spree_payment_methods", ["instance_id"], name: "index_spree_payment_methods_on_instance_id", using: :btree
  add_index "spree_payment_methods", ["partner_id"], name: "index_spree_payment_methods_on_partner_id", using: :btree
  add_index "spree_payment_methods", ["user_id"], name: "index_spree_payment_methods_on_user_id", using: :btree

  create_table "spree_payments", force: true do |t|
    t.decimal  "amount",               precision: 10, scale: 2, default: 0.0, null: false
    t.integer  "order_id"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "payment_method_id"
    t.string   "state"
    t.string   "response_code"
    t.string   "avs_response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier"
    t.string   "cvv_response_code"
    t.string   "cvv_response_message"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_payments", ["company_id"], name: "index_spree_payments_on_company_id", using: :btree
  add_index "spree_payments", ["instance_id"], name: "index_spree_payments_on_instance_id", using: :btree
  add_index "spree_payments", ["order_id"], name: "index_spree_payments_on_order_id", using: :btree
  add_index "spree_payments", ["partner_id"], name: "index_spree_payments_on_partner_id", using: :btree
  add_index "spree_payments", ["payment_method_id"], name: "index_spree_payments_on_payment_method_id", using: :btree
  add_index "spree_payments", ["source_id", "source_type"], name: "index_spree_payments_on_source_id_and_source_type", using: :btree
  add_index "spree_payments", ["user_id"], name: "index_spree_payments_on_user_id", using: :btree

  create_table "spree_preferences", force: true do |t|
    t.text     "value"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_preferences", ["company_id"], name: "index_spree_preferences_on_company_id", using: :btree
  add_index "spree_preferences", ["instance_id"], name: "index_spree_preferences_on_instance_id", using: :btree
  add_index "spree_preferences", ["partner_id"], name: "index_spree_preferences_on_partner_id", using: :btree
  add_index "spree_preferences", ["user_id"], name: "index_spree_preferences_on_user_id", using: :btree

  create_table "spree_prices", force: true do |t|
    t.integer  "variant_id",                          null: false
    t.decimal  "amount",     precision: 10, scale: 2
    t.string   "currency"
    t.datetime "deleted_at"
  end

  add_index "spree_prices", ["deleted_at"], name: "index_spree_prices_on_deleted_at", using: :btree
  add_index "spree_prices", ["variant_id", "currency"], name: "index_spree_prices_on_variant_id_and_currency", using: :btree

  create_table "spree_product_option_types", force: true do |t|
    t.integer  "position"
    t.integer  "product_id"
    t.integer  "option_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_product_option_types", ["option_type_id"], name: "index_spree_product_option_types_on_option_type_id", using: :btree
  add_index "spree_product_option_types", ["position"], name: "index_spree_product_option_types_on_position", using: :btree
  add_index "spree_product_option_types", ["product_id"], name: "index_spree_product_option_types_on_product_id", using: :btree

  create_table "spree_product_properties", force: true do |t|
    t.string   "value"
    t.integer  "product_id"
    t.integer  "property_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",    default: 0
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_product_properties", ["company_id"], name: "index_spree_product_properties_on_company_id", using: :btree
  add_index "spree_product_properties", ["instance_id"], name: "index_spree_product_properties_on_instance_id", using: :btree
  add_index "spree_product_properties", ["partner_id"], name: "index_spree_product_properties_on_partner_id", using: :btree
  add_index "spree_product_properties", ["position"], name: "index_spree_product_properties_on_position", using: :btree
  add_index "spree_product_properties", ["product_id"], name: "index_product_properties_on_product_id", using: :btree
  add_index "spree_product_properties", ["property_id"], name: "index_spree_product_properties_on_property_id", using: :btree
  add_index "spree_product_properties", ["user_id"], name: "index_spree_product_properties_on_user_id", using: :btree

  create_table "spree_product_types", force: true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.text     "custom_csv_fields"
    t.boolean  "action_rfq"
    t.boolean  "possible_manual_payment"
  end

  create_table "spree_products", force: true do |t|
    t.string   "name",                    default: "",    null: false
    t.text     "description"
    t.datetime "available_on"
    t.datetime "deleted_at"
    t.string   "slug"
    t.text     "meta_description"
    t.string   "meta_keywords"
    t.integer  "tax_category_id"
    t.integer  "shipping_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.hstore   "extra_properties"
    t.hstore   "status"
    t.boolean  "products_public",         default: true
    t.boolean  "approved",                default: true
    t.text     "cross_sell_skus",         default: [],                 array: true
    t.integer  "administrator_id"
    t.boolean  "shippo_enabled",          default: false
    t.boolean  "draft",                   default: false
    t.float    "average_rating",          default: 0.0,   null: false
    t.integer  "wish_list_items_count",   default: 0
    t.integer  "product_type_id"
    t.string   "external_id"
    t.boolean  "action_rfq"
    t.boolean  "possible_manual_payment"
  end

  add_index "spree_products", ["available_on"], name: "index_spree_products_on_available_on", using: :btree
  add_index "spree_products", ["company_id"], name: "index_spree_products_on_company_id", using: :btree
  add_index "spree_products", ["deleted_at"], name: "index_spree_products_on_deleted_at", using: :btree
  add_index "spree_products", ["external_id", "company_id"], name: "index_spree_products_on_external_id_and_company_id", unique: true, using: :btree
  add_index "spree_products", ["extra_properties"], name: "spree_products_gin_extra_properties", using: :gin
  add_index "spree_products", ["instance_id"], name: "index_spree_products_on_instance_id", using: :btree
  add_index "spree_products", ["name"], name: "index_spree_products_on_name", using: :btree
  add_index "spree_products", ["partner_id"], name: "index_spree_products_on_partner_id", using: :btree
  add_index "spree_products", ["product_type_id"], name: "index_spree_products_on_product_type_id", using: :btree
  add_index "spree_products", ["shipping_category_id"], name: "index_spree_products_on_shipping_category_id", using: :btree
  add_index "spree_products", ["slug"], name: "index_spree_products_on_slug", using: :btree
  add_index "spree_products", ["slug"], name: "permalink_idx_unique", unique: true, using: :btree
  add_index "spree_products", ["tax_category_id"], name: "index_spree_products_on_tax_category_id", using: :btree
  add_index "spree_products", ["user_id"], name: "index_spree_products_on_user_id", using: :btree

  create_table "spree_products_promotion_rules", id: false, force: true do |t|
    t.integer "product_id"
    t.integer "promotion_rule_id"
  end

  add_index "spree_products_promotion_rules", ["product_id"], name: "index_products_promotion_rules_on_product_id", using: :btree
  add_index "spree_products_promotion_rules", ["promotion_rule_id"], name: "index_products_promotion_rules_on_promotion_rule_id", using: :btree

  create_table "spree_products_taxons", force: true do |t|
    t.integer "product_id"
    t.integer "taxon_id"
    t.integer "position"
  end

  add_index "spree_products_taxons", ["position"], name: "index_spree_products_taxons_on_position", using: :btree
  add_index "spree_products_taxons", ["product_id"], name: "index_spree_products_taxons_on_product_id", using: :btree
  add_index "spree_products_taxons", ["taxon_id"], name: "index_spree_products_taxons_on_taxon_id", using: :btree

  create_table "spree_promotion_action_line_items", force: true do |t|
    t.integer "promotion_action_id"
    t.integer "variant_id"
    t.integer "quantity",            default: 1
  end

  add_index "spree_promotion_action_line_items", ["promotion_action_id"], name: "index_spree_promotion_action_line_items_on_promotion_action_id", using: :btree
  add_index "spree_promotion_action_line_items", ["variant_id"], name: "index_spree_promotion_action_line_items_on_variant_id", using: :btree

  create_table "spree_promotion_actions", force: true do |t|
    t.integer  "promotion_id"
    t.integer  "position"
    t.string   "type"
    t.datetime "deleted_at"
  end

  add_index "spree_promotion_actions", ["deleted_at"], name: "index_spree_promotion_actions_on_deleted_at", using: :btree
  add_index "spree_promotion_actions", ["id", "type"], name: "index_spree_promotion_actions_on_id_and_type", using: :btree
  add_index "spree_promotion_actions", ["promotion_id"], name: "index_spree_promotion_actions_on_promotion_id", using: :btree

  create_table "spree_promotion_rules", force: true do |t|
    t.integer  "promotion_id"
    t.integer  "user_id"
    t.integer  "product_group_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.text     "preferences"
  end

  add_index "spree_promotion_rules", ["product_group_id"], name: "index_promotion_rules_on_product_group_id", using: :btree
  add_index "spree_promotion_rules", ["promotion_id"], name: "index_spree_promotion_rules_on_promotion_id", using: :btree
  add_index "spree_promotion_rules", ["user_id"], name: "index_promotion_rules_on_user_id", using: :btree

  create_table "spree_promotion_rules_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "promotion_rule_id"
  end

  add_index "spree_promotion_rules_users", ["promotion_rule_id"], name: "index_promotion_rules_users_on_promotion_rule_id", using: :btree
  add_index "spree_promotion_rules_users", ["user_id"], name: "index_promotion_rules_users_on_user_id", using: :btree

  create_table "spree_promotions", force: true do |t|
    t.string   "description"
    t.datetime "expires_at"
    t.datetime "starts_at"
    t.string   "name"
    t.string   "type"
    t.integer  "usage_limit"
    t.string   "match_policy", default: "all"
    t.string   "code"
    t.boolean  "advertise",    default: false
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_promotions", ["advertise"], name: "index_spree_promotions_on_advertise", using: :btree
  add_index "spree_promotions", ["code"], name: "index_spree_promotions_on_code", using: :btree
  add_index "spree_promotions", ["company_id"], name: "index_spree_promotions_on_company_id", using: :btree
  add_index "spree_promotions", ["expires_at"], name: "index_spree_promotions_on_expires_at", using: :btree
  add_index "spree_promotions", ["id", "type"], name: "index_spree_promotions_on_id_and_type", using: :btree
  add_index "spree_promotions", ["instance_id"], name: "index_spree_promotions_on_instance_id", using: :btree
  add_index "spree_promotions", ["partner_id"], name: "index_spree_promotions_on_partner_id", using: :btree
  add_index "spree_promotions", ["starts_at"], name: "index_spree_promotions_on_starts_at", using: :btree
  add_index "spree_promotions", ["user_id"], name: "index_spree_promotions_on_user_id", using: :btree

  create_table "spree_properties", force: true do |t|
    t.string   "name"
    t.string   "presentation", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_properties", ["company_id"], name: "index_spree_properties_on_company_id", using: :btree
  add_index "spree_properties", ["instance_id"], name: "index_spree_properties_on_instance_id", using: :btree
  add_index "spree_properties", ["partner_id"], name: "index_spree_properties_on_partner_id", using: :btree
  add_index "spree_properties", ["user_id"], name: "index_spree_properties_on_user_id", using: :btree

  create_table "spree_properties_prototypes", id: false, force: true do |t|
    t.integer "prototype_id"
    t.integer "property_id"
  end

  create_table "spree_prototypes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_prototypes", ["company_id"], name: "index_spree_prototypes_on_company_id", using: :btree
  add_index "spree_prototypes", ["instance_id"], name: "index_spree_prototypes_on_instance_id", using: :btree
  add_index "spree_prototypes", ["partner_id"], name: "index_spree_prototypes_on_partner_id", using: :btree
  add_index "spree_prototypes", ["user_id"], name: "index_spree_prototypes_on_user_id", using: :btree

  create_table "spree_return_authorizations", force: true do |t|
    t.string   "number"
    t.string   "state"
    t.decimal  "amount",            precision: 10, scale: 2, default: 0.0, null: false
    t.integer  "order_id"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stock_location_id"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_return_authorizations", ["company_id"], name: "index_spree_return_authorizations_on_company_id", using: :btree
  add_index "spree_return_authorizations", ["instance_id"], name: "index_spree_return_authorizations_on_instance_id", using: :btree
  add_index "spree_return_authorizations", ["number"], name: "index_spree_return_authorizations_on_number", using: :btree
  add_index "spree_return_authorizations", ["order_id"], name: "index_spree_return_authorizations_on_order_id", using: :btree
  add_index "spree_return_authorizations", ["partner_id"], name: "index_spree_return_authorizations_on_partner_id", using: :btree
  add_index "spree_return_authorizations", ["stock_location_id"], name: "index_spree_return_authorizations_on_stock_location_id", using: :btree
  add_index "spree_return_authorizations", ["user_id"], name: "index_spree_return_authorizations_on_user_id", using: :btree

  create_table "spree_roles", force: true do |t|
    t.string  "name"
    t.integer "instance_id"
    t.integer "company_id"
    t.integer "partner_id"
    t.integer "user_id"
  end

  add_index "spree_roles", ["company_id"], name: "index_spree_roles_on_company_id", using: :btree
  add_index "spree_roles", ["instance_id"], name: "index_spree_roles_on_instance_id", using: :btree
  add_index "spree_roles", ["partner_id"], name: "index_spree_roles_on_partner_id", using: :btree
  add_index "spree_roles", ["user_id"], name: "index_spree_roles_on_user_id", using: :btree

  create_table "spree_roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "spree_roles_users", ["role_id"], name: "index_spree_roles_users_on_role_id", using: :btree
  add_index "spree_roles_users", ["user_id"], name: "index_spree_roles_users_on_user_id", using: :btree

  create_table "spree_shipments", force: true do |t|
    t.string   "tracking"
    t.string   "number"
    t.decimal  "cost",                 precision: 10, scale: 2, default: 0.0
    t.datetime "shipped_at"
    t.integer  "order_id"
    t.integer  "address_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stock_location_id"
    t.decimal  "adjustment_total",     precision: 10, scale: 2, default: 0.0
    t.decimal  "additional_tax_total", precision: 10, scale: 2, default: 0.0
    t.decimal  "promo_total",          precision: 10, scale: 2, default: 0.0
    t.decimal  "included_tax_total",   precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "pre_tax_amount",       precision: 8,  scale: 2, default: 0.0
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_shipments", ["address_id"], name: "index_spree_shipments_on_address_id", using: :btree
  add_index "spree_shipments", ["company_id"], name: "index_spree_shipments_on_company_id", using: :btree
  add_index "spree_shipments", ["instance_id"], name: "index_spree_shipments_on_instance_id", using: :btree
  add_index "spree_shipments", ["number"], name: "index_shipments_on_number", using: :btree
  add_index "spree_shipments", ["order_id"], name: "index_spree_shipments_on_order_id", using: :btree
  add_index "spree_shipments", ["partner_id"], name: "index_spree_shipments_on_partner_id", using: :btree
  add_index "spree_shipments", ["stock_location_id"], name: "index_spree_shipments_on_stock_location_id", using: :btree
  add_index "spree_shipments", ["user_id"], name: "index_spree_shipments_on_user_id", using: :btree

  create_table "spree_shipping_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.boolean  "company_default",                  default: false
    t.boolean  "is_system_profile",                default: false
    t.integer  "from_system_shipping_category_id"
    t.boolean  "is_system_category_enabled",       default: true
  end

  add_index "spree_shipping_categories", ["company_id"], name: "index_spree_shipping_categories_on_company_id", using: :btree
  add_index "spree_shipping_categories", ["instance_id"], name: "index_spree_shipping_categories_on_instance_id", using: :btree
  add_index "spree_shipping_categories", ["partner_id"], name: "index_spree_shipping_categories_on_partner_id", using: :btree
  add_index "spree_shipping_categories", ["user_id"], name: "index_spree_shipping_categories_on_user_id", using: :btree

  create_table "spree_shipping_method_categories", force: true do |t|
    t.integer  "shipping_method_id",   null: false
    t.integer  "shipping_category_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_shipping_method_categories", ["shipping_category_id", "shipping_method_id"], name: "unique_spree_shipping_method_categories", unique: true, using: :btree
  add_index "spree_shipping_method_categories", ["shipping_method_id"], name: "index_spree_shipping_method_categories_on_shipping_method_id", using: :btree

  create_table "spree_shipping_methods", force: true do |t|
    t.string   "name"
    t.string   "display_on"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tracking_url"
    t.string   "admin_name"
    t.integer  "tax_category_id"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.integer  "processing_time",                                            default: 0
    t.integer  "order_id"
    t.decimal  "precalculated_cost",                 precision: 8, scale: 2
    t.string   "shippo_rate_id",         limit: 230
    t.text     "shippo_label_url"
    t.text     "shippo_tracking_number"
  end

  add_index "spree_shipping_methods", ["company_id"], name: "index_spree_shipping_methods_on_company_id", using: :btree
  add_index "spree_shipping_methods", ["deleted_at"], name: "index_spree_shipping_methods_on_deleted_at", using: :btree
  add_index "spree_shipping_methods", ["instance_id"], name: "index_spree_shipping_methods_on_instance_id", using: :btree
  add_index "spree_shipping_methods", ["order_id"], name: "index_spree_shipping_methods_on_order_id", using: :btree
  add_index "spree_shipping_methods", ["partner_id"], name: "index_spree_shipping_methods_on_partner_id", using: :btree
  add_index "spree_shipping_methods", ["tax_category_id"], name: "index_spree_shipping_methods_on_tax_category_id", using: :btree
  add_index "spree_shipping_methods", ["user_id"], name: "index_spree_shipping_methods_on_user_id", using: :btree

  create_table "spree_shipping_methods_zones", id: false, force: true do |t|
    t.integer "shipping_method_id"
    t.integer "zone_id"
  end

  create_table "spree_shipping_rates", force: true do |t|
    t.integer  "shipment_id"
    t.integer  "shipping_method_id"
    t.boolean  "selected",                                   default: false
    t.decimal  "cost",               precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tax_rate_id"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_shipping_rates", ["company_id"], name: "index_spree_shipping_rates_on_company_id", using: :btree
  add_index "spree_shipping_rates", ["instance_id"], name: "index_spree_shipping_rates_on_instance_id", using: :btree
  add_index "spree_shipping_rates", ["partner_id"], name: "index_spree_shipping_rates_on_partner_id", using: :btree
  add_index "spree_shipping_rates", ["selected"], name: "index_spree_shipping_rates_on_selected", using: :btree
  add_index "spree_shipping_rates", ["shipment_id", "shipping_method_id"], name: "spree_shipping_rates_join_index", unique: true, using: :btree
  add_index "spree_shipping_rates", ["tax_rate_id"], name: "index_spree_shipping_rates_on_tax_rate_id", using: :btree
  add_index "spree_shipping_rates", ["user_id"], name: "index_spree_shipping_rates_on_user_id", using: :btree

  create_table "spree_state_changes", force: true do |t|
    t.string   "name"
    t.string   "previous_state"
    t.integer  "stateful_id"
    t.integer  "user_id"
    t.string   "stateful_type"
    t.string   "next_state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_state_changes", ["stateful_id", "stateful_type"], name: "index_spree_state_changes_on_stateful_id_and_stateful_type", using: :btree
  add_index "spree_state_changes", ["user_id"], name: "index_spree_state_changes_on_user_id", using: :btree

  create_table "spree_states", force: true do |t|
    t.string   "name"
    t.string   "abbr"
    t.integer  "country_id"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_states", ["company_id"], name: "index_spree_states_on_company_id", using: :btree
  add_index "spree_states", ["country_id"], name: "index_spree_states_on_country_id", using: :btree
  add_index "spree_states", ["instance_id"], name: "index_spree_states_on_instance_id", using: :btree
  add_index "spree_states", ["partner_id"], name: "index_spree_states_on_partner_id", using: :btree
  add_index "spree_states", ["user_id"], name: "index_spree_states_on_user_id", using: :btree

  create_table "spree_stock_items", force: true do |t|
    t.integer  "stock_location_id"
    t.integer  "variant_id"
    t.integer  "count_on_hand",     default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "backorderable",     default: false
    t.datetime "deleted_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_stock_items", ["backorderable"], name: "index_spree_stock_items_on_backorderable", using: :btree
  add_index "spree_stock_items", ["company_id"], name: "index_spree_stock_items_on_company_id", using: :btree
  add_index "spree_stock_items", ["deleted_at"], name: "index_spree_stock_items_on_deleted_at", using: :btree
  add_index "spree_stock_items", ["instance_id"], name: "index_spree_stock_items_on_instance_id", using: :btree
  add_index "spree_stock_items", ["partner_id"], name: "index_spree_stock_items_on_partner_id", using: :btree
  add_index "spree_stock_items", ["stock_location_id", "variant_id"], name: "stock_item_by_loc_and_var_id", using: :btree
  add_index "spree_stock_items", ["stock_location_id"], name: "index_spree_stock_items_on_stock_location_id", using: :btree
  add_index "spree_stock_items", ["user_id"], name: "index_spree_stock_items_on_user_id", using: :btree

  create_table "spree_stock_locations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.integer  "state_id"
    t.string   "state_name"
    t.integer  "country_id"
    t.string   "zipcode"
    t.string   "phone"
    t.boolean  "active",                 default: true
    t.boolean  "backorderable_default",  default: false
    t.boolean  "propagate_all_variants", default: true
    t.string   "admin_name"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_stock_locations", ["active"], name: "index_spree_stock_locations_on_active", using: :btree
  add_index "spree_stock_locations", ["backorderable_default"], name: "index_spree_stock_locations_on_backorderable_default", using: :btree
  add_index "spree_stock_locations", ["company_id"], name: "index_spree_stock_locations_on_company_id", using: :btree
  add_index "spree_stock_locations", ["country_id"], name: "index_spree_stock_locations_on_country_id", using: :btree
  add_index "spree_stock_locations", ["instance_id"], name: "index_spree_stock_locations_on_instance_id", using: :btree
  add_index "spree_stock_locations", ["partner_id"], name: "index_spree_stock_locations_on_partner_id", using: :btree
  add_index "spree_stock_locations", ["propagate_all_variants"], name: "index_spree_stock_locations_on_propagate_all_variants", using: :btree
  add_index "spree_stock_locations", ["state_id"], name: "index_spree_stock_locations_on_state_id", using: :btree
  add_index "spree_stock_locations", ["user_id"], name: "index_spree_stock_locations_on_user_id", using: :btree

  create_table "spree_stock_movements", force: true do |t|
    t.integer  "stock_item_id"
    t.integer  "quantity",        default: 0
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "originator_id"
    t.string   "originator_type"
  end

  add_index "spree_stock_movements", ["stock_item_id"], name: "index_spree_stock_movements_on_stock_item_id", using: :btree

  create_table "spree_stock_transfers", force: true do |t|
    t.string   "type"
    t.string   "reference"
    t.integer  "source_location_id"
    t.integer  "destination_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "number"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_stock_transfers", ["company_id"], name: "index_spree_stock_transfers_on_company_id", using: :btree
  add_index "spree_stock_transfers", ["destination_location_id"], name: "index_spree_stock_transfers_on_destination_location_id", using: :btree
  add_index "spree_stock_transfers", ["instance_id"], name: "index_spree_stock_transfers_on_instance_id", using: :btree
  add_index "spree_stock_transfers", ["number"], name: "index_spree_stock_transfers_on_number", using: :btree
  add_index "spree_stock_transfers", ["partner_id"], name: "index_spree_stock_transfers_on_partner_id", using: :btree
  add_index "spree_stock_transfers", ["source_location_id"], name: "index_spree_stock_transfers_on_source_location_id", using: :btree
  add_index "spree_stock_transfers", ["user_id"], name: "index_spree_stock_transfers_on_user_id", using: :btree

  create_table "spree_stores", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.text     "meta_description"
    t.text     "meta_keywords"
    t.string   "seo_title"
    t.string   "mail_from_address"
    t.string   "default_currency"
    t.string   "code"
    t.boolean  "default",           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
  end

  add_index "spree_stores", ["code"], name: "index_spree_stores_on_code", using: :btree
  add_index "spree_stores", ["default"], name: "index_spree_stores_on_default", using: :btree
  add_index "spree_stores", ["instance_id"], name: "index_spree_stores_on_instance_id", using: :btree
  add_index "spree_stores", ["url"], name: "index_spree_stores_on_url", using: :btree

  create_table "spree_tax_categories", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "is_default",  default: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_tax_categories", ["company_id"], name: "index_spree_tax_categories_on_company_id", using: :btree
  add_index "spree_tax_categories", ["deleted_at"], name: "index_spree_tax_categories_on_deleted_at", using: :btree
  add_index "spree_tax_categories", ["instance_id"], name: "index_spree_tax_categories_on_instance_id", using: :btree
  add_index "spree_tax_categories", ["is_default"], name: "index_spree_tax_categories_on_is_default", using: :btree
  add_index "spree_tax_categories", ["partner_id"], name: "index_spree_tax_categories_on_partner_id", using: :btree
  add_index "spree_tax_categories", ["user_id"], name: "index_spree_tax_categories_on_user_id", using: :btree

  create_table "spree_tax_rates", force: true do |t|
    t.decimal  "amount",             precision: 8, scale: 5
    t.integer  "zone_id"
    t.integer  "tax_category_id"
    t.boolean  "included_in_price",                          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "show_rate_in_label",                         default: true
    t.datetime "deleted_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_tax_rates", ["company_id"], name: "index_spree_tax_rates_on_company_id", using: :btree
  add_index "spree_tax_rates", ["deleted_at"], name: "index_spree_tax_rates_on_deleted_at", using: :btree
  add_index "spree_tax_rates", ["included_in_price"], name: "index_spree_tax_rates_on_included_in_price", using: :btree
  add_index "spree_tax_rates", ["instance_id"], name: "index_spree_tax_rates_on_instance_id", using: :btree
  add_index "spree_tax_rates", ["partner_id"], name: "index_spree_tax_rates_on_partner_id", using: :btree
  add_index "spree_tax_rates", ["show_rate_in_label"], name: "index_spree_tax_rates_on_show_rate_in_label", using: :btree
  add_index "spree_tax_rates", ["tax_category_id"], name: "index_spree_tax_rates_on_tax_category_id", using: :btree
  add_index "spree_tax_rates", ["user_id"], name: "index_spree_tax_rates_on_user_id", using: :btree
  add_index "spree_tax_rates", ["zone_id"], name: "index_spree_tax_rates_on_zone_id", using: :btree

  create_table "spree_taxonomies", force: true do |t|
    t.string   "name",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",    default: 0
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_taxonomies", ["company_id"], name: "index_spree_taxonomies_on_company_id", using: :btree
  add_index "spree_taxonomies", ["instance_id"], name: "index_spree_taxonomies_on_instance_id", using: :btree
  add_index "spree_taxonomies", ["partner_id"], name: "index_spree_taxonomies_on_partner_id", using: :btree
  add_index "spree_taxonomies", ["position"], name: "index_spree_taxonomies_on_position", using: :btree
  add_index "spree_taxonomies", ["user_id"], name: "index_spree_taxonomies_on_user_id", using: :btree

  create_table "spree_taxons", force: true do |t|
    t.integer  "parent_id"
    t.integer  "position",          default: 0
    t.string   "name",                              null: false
    t.string   "permalink"
    t.integer  "taxonomy_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "meta_title"
    t.string   "meta_description"
    t.string   "meta_keywords"
    t.integer  "depth"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.boolean  "in_top_nav",        default: false
    t.integer  "top_nav_position"
  end

  add_index "spree_taxons", ["company_id"], name: "index_spree_taxons_on_company_id", using: :btree
  add_index "spree_taxons", ["in_top_nav"], name: "index_spree_taxons_on_in_top_nav", using: :btree
  add_index "spree_taxons", ["instance_id"], name: "index_spree_taxons_on_instance_id", using: :btree
  add_index "spree_taxons", ["parent_id"], name: "index_taxons_on_parent_id", using: :btree
  add_index "spree_taxons", ["partner_id"], name: "index_spree_taxons_on_partner_id", using: :btree
  add_index "spree_taxons", ["permalink"], name: "index_taxons_on_permalink", using: :btree
  add_index "spree_taxons", ["position"], name: "index_spree_taxons_on_position", using: :btree
  add_index "spree_taxons", ["taxonomy_id"], name: "index_taxons_on_taxonomy_id", using: :btree
  add_index "spree_taxons", ["user_id"], name: "index_spree_taxons_on_user_id", using: :btree

  create_table "spree_tokenized_permissions", force: true do |t|
    t.integer  "permissable_id"
    t.string   "permissable_type"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_tokenized_permissions", ["permissable_id", "permissable_type"], name: "index_tokenized_name_and_type", using: :btree

  create_table "spree_trackers", force: true do |t|
    t.string   "environment"
    t.string   "analytics_id"
    t.boolean  "active",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_trackers", ["active"], name: "index_spree_trackers_on_active", using: :btree
  add_index "spree_trackers", ["company_id"], name: "index_spree_trackers_on_company_id", using: :btree
  add_index "spree_trackers", ["instance_id"], name: "index_spree_trackers_on_instance_id", using: :btree
  add_index "spree_trackers", ["partner_id"], name: "index_spree_trackers_on_partner_id", using: :btree
  add_index "spree_trackers", ["user_id"], name: "index_spree_trackers_on_user_id", using: :btree

  create_table "spree_users", force: true do |t|
    t.string   "encrypted_password",     limit: 128
    t.string   "password_salt",          limit: 128
    t.string   "email"
    t.string   "remember_token"
    t.string   "persistence_token"
    t.string   "reset_password_token"
    t.string   "perishable_token"
    t.integer  "sign_in_count",                      default: 0, null: false
    t.integer  "failed_attempts",                    default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "login"
    t.integer  "ship_address_id"
    t.integer  "bill_address_id"
    t.string   "authentication_token"
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_variants", force: true do |t|
    t.string   "sku",                                      default: "",         null: false
    t.decimal  "weight",          precision: 8,  scale: 2, default: 0.0
    t.decimal  "height",          precision: 8,  scale: 2
    t.decimal  "width",           precision: 8,  scale: 2
    t.decimal  "depth",           precision: 8,  scale: 2
    t.datetime "deleted_at"
    t.boolean  "is_master",                                default: false
    t.integer  "product_id"
    t.decimal  "cost_price",      precision: 10, scale: 2
    t.integer  "position"
    t.string   "cost_currency"
    t.boolean  "track_inventory",                          default: true
    t.integer  "tax_category_id"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.string   "weight_unit",                              default: "oz"
    t.string   "height_unit",                              default: "in"
    t.string   "width_unit",                               default: "in"
    t.string   "depth_unit",                               default: "in"
    t.text     "unit_of_measure",                          default: "imperial"
    t.decimal  "weight_user",     precision: 8,  scale: 2
    t.decimal  "height_user",     precision: 8,  scale: 2
    t.decimal  "width_user",      precision: 8,  scale: 2
    t.decimal  "depth_user",      precision: 8,  scale: 2
  end

  add_index "spree_variants", ["company_id"], name: "index_spree_variants_on_company_id", using: :btree
  add_index "spree_variants", ["deleted_at"], name: "index_spree_variants_on_deleted_at", using: :btree
  add_index "spree_variants", ["instance_id"], name: "index_spree_variants_on_instance_id", using: :btree
  add_index "spree_variants", ["is_master"], name: "index_spree_variants_on_is_master", using: :btree
  add_index "spree_variants", ["partner_id"], name: "index_spree_variants_on_partner_id", using: :btree
  add_index "spree_variants", ["position"], name: "index_spree_variants_on_position", using: :btree
  add_index "spree_variants", ["product_id"], name: "index_spree_variants_on_product_id", using: :btree
  add_index "spree_variants", ["sku"], name: "index_spree_variants_on_sku", using: :btree
  add_index "spree_variants", ["tax_category_id"], name: "index_spree_variants_on_tax_category_id", using: :btree
  add_index "spree_variants", ["track_inventory"], name: "index_spree_variants_on_track_inventory", using: :btree
  add_index "spree_variants", ["user_id"], name: "index_spree_variants_on_user_id", using: :btree

  create_table "spree_zone_members", force: true do |t|
    t.integer  "zoneable_id"
    t.string   "zoneable_type"
    t.integer  "zone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_zone_members", ["zone_id"], name: "index_spree_zone_members_on_zone_id", using: :btree
  add_index "spree_zone_members", ["zoneable_id", "zoneable_type"], name: "index_spree_zone_members_on_zoneable_id_and_zoneable_type", using: :btree

  create_table "spree_zones", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "default_tax",        default: false
    t.integer  "zone_members_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
    t.integer  "company_id"
    t.integer  "partner_id"
    t.integer  "user_id"
  end

  add_index "spree_zones", ["company_id"], name: "index_spree_zones_on_company_id", using: :btree
  add_index "spree_zones", ["default_tax"], name: "index_spree_zones_on_default_tax", using: :btree
  add_index "spree_zones", ["instance_id"], name: "index_spree_zones_on_instance_id", using: :btree
  add_index "spree_zones", ["partner_id"], name: "index_spree_zones_on_partner_id", using: :btree
  add_index "spree_zones", ["user_id"], name: "index_spree_zones_on_user_id", using: :btree

  create_table "support_faqs", force: true do |t|
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

  create_table "support_ticket_message_attachments", force: true do |t|
    t.text     "description"
    t.string   "tag"
    t.integer  "instance_id"
    t.integer  "uploader_id"
    t.integer  "receiver_id"
    t.integer  "ticket_message_id"
    t.integer  "ticket_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "file"
    t.string   "file_type"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "support_ticket_message_attachments", ["target_id", "target_type"], name: "stma_target_polymorphic", using: :btree

  create_table "support_ticket_messages", force: true do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.integer  "ticket_id"
    t.string   "full_name",   null: false
    t.string   "email",       null: false
    t.string   "subject",     null: false
    t.text     "message",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "support_ticket_messages", ["instance_id"], name: "index_support_ticket_messages_on_instance_id", using: :btree
  add_index "support_ticket_messages", ["ticket_id"], name: "index_support_ticket_messages_on_ticket_id", using: :btree
  add_index "support_ticket_messages", ["user_id"], name: "index_support_ticket_messages_on_user_id", using: :btree

  create_table "support_tickets", force: true do |t|
    t.integer  "instance_id"
    t.integer  "user_id"
    t.integer  "assigned_to_id"
    t.string   "state",               null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "target_id"
    t.string   "target_type"
    t.text     "reservation_details"
  end

  add_index "support_tickets", ["assigned_to_id"], name: "index_support_tickets_on_assigned_to_id", using: :btree
  add_index "support_tickets", ["instance_id"], name: "index_support_tickets_on_instance_id", using: :btree
  add_index "support_tickets", ["target_id", "target_type"], name: "index_support_tickets_on_target_id_and_target_type", using: :btree
  add_index "support_tickets", ["user_id"], name: "index_support_tickets_on_user_id", using: :btree

  create_table "text_filters", force: true do |t|
    t.string   "name"
    t.string   "regexp"
    t.string   "replacement_text"
    t.integer  "flags"
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "theme_fonts", force: true do |t|
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
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "theme_fonts", ["theme_id"], name: "index_theme_fonts_on_theme_id", using: :btree

  create_table "themes", force: true do |t|
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
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
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
    t.string   "compiled_dashboard_stylesheet"
  end

  add_index "themes", ["owner_id", "owner_type"], name: "index_themes_on_owner_id_and_owner_type", using: :btree

  create_table "transactable_type_actions", force: true do |t|
    t.integer  "action_type_id"
    t.integer  "transactable_type_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactable_types", force: true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.text     "pricing_options"
    t.text     "pricing_validation"
    t.text     "availability_options"
    t.boolean  "favourable_pricing_rate",                                            default: true
    t.integer  "days_for_monthly_rate",                                              default: 0
    t.datetime "cancellation_policy_enabled"
    t.integer  "cancellation_policy_hours_for_cancellation",                         default: 0
    t.integer  "cancellation_policy_penalty_percentage",                             default: 0
    t.boolean  "action_recurring_booking",                                           default: false, null: false
    t.boolean  "show_page_enabled",                                                  default: false
    t.text     "custom_csv_fields"
    t.boolean  "action_overnight_booking",                                           default: false, null: false
    t.text     "onboarding_form_fields"
    t.decimal  "service_fee_guest_percent",                  precision: 5, scale: 2, default: 0.0
    t.decimal  "service_fee_host_percent",                   precision: 5, scale: 2, default: 0.0
    t.string   "bookable_noun"
    t.string   "lessor"
    t.string   "lessee"
    t.boolean  "groupable_with_others",                                              default: true
    t.boolean  "enable_reviews"
    t.boolean  "action_rfq",                                                         default: false
    t.boolean  "action_hourly_booking",                                              default: false
    t.boolean  "action_free_booking",                                                default: false
    t.boolean  "action_daily_booking",                                               default: false
    t.boolean  "action_monthly_booking",                                             default: false
    t.boolean  "action_weekly_booking",                                              default: false
    t.boolean  "action_schedule_booking"
    t.integer  "min_daily_price_cents"
    t.integer  "max_daily_price_cents"
    t.integer  "min_weekly_price_cents"
    t.integer  "max_weekly_price_cents"
    t.integer  "min_monthly_price_cents"
    t.integer  "max_monthly_price_cents"
    t.integer  "min_hourly_price_cents"
    t.integer  "max_hourly_price_cents"
    t.integer  "min_fixed_price_cents"
    t.integer  "max_fixed_price_cents"
    t.boolean  "manual_payment",                                                     default: false
    t.boolean  "buyable",                                                            default: false
    t.boolean  "show_reviews_if_both_completed",                                     default: false
    t.boolean  "enable_photo_required",                                              default: true
    t.integer  "hours_to_expiration",                                                default: 24
    t.integer  "minimum_booking_minutes",                                            default: 60
    t.boolean  "action_na",                                                          default: false
    t.boolean  "action_book_it_out"
    t.boolean  "skip_location"
    t.string   "default_currency"
    t.text     "allowed_currencies"
    t.string   "default_country"
    t.text     "allowed_countries"
  end

  add_index "transactable_types", ["instance_id"], name: "index_transactable_types_on_instance_id", using: :btree

  create_table "transactables", force: true do |t|
    t.integer  "instance_type_id"
    t.integer  "instance_id"
    t.integer  "partner_id"
    t.integer  "creator_id"
    t.integer  "company_id"
    t.integer  "location_id"
    t.integer  "listing_type_id"
    t.integer  "administrator_id"
    t.hstore   "properties"
    t.datetime "deleted_at"
    t.datetime "draft"
    t.datetime "activated_at"
    t.boolean  "listings_public"
    t.boolean  "enabled"
    t.text     "metadata"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "transactable_type_id"
    t.integer  "parent_transactable_id"
    t.string   "external_id"
    t.boolean  "mark_to_be_bulk_update_deleted", default: false
    t.boolean  "action_rfq",                     default: false
    t.boolean  "action_hourly_booking",          default: false
    t.boolean  "action_free_booking",            default: false
    t.boolean  "action_recurring_booking",       default: false
    t.boolean  "action_daily_booking",           default: false
    t.integer  "hourly_price_cents",             default: 0
    t.integer  "daily_price_cents",              default: 0
    t.integer  "weekly_price_cents",             default: 0
    t.integer  "monthly_price_cents",            default: 0
    t.boolean  "action_schedule_booking"
    t.integer  "fixed_price_cents"
    t.integer  "min_fixed_price_cents"
    t.integer  "max_fixed_price_cents"
    t.float    "average_rating",                 default: 0.0,       null: false
    t.string   "booking_type",                   default: "regular"
    t.boolean  "manual_payment",                 default: false
    t.integer  "wish_list_items_count",          default: 0
    t.integer  "quantity",                       default: 1
    t.integer  "opened_on_days",                 default: [],                     array: true
    t.integer  "minimum_booking_minutes",        default: 60
    t.integer  "book_it_out_discount"
    t.integer  "book_it_out_minimum_qty"
  end

  add_index "transactables", ["external_id", "location_id"], name: "index_transactables_on_external_id_and_location_id", unique: true, using: :btree
  add_index "transactables", ["opened_on_days"], name: "index_transactables_on_opened_on_days", using: :gin
  add_index "transactables", ["parent_transactable_id"], name: "index_transactables_on_parent_transactable_id", using: :btree
  add_index "transactables", ["properties"], name: "transactables_gin_properties", using: :gin
  add_index "transactables", ["transactable_type_id"], name: "index_transactables_on_transactable_type_id", using: :btree

  create_table "translations", force: true do |t|
    t.string   "locale"
    t.string   "key"
    t.text     "value"
    t.text     "interpolations"
    t.boolean  "is_proc",        default: false
    t.integer  "instance_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "translations", ["instance_id", "updated_at"], name: "index_translations_on_instance_id_and_updated_at", using: :btree

  create_table "unit_prices", force: true do |t|
    t.integer  "transactable_id"
    t.integer  "price_cents"
    t.integer  "period"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "unit_prices", ["transactable_id"], name: "index_unit_prices_on_listing_id", using: :btree

  create_table "upload_obligations", force: true do |t|
    t.string   "level"
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "upload_obligations", ["deleted_at"], name: "index_upload_obligations_on_deleted_at", using: :btree
  add_index "upload_obligations", ["instance_id"], name: "index_upload_obligations_on_instance_id", using: :btree
  add_index "upload_obligations", ["item_id", "item_type"], name: "index_upload_obligations_on_item_id_and_item_type", using: :btree

  create_table "user_bans", force: true do |t|
    t.integer  "user_id"
    t.integer  "instance_id"
    t.integer  "creator_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_blog_posts", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "slug"
    t.string   "hero_image"
    t.text     "content"
    t.text     "excerpt"
    t.datetime "published_at"
    t.string   "author_name"
    t.text     "author_biography"
    t.string   "author_avatar_img"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "highlighted",       default: false
    t.integer  "instance_id"
  end

  create_table "user_blogs", force: true do |t|
    t.integer  "user_id"
    t.boolean  "enabled",     default: false
    t.string   "name"
    t.string   "header_logo"
    t.string   "header_icon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
  end

  create_table "user_industries", force: true do |t|
    t.integer  "industry_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
  end

  add_index "user_industries", ["industry_id", "user_id"], name: "index_user_industries_on_industry_id_and_user_id", using: :btree

  create_table "user_instance_profiles", force: true do |t|
    t.integer  "user_id"
    t.integer  "instance_id"
    t.integer  "instance_profile_type_id"
    t.text     "metadata"
    t.hstore   "properties"
    t.datetime "deleted_at"
    t.integer  "reservations_count",       default: 0
    t.integer  "transactables_count",      default: 0
  end

  create_table "user_messages", force: true do |t|
    t.integer  "thread_owner_id"
    t.integer  "author_id",                              null: false
    t.integer  "thread_recipient_id"
    t.integer  "thread_context_id"
    t.string   "thread_context_type"
    t.text     "body"
    t.boolean  "archived_for_owner",     default: false
    t.boolean  "archived_for_recipient", default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "read_for_owner",         default: false
    t.boolean  "read_for_recipient",     default: false
    t.datetime "deleted_at"
    t.integer  "instance_id"
  end

  add_index "user_messages", ["instance_id"], name: "index_user_messages_on_instance_id", using: :btree

  create_table "user_relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "deleted_at"
    t.integer  "authentication_id"
  end

  add_index "user_relationships", ["authentication_id"], name: "index_user_relationships_on_authentication_id", using: :btree
  add_index "user_relationships", ["followed_id"], name: "index_user_relationships_on_followed_id", using: :btree
  add_index "user_relationships", ["follower_id", "followed_id", "deleted_at"], name: "index_user_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "user_relationships", ["follower_id"], name: "index_user_relationships_on_follower_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                                              default: "",                                                                                  null: false
    t.string   "encrypted_password",                     limit: 128, default: "",                                                                                  null: false
    t.string   "password_salt",                                      default: "",                                                                                  null: false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "admin"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "deleted_at"
    t.datetime "locked_at"
    t.datetime "reset_password_sent_at"
    t.integer  "failed_attempts",                                    default: 0
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
    t.string   "time_zone",                                          default: "Pacific Time (US & Canada)"
    t.boolean  "sms_notifications_enabled",                          default: true
    t.string   "sms_preferences",                                    default: "---\nuser_message: true\nreservation_state_changed: true\nnew_reservation: true\n"
    t.text     "instance_unread_messages_threads_count",             default: "--- {}\n"
    t.text     "metadata"
    t.string   "payment_token"
    t.boolean  "sso_log_out",                                        default: false
    t.string   "spree_api_key"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "drivers_licence_number"
    t.string   "gov_number"
    t.string   "twitter_url"
    t.string   "linkedin_url"
    t.string   "facebook_url"
    t.string   "google_plus_url"
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
    t.string   "language",                               limit: 2,   default: "en"
    t.string   "saved_searches_alerts_frequency",                    default: "daily"
    t.integer  "saved_searches_count",                               default: 0
    t.datetime "saved_searches_alert_sent_at"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["domain_id"], name: "index_users_on_domain_id", using: :btree
  add_index "users", ["instance_id", "email"], name: "index_users_on_slug", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "users", ["instance_id", "reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["instance_id", "slug"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["instance_id"], name: "index_users_on_instance_id", using: :btree
  add_index "users", ["instance_profile_type_id"], name: "index_users_on_instance_profile_type_id", using: :btree
  add_index "users", ["partner_id"], name: "index_users_on_partner_id", using: :btree
  add_index "users", ["saved_searches_alerts_frequency", "saved_searches_count", "saved_searches_alert_sent_at"], name: "index_users_on_saved_search_attrs", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "waiver_agreement_templates", force: true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "waiver_agreement_templates", ["target_id", "target_type"], name: "index_waiver_agreement_templates_on_target_id_and_target_type", using: :btree

  create_table "waiver_agreements", force: true do |t|
    t.string   "vendor_name"
    t.string   "guest_name"
    t.string   "name"
    t.text     "content"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "waiver_agreement_template_id"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "waiver_agreements", ["target_id", "target_type"], name: "index_waiver_agreements_on_target_id_and_target_type", using: :btree
  add_index "waiver_agreements", ["waiver_agreement_template_id"], name: "index_waiver_agreements_on_waiver_agreement_template_id", using: :btree

  create_table "wish_list_items", force: true do |t|
    t.integer  "instance_id"
    t.integer  "wish_list_id"
    t.integer  "wishlistable_id"
    t.string   "wishlistable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wish_list_items", ["instance_id", "wish_list_id"], name: "index_wish_list_items_on_instance_id_and_wish_list_id", using: :btree
  add_index "wish_list_items", ["wishlistable_id", "wishlistable_type"], name: "index_wish_list_items_on_wishlistable_id_and_wishlistable_type", using: :btree

  create_table "wish_lists", force: true do |t|
    t.integer  "user_id"
    t.integer  "instance_id"
    t.string   "name"
    t.boolean  "default",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wish_lists", ["instance_id", "user_id"], name: "index_wish_lists_on_instance_id_and_user_id", using: :btree

  create_table "workflow_alert_logs", force: true do |t|
    t.integer  "instance_id"
    t.integer  "workflow_alert_id"
    t.integer  "workflow_alert_weekly_aggregated_log_id"
    t.integer  "workflow_alert_monthly_aggregated_log_id"
    t.string   "alert_type"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_alert_logs", ["instance_id", "alert_type"], name: "index_workflow_alert_logs_on_instance_id_and_alert_type", using: :btree

  create_table "workflow_alert_monthly_aggregated_logs", force: true do |t|
    t.integer  "instance_id"
    t.integer  "workflow_alert_id"
    t.integer  "year"
    t.integer  "month"
    t.integer  "email_count",       default: 0, null: false
    t.integer  "integer",           default: 0, null: false
    t.integer  "sms_count",         default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_alert_monthly_aggregated_logs", ["instance_id", "year", "month"], name: "wamal_instance_id_year_month_index", unique: true, using: :btree

  create_table "workflow_alert_weekly_aggregated_logs", force: true do |t|
    t.integer  "instance_id"
    t.integer  "year"
    t.integer  "week_number"
    t.integer  "email_count", default: 0, null: false
    t.integer  "integer",     default: 0, null: false
    t.integer  "sms_count",   default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_alert_weekly_aggregated_logs", ["instance_id", "year", "week_number"], name: "wamal_instance_id_year_week_number_index", unique: true, using: :btree

  create_table "workflow_alerts", force: true do |t|
    t.string   "name"
    t.string   "alert_type"
    t.string   "recipient_type"
    t.string   "template_path"
    t.integer  "workflow_step_id"
    t.integer  "instance_id"
    t.text     "options"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delay",            default: 0
    t.text     "subject"
    t.string   "layout_path"
    t.text     "custom_options"
    t.string   "from"
    t.string   "reply_to"
    t.string   "cc"
    t.string   "bcc"
    t.string   "recipient"
    t.string   "from_type"
    t.string   "reply_to_type"
  end

  create_table "workflow_steps", force: true do |t|
    t.string   "name"
    t.string   "associated_class"
    t.integer  "instance_id"
    t.integer  "workflow_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflows", force: true do |t|
    t.string   "name"
    t.integer  "instance_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "events_metadata"
    t.string   "workflow_type"
  end

end
