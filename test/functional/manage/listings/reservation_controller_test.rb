require 'test_helper'

class Manage::Listings::ReservationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @reservation = FactoryGirl.build(:reservation_with_credit_card)
    @reservation.periods = []
    @reservation.add_period(Time.now.next_week.to_date)
    @reservation.total_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
    @reservation.save!
  end

  test "a host is redirected to bookings if valid event" do
    sign_in @reservation.listing.creator
    put :update, {:listing_id => @reservation.listing.id, :event => "Reject", :id => @reservation.id}
    assert_redirected_to manage_guests_dashboard_path
  end

end
