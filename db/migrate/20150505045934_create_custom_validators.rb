class CreateCustomValidators < ActiveRecord::Migration
  def change
    create_table :custom_validators do |t|
      t.integer :instance_id
      t.string :validatable_type
      t.integer :validatable_id
      t.string :field_name
      t.text :validation_rules
      t.text :valid_values
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :custom_validators, [:instance_id, :validatable_type, :validatable_id], name: 'index_custom_validators_on_i_id_and_v_type_and_v_id'
  end
end
