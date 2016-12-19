# frozen_string_literal: true
class CreateCustomImages < ActiveRecord::Migration
  def change
    create_table :custom_images do |t|
      t.integer :instance_id, null: false
      t.integer :custom_attribute_id, null: false
      t.integer :owner_id
      t.string :owner_type
      t.integer :uploader_id
      t.string :image
      t.integer :crop_x
      t.integer :crop_y
      t.integer :crop_h
      t.integer :crop_w
      t.integer :rotation_angle
      t.text :image_transformation_data
      t.integer :width
      t.integer :height
      t.datetime :image_versions_generated_at
      t.datetime :deleted_at
      t.timestamps null: false
      t.index [:instance_id, :custom_attribute_id]
      t.index [:owner_id, :owner_type]
    end
  end
end
