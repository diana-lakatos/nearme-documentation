require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  test "it exists" do
    assert Reservation
  end

  test "it has a listing" do
    @reservation = Reservation.new
    @reservation.listing = Listing.new

    assert @reservation.listing
  end

  test "it has an owner" do
    @reservation = Reservation.new
    @reservation.owner = User.new

    assert @reservation.owner
  end

  test "it has periods" do
    @reservation = Reservation.new

    assert @reservation.periods
  end
end
