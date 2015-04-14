class CreateSavedSearches < ActiveRecord::Migration
  create_table :saved_searches, force: true do |t|
    t.string   :title
    t.integer  :user_id
    t.text     :query
    t.datetime :created_at
    t.datetime :updated_at
  end
end
