class FixReservationsForAllowReview < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      Reservation.with_listing.past.confirmed.update_all("archived_at = COALESCE(confirmed_at, updated_at)")
      Spree::Order.completed.approved.paid.shipped.update_all("archived_at = COALESCE(completed_at, updated_at)")
    end
  end
end
