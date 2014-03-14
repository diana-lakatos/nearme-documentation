class AddInstanceIdAndCompanyIdToModels < ActiveRecord::Migration
  def change
    add_column :locations, :partner_id, :integer
    add_column :listings, :company_id, :integer
    add_column :listings, :partner_id, :integer
    add_column :listings, :listings_public, :boolean, :default => true
    add_column :reservations, :company_id, :integer
    add_column :reservations, :partner_id, :integer
    add_column :reservations, :listings_public, :boolean, :default => true
    add_column :payment_transfers, :instance_id, :integer
    add_column :payment_transfers, :partner_id, :integer
    add_column :reservation_charges, :instance_id, :integer
    add_column :reservation_charges, :company_id, :integer
    add_column :reservation_charges, :partner_id, :integer
    add_column :impressions, :company_id, :integer
    add_column :impressions, :partner_id, :integer
    add_column :impressions, :instance_id, :integer
    add_index :locations, :partner_id
    add_index :listings, :company_id
    add_index :listings, :partner_id
    add_index :reservations, :company_id
    add_index :reservations, :partner_id
    add_index :payment_transfers, :instance_id
    add_index :payment_transfers, :partner_id
    add_index :reservation_charges, :instance_id
    add_index :reservation_charges, :company_id
    add_index :reservation_charges, :partner_id
    add_index :impressions, :instance_id
    add_index :impressions, :company_id
    add_index :impressions, :partner_id


    connection.execute <<-SQL
      UPDATE locations AS l
      SET partner_id = c.partner_id, listings_public = c.listings_public
      FROM companies AS c
      WHERE l.company_id = c.id 
    SQL

    connection.execute <<-SQL
      UPDATE listings AS listing
      SET 
        partner_id = loc.partner_id, 
        company_id = loc.company_id,
        listings_public = loc.listings_public
      FROM locations AS loc
      WHERE listing.location_id = loc.id 
    SQL

    connection.execute <<-SQL
      UPDATE reservations AS r
      SET 
        partner_id = l.partner_id, 
        company_id = l.company_id,
        listings_public = l.listings_public
      FROM listings AS l
      WHERE r.listing_id = l.id 
    SQL

    connection.execute <<-SQL
      UPDATE payment_transfers AS pt
      SET 
        partner_id = c.partner_id, 
        instance_id = c.instance_id
      FROM companies AS c
      WHERE pt.company_id = c.id 
    SQL

    connection.execute <<-SQL
      UPDATE reservation_charges AS rc
      SET 
        partner_id = r.partner_id, 
        instance_id = r.instance_id,
        company_id = r.company_id
      FROM reservations AS r
      WHERE rc.reservation_id = r.id 
    SQL

    connection.execute <<-SQL
      UPDATE impressions AS i
      SET 
        partner_id = l.partner_id, 
        instance_id = l.instance_id,
        company_id = l.company_id
      FROM locations AS l
      WHERE i.impressionable_id = l.id AND i.impressionable_type = 'Location'
    SQL

    connection.execute <<-SQL
      UPDATE impressions AS i
      SET 
        partner_id = l.partner_id, 
        instance_id = l.instance_id,
        company_id = l.company_id
      FROM listings AS l
      WHERE i.impressionable_id = l.id AND i.impressionable_type = 'Listing'
    SQL

  end
end
