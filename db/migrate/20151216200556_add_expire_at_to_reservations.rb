class AddExpireAtToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :expire_at, :datetime
  end
end
