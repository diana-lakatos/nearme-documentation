class CreateUserInstanceProfiles < ActiveRecord::Migration

  def up
    create_table :user_instance_profiles do |t|
      t.integer :user_id, index: true
      t.integer :instance_id, index: true
      t.integer :instance_profile_type_id, index: true
      t.text :metadata
      t.hstore :properties
      t.datetime :deleted_at
    end

    create_table :instance_profile_types do |t|
      t.string :name
      t.integer :instance_id, index: true
      t.datetime :deleted_at
    end

    rename_table :transactable_type_attributes, :custom_attributes

    add_column :custom_attributes, :target_id, :integer
    add_column :custom_attributes, :target_type, :string

    connection.execute <<-SQL
      UPDATE custom_attributes
      SET
        target_id = transactable_type_id,
        target_type = 'TransactableType'
      WHERE transactable_type_id IS NOT NULL
    SQL
    add_index :custom_attributes, [:target_id, :target_type]
  end

  def down
    drop_table :user_instance_profiles
    drop_table :instance_profile_types
    remove_column :custom_attributes, :target_id
    remove_column :custom_attributes, :target_type
    rename_table :custom_attributes, :transactable_type_attributes
  end
end
