class AddInstanceIdToReservationPeriods < ActiveRecord::Migration
  def up
    add_column :reservation_periods, :instance_id, :integer, index: true
    add_column :company_users, :instance_id, :integer, index: true
    add_column :company_industries, :instance_id, :integer, index: true
    add_column :availability_rules, :instance_id, :integer, index: true


    connection.execute <<-SQL
      UPDATE reservation_periods
      SET
        instance_id = r.instance_id
      FROM reservations AS r
      WHERE reservation_periods.reservation_id = r.id
    SQL

    connection.execute <<-SQL
      UPDATE company_users
      SET
        instance_id = c.instance_id
      FROM companies AS c
      WHERE company_users.company_id = c.id
    SQL

    connection.execute <<-SQL
      UPDATE company_industries
      SET
        instance_id = c.instance_id
      FROM companies AS c
      WHERE company_industries.company_id = c.id
    SQL

    puts "Processing availability rules..."
    AvailabilityRule.unscoped.where(target_type: 'Listing').delete_all
    AvailabilityRule.unscoped.where(instance_id: nil).find_each do |ar|
      if ar.target.nil?
        ar.destroy unless ar.deleted_at.present?
        next
      end
      puts "Unknown instance_id for #{ar.target.class} #{ar.target.try(:id)}" if ar.target.try(:instance_id).nil?
      ar.update_column(:instance_id, ar.target.try(:instance_id))
    end
  end

  def down
    remove_column :reservation_periods, :instance_id
    remove_column :company_users, :instance_id
    remove_column :company_industries, :instance_id
    remove_column :availability_rules, :instance_id
  end
end
