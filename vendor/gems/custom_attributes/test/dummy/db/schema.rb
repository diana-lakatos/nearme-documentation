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

ActiveRecord::Schema.define(version: 20141003121911) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "custom_attributes", force: true do |t|
    t.string   "name"
    t.integer  "instance_id"
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
    t.integer  "target_id"
    t.string   "target_type"
    t.boolean  "searchable"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_attributes", ["instance_id"], name: "index_custom_attributes_on_instance_id", using: :btree
  add_index "custom_attributes", ["target_id", "target_type"], name: "index_custom_attributes_on_target_id_and_target_type", using: :btree

  create_table "sample_model_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_models", force: true do |t|
    t.integer  "sample_model_type_id"
    t.hstore   "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
