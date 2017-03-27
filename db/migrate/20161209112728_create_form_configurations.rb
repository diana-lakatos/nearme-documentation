# frozen_string_literal: true
class CreateFormConfigurations < ActiveRecord::Migration
  def change
    create_table :form_configurations do |t|
      t.integer :instance_id, null: false, index: true
      t.string :base_form, null: false
      t.string :name, null: false
      t.text :liquid_body
      t.text :configuration, null: false, default: {}
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
