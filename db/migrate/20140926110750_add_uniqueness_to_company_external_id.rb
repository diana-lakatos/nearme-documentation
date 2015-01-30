class AddUniquenessToCompanyExternalId < ActiveRecord::Migration
  def up
    add_column :locations, :external_id, :string

    connection.execute <<-SQL
      CREATE UNIQUE INDEX companies_external_id_uni_idx
      ON companies (external_id, instance_id)
      WHERE external_id IS NOT NULL AND deleted_at IS NULL;

      UPDATE transactables
      SET external_id = id
      WHERE external_id IS NULL;

      UPDATE locations
      SET external_id = id
      WHERE external_id IS NULL;

      DROP INDEX index_companies_on_instance_id_and_external_id ;
    SQL

    add_index :transactables, [:external_id, :location_id], unique: true
    add_index :locations, [:external_id, :company_id], unique: true
    add_index :addresses, [:entity_id, :entity_type, :address], unique: true

    remove_index :addresses, [:entity_id, :entity_type]
    remove_index :transactables, :external_id
  end

  def down
    connection.execute <<-SQL
      DROP INDEX companies_external_id_uni_idx;
      CREATE UNIQUE INDEX index_companies_on_instance_id_and_external_id
      ON companies (instance_id, external_id)
    SQL
    remove_column :locations, :external_id
    remove_index :transactables, [:external_id, :location_id]
    remove_index :addresses, [:entity_id, :entity_type, :address]
    add_index :transactables, :external_id
    add_index :addresses, [:entity_id, :entity_type]
  end
end

