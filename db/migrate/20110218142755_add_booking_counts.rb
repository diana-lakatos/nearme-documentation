class AddBookingCounts < ActiveRecord::Migration
  def self.up
    add_column :users,      :bookings_count, :integer, :default => 0, :null => false
    add_column :workplaces, :bookings_count, :integer, :default => 0, :null => false

    # [User, Workplace].each do |klass|
    #       klass.find_each do |instance|
    #         klass.reset_counters instance.id, :bookings
    #       end
    #     end
  end

  def self.down
    remove_column :workplaces, :bookings_count
    remove_column :users,      :bookings_count
  end
end
