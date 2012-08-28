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

  context "with reservation pricing" do
    context "and a listing with some availability" do
      setup do
        @listing = FactoryGirl.create(:listing, price_cents: 50 * 100, quantity: 10)
        @user    = FactoryGirl.create(:user)
      end

      should "set total cost after creating a new reservation" do
        dates              = [Date.today, Date.tomorrow, Date.today + 5, Date.today + 6]
        quantity           =  5
        assert reservation = @listing.reserve!("test@test.com", @user, dates, quantity)

        # listing cost * 4 days * 5 people :)
        assert_equal @listing.price_cents * dates.size * quantity, reservation.total_amount_cents
      end

      should "not reset total cost when saving an existing reservation" do
        dates              = [Date.today]
        quantity           =  2
        assert reservation = @listing.reserve!("test@test.com", @user, dates, quantity)

        assert_not_nil reservation.total_amount_cents

        assert_no_difference "reservation.total_amount_cents" do
          reservation.confirmation_email = "joe@cuppa.com"
          reservation.save
        end

      end

      should "raise an exception if we try to reserve more desks than are available" do
        dates    = [Date.today]
        quantity = 11

        assert quantity > @listing.availability_for(dates.first)

        assert_raises DNM::PropertyUnavailableOnDate do
          @listing.reserve!("test@test.com", @user, dates, quantity)
        end
      end

    end
  end
end
