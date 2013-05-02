require 'test_helper'
require 'reservations_helper'

class ReservationTest < ActiveSupport::TestCase
  include ReservationsHelper

  setup do
    stub_request(:get, /.*api\.mixpanel\.com.*/)
  end

  test "it has a listing" do
    @reservation = Reservation.new
    @reservation.listing = FactoryGirl.create(:listing)

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

  context 'booking events' do

    setup do
      @reservation = FactoryGirl.create(:reservation)
    end

    should 'track booking confirmation' do
      Track::Book.expects(:confirmed_a_booking)
      assert @reservation.confirm!
    end

    should 'track booking rejection' do
      Track::Book.expects(:rejected_a_booking)
      assert @reservation.reject!
    end

    should 'track host booking cancellation' do
      Track::Book.expects(:cancelled_a_booking)
      assert @reservation.user_cancel!
    end

    should 'track guest booking cancellation' do
      Track::Book.expects(:cancelled_a_booking)
      @reservation.confirm!
      assert @reservation.owner_cancel!
    end

    should 'track booking expiry' do
      Track::Book.expects(:booking_expired)
      assert @reservation.expire!
    end

  end

  describe 'expiration' do

    context 'with an unsaved reservation' do

      setup do
        @reservation = FactoryGirl.build(:reservation_with_credit_card)
        @reservation.add_period(Date.today)
        @reservation.total_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
        Timecop.freeze
      end

      teardown do
        Timecop.return
      end

      should 'create a delayed_job task to run in 24 hours time when saved' do
        lambda {
          @reservation.save!
        }.should change(Delayed::Job, :count).by(1)

        assert Delayed::Job.first.run_at == 24.hours.from_now
      end

    end

    context 'with a confirmed reservation' do

      setup do
        @reservation = FactoryGirl.build(:reservation_with_credit_card)
        @reservation.add_period(Date.today)
        @reservation.total_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
        @reservation.save!
        @reservation.confirm
      end

      should 'not send any email if the expire method is called' do
        ReservationObserver.any_instance.expects(:after_expires).never
        assert_raises @reservation.expire
      end

    end

  end

  context "confirmation" do
    should "attempt to charge user card if paying by credit card" do
      reservation = FactoryGirl.build(:reservation_with_credit_card)
      reservation.add_period(Date.today)
      reservation.total_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
      reservation.save!

      reservation.owner.billing_gateway.expects(:charge)
      reservation.confirm
      assert reservation.reload.paid?
    end
  end

  context "with serialization" do
    should "work even if the total amount is nil" do
      reservation = Reservation.new
      reservation.listing = FactoryGirl.create(:listing)
      reservation.total_amount_cents = nil

      expected = { :reservation =>
        {
          :id         => nil,
          :user_id    => nil,
          :listing_id => reservation.listing.id,
          :state      => "pending",
          :cancelable => true,
          :total_cost => { :amount=>0.0, :label=>"$0.00", :currency_code=> "USD" },
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
        assert reservation = @listing.reserve!(@user, dates, quantity)

        assert_equal Reservation::PriceCalculator.new(reservation).price.cents, reservation.total_amount_cents
      end

      should "not reset total cost when saving an existing reservation" do
        dates              = [1.week.from_now.monday]
        quantity           =  2
        assert reservation = @listing.reserve!(@user, dates, quantity)

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
          @listing.reserve!(@user, dates, quantity)
        end
      end

    end
  end

  context 'validations' do
    setup do
      @user = FactoryGirl.create(:user)

      @listing = FactoryGirl.create(:listing, quantity: 2)
      @listing.availability_template_id = AvailabilityRule.templates.first.id
      @listing.save!

      @reservation = Reservation.new(:user => @user, :quantity => 1)
      @reservation.listing = @listing

      @sunday = Date.today.end_of_week
      @monday = Date.today.next_week.beginning_of_week
    end

    context 'date availability' do
      should "validate date quantity available" do
        @reservation.add_period(@monday)
        assert @reservation.valid?

        @reservation.quantity = 3
        assert !@reservation.valid?
      end

      should "validate date available" do
        assert @listing.open_on?(@monday)
        assert !@listing.open_on?(@sunday)

        @reservation.add_period(@monday)
        assert @reservation.valid?

        @reservation.add_period(@sunday)
        assert !@reservation.valid?
      end

      should "validate against other reservations" do
        reservation = @listing.reservations.build(:user => @user, :quantity => 2)
        reservation.add_period(@monday)
        reservation.save!
        
        @reservation.add_period(@monday)
        assert !@reservation.valid? 
      end
    end

    context 'minimum contiguous block requirement' do
      setup do
        @listing.daily_price = nil
        @listing.weekly_price = 100_00
        @listing.save!

        assert_equal 5, @listing.minimum_booking_days
      end

      should "require minimum days" do
        4.times do |i|
          @reservation.add_period(@monday + i)
        end

        assert !@reservation.valid?

        @reservation.add_period(@monday+4)
        assert @reservation.valid?
      end

      should "test all blocks" do
        5.times do |i|
          @reservation.add_period(@monday + i)
        end

        # Leave a week in between
        4.times do |i|
          @reservation.add_period(@monday + i + 14)
        end

        assert !@reservation.valid?

        @reservation.add_period(@monday+ 4 + 14)
        assert @reservation.valid?
      end

    end
  end
end
