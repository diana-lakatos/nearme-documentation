class AddAllowReviewToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :archived_at, :datetime, index: true
    add_column :spree_orders, :archived_at, :datetime, index: true
    add_column :bids, :archived_at, :datetime, index: true
  end
end
