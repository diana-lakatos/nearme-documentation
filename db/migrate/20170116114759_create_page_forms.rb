# frozen_string_literal: true
class CreatePageForms < ActiveRecord::Migration
  def change
    create_table :page_forms do |t|
      t.integer :instance_id
      t.integer :page_id
      t.integer :form_configuration_id
      t.timestamps null: false
      t.index [:instance_id, :page_id, :form_configuration_id], name: 'index_page_forms_on_instance_id_and_fks', unique: true
    end
  end
end
