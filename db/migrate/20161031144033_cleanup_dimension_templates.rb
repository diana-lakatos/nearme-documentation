# frozen_string_literal: true
# TODO: before removing migrate data to new format
class CleanupDimensionTemplates < ActiveRecord::Migration
  def change
    # remove_column :dimensions_templates, :creator_id, :integer
    # remove_column :dimensions_templates, :unit_of_measure, :string
    # remove_column :dimensions_templates, :weight_unit, :string
    # remove_column :dimensions_templates, :height_unit, :string
    # remove_column :dimensions_templates, :width_unit, :string
    # remove_column :dimensions_templates, :depth_unit, :string
    # remove_column :dimensions_templates, :created_at, :datetime
    # remove_column :dimensions_templates, :updated_at, :datetime
    # remove_column :dimensions_templates, :details, :text
    # remove_column :dimensions_templates, :use_as_default, :boolean
    # remove_column :dimensions_templates, :shippo_id, :string

    add_column :dimensions_templates, :description, :string
    add_column :dimensions_templates, :shipping_provider_id, :integer
  end
end
