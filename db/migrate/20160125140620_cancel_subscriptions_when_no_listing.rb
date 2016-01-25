class CancelSubscriptionsWhenNoListing < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!
      RecurringBooking.with_state(:unconfirmed, :confirmed, :overdued).select{|r| r.listing.nil? || r.listing.deleted?}.each do |booking|
        booking.host_cancel!
      end
    end
  end
end
