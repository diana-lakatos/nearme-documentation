# frozen_string_literal: true
class CreateTransactableDimensionsTemplates < ActiveRecord::Migration
  def change
    create_table :transactable_dimensions_templates do |t|
      t.integer :transactable_id, null: false
      t.integer :dimensions_template_id, null: false
    end
  end
end
