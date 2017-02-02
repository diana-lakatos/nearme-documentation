class CreateActivityFeedImages < ActiveRecord::Migration
  def change
    create_table :activity_feed_images do |t|
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
      t.timestamps null: false
    end
  end
end
