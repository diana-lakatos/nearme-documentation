class AddSearchableToInstanceProfileTypes < ActiveRecord::Migration
  def change
    add_column :instance_profile_types, :searchable, :boolean

    add_index :instance_profile_types, [:instance_id, :searchable]
  end
end
