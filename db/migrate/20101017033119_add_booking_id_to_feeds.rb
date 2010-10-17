class AddBookingIdToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :booking_id, :integer
  end

  def self.down
  end
end
