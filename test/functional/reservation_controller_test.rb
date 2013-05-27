require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase

include Devise::TestHelpers

  setup do
    @reservation = FactoryGirl.build(:reservation_with_credit_card_and_valid_period)
    @reservation.total_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
    @reservation.save!
  end

  test "a guest is redirected to bookings if valid event" do
    sign_in @reservation.owner
    put :update, {:listing_id => @reservation.listing.id, :event => "user_cancel", :id => @reservation.id}
    assert_redirected_to bookings_dashboard_path
  end

end
