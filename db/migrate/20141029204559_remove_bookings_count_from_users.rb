class RemoveBookingsCountFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :bookings_count, :integer, default: 0, null: false
  end
end
