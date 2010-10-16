class AddFieldsToBookings < ActiveRecord::Migration
  def self.up
    add_column :bookings, :workplace_id, :integer
    add_column :bookings, :comment, :text
    add_column :bookings, :state, :string
    add_column :bookings, :user_id, :integer
    add_column :bookings, :date, :date
  end

  def self.down
    remove_column :bookings, :date
    remove_column :bookings, :user_id
    remove_column :bookings, :state
    remove_column :bookings, :comment
    remove_column :bookings, :workplace_id
  end
end
