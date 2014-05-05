class CreateTransactableTypes < ActiveRecord::Migration
  def up

    create_table :transactable_types do |t|
      t.string :name
      t.integer :instance_id
      t.datetime :deleted_at
    end
    add_index :transactable_types, :instance_id

    create_table :transactable_type_attributes do |t|
      t.string :name
      t.integer :instance_id
      t.integer :transactable_type_id
      t.string :attribute_type
      t.string :html_tag
      t.string :prompt
      t.string :default_value
      t.boolean :public, :default => true
      t.text :validation_rules
      t.text :valid_values
      t.datetime :deleted_at
    end
    add_index :transactable_type_attributes, [:instance_id, :transactable_type_id], :name => 'index_tta_on_instance_id_and_transactable_type_id'

    add_column :transactables, :transactable_type_id, :integer
    add_column :transactables, :parent_transactable_id, :integer
    add_index :transactables, :transactable_type_id
    add_index :transactables, :parent_transactable_id

    remove_column :instances, :transactable_properties_types
    remove_column :instances, :transactable_properties_defaults
    remove_column :instances, :transactable_properties_validation_rules
  end

  def down
    drop_table :transactable_types
    drop_table :transactable_type_attributes
    remove_column :transactables, :transactable_type_id
    remove_column :transactables, :parent_transactable_id
    add_column :instances, :transactable_properties_types, :text
    add_column :instances, :transactable_properties_defaults, :text
    add_column :instances, :transactable_properties_validation_rules, :text
  end
end
