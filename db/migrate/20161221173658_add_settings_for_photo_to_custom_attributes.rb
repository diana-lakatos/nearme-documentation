# frozen_string_literal: true
class AddSettingsForPhotoToCustomAttributes < ActiveRecord::Migration
  def change
    add_column :custom_attributes, :placeholder_image, :string
    add_column :custom_attributes, :type, :string
    add_column :custom_attributes, :settings, :text, null: false, default: '{}'
  end
end
