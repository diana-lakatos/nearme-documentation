# frozen_string_literal: true
class CreateFormConfigurationsWorkflows < ActiveRecord::Migration
  def change
    create_table :form_configurations_workflows do |t|
      t.integer :instance_id
      t.belongs_to :form_configuration
      t.belongs_to :workflow_step
      t.timestamps
    end
  end
end
