class AddRatingEmailTimestampsToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :request_guest_rating_email_sent_at, :datetime
    add_column :reservations, :request_host_rating_email_sent_at, :datetime
  end
end
