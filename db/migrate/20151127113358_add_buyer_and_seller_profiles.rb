class AddBuyerAndSellerProfiles < ActiveRecord::Migration
  def up
    create_table :user_profiles do |t|
      t.hstore :properties
      t.integer :user_id
      t.integer :instance_profile_type_id, index: true
      t.integer :instance_id
      t.string :profile_type
      t.datetime :deleted_at
      t.timestamps
      t.index [:instance_id, :user_id, :profile_type], unique: true
    end

    add_column :instance_profile_types, :profile_type, :string, index: true
    execute <<-SQL
      UPDATE instance_profile_types
      SET profile_type = 'default'
      WHERE profile_type IS NULL;
    SQL
    execute <<-SQL
      DELETE FROM instance_profile_types
      WHERE id IN (
        SELECT id
        FROM (
          SELECT id, ROW_NUMBER() OVER (partition BY instance_id ORDER BY id) AS rnum
          FROM instance_profile_types WHERE instance_profile_types.profile_type = 'default') t
          WHERE t.rnum > 1
      );
    SQL
    add_index :instance_profile_types, [:instance_id, :profile_type], unique: true
  end

  def down
    drop_table :user_profiles
    remove_column :instance_profile_types, :profile_type
  end
end

