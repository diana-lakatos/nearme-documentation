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

  context "with serialization" do
    should "work even if the total amount is nil" do
      reservation = Reservation.new
      reservation.total_amount_cents = nil

      expected = { :reservation =>
        {
          :id         => nil,
          :user_id    => nil,
          :listing_id => nil,
          :state      => "pending",
          :cancelable => true,
          :total_cost => { :amount=>0.0, :label=>"$0.00", :currency_code=>"USD" },
          :times      => []
        }
      }

      assert_equal expected, ReservationSerializer.new(reservation).as_json
    end
  end

  context "with reservation pricing" do
    context "and a listing with some availability" do
      setup do
        @listing = FactoryGirl.create(:listing, quantity: 10)
        @user    = FactoryGirl.create(:user)
      end

      should "set total cost after creating a new reservation" do
        dates              = [Date.today, Date.tomorrow, Date.today + 5, Date.today + 6].map { |d|
          d += 1 if d.wday == 6
          d += 1 if d.wday == 0
          d
        }
        quantity           =  5
        assert reservation = @listing.reserve!("test@test.com", @user, dates, quantity)

        # listing cost * 4 days * 5 people :)
        assert_equal @listing.price_cents * dates.size * quantity, reservation.total_amount_cents
      end

      should "not reset total cost when saving an existing reservation" do
        dates              = [1.week.from_now.monday]
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
