class RemoveOrganizationsFromSystem < ActiveRecord::Migration
  def up
    drop_table :organization_users
    drop_table :location_organizations
    drop_table :organizations


    connection.execute <<-SQL
      UPDATE listings
      SET
        confirm_reservations = true
      FROM listings as l, locations as lo

      WHERE l.location_id = lo.id
      AND lo.require_organization_membership = true
    SQL

    remove_column :locations, :require_organization_membership
  end

  def down
    add_column :locations, :require_organization_membership, :boolean, :default => false

    create_table :location_organizations do |t|
      t.integer :location_id
      t.integer :organization_id
      t.timestamps
    end

    create_table :organization_users do |t|
      t.integer :organization_id
      t.integer :user_id
      t.timestamps
    end

    create_table :organizations do |t|
      t.string :name
      t.string :logo
      t.timestamps
    end
  end
end
