class CreateCustomAttributes < ActiveRecord::Migration
  def change
    create_table :custom_attributes do |t|
      t.string  :name
      t.integer :instance_id
      t.string  :attribute_type
      t.string  :html_tag
      t.string  :prompt
      t.string  :default_value
      t.boolean :public, default: true
      t.text    :validation_rules
      t.text    :valid_values
      t.datetime :deleted_at
      t.string  :label
      t.text    :input_html_options
      t.text    :wrapper_html_options
      t.text    :hint
      t.string  :placeholder
      t.boolean :internal, default: false
      t.integer :target_id
      t.string  :target_type
      t.boolean :searchable
      t.timestamps
    end
    add_index :custom_attributes, :instance_id
    add_index :custom_attributes, [:target_id, :target_type]
  end
end
