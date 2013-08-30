require 'test_helper'
require 'reservations_helper'
require Rails.root.join('lib', 'dnm.rb')
require Rails.root.join('app', 'serializers', 'reservation_serializer.rb')

class ReservationTest < ActiveSupport::TestCase
  include ReservationsHelper

  setup do
    stub_mixpanel
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

  context 'scopes' do

    setup do
      FactoryGirl.create(:reservation, :state => 'unconfirmed')
    end

    should 'find rejected reservations' do
      FactoryGirl.create(:reservation, :state => 'rejected') 
      assert_equal 1, Reservation.rejected.count
    end

    should 'find confirmed reservations' do
      FactoryGirl.create(:reservation, :state => 'confirmed') 
      assert_equal 1, Reservation.confirmed.count
    end

    should 'find expired reservations' do
      FactoryGirl.create(:reservation, :state => 'expired') 
      assert_equal 1, Reservation.expired.count
    end

    should 'find cancelled reservations' do
      FactoryGirl.create(:reservation, :state => 'cancelled') 
      assert_equal 1, Reservation.cancelled.count
    end
  end

  context 'cancelable' do

    setup do
        @reservation = Reservation.new
        @reservation.listing = FactoryGirl.create(:always_open_listing)
        @reservation.owner = FactoryGirl.create(:user)
        @reservation.add_period(Time.zone.today.next_week+1)
        @reservation.save!
    end

    should 'be cancelable if all periods are for future' do
        assert @reservation.cancelable
    end

    should 'be cancelable if all periods are for future and confirmed' do
        @reservation.confirm!
        assert @reservation.cancelable
    end

    should 'not be cancelable if at least one period is for past' do
        @reservation.add_period((Time.zone.today+2.day))
        @reservation.add_period((Time.zone.today-2.day))
        assert !@reservation.cancelable
    end

    should 'not be cancelable if user canceled' do
        @reservation.user_cancel!
        assert !@reservation.cancelable
    end

    should 'not be cancelable if owner rejected' do
        @reservation.reject!
        assert !@reservation.cancelable
    end

    should 'not be cancelable if expired' do
        @reservation.expire!
        assert !@reservation.cancelable
    end

    should 'not be cancelable if owner canceled' do
        @reservation.confirm!
        @reservation.host_cancel!
        assert !@reservation.cancelable
    end

  end

  context 'expiration' do

    context 'with an unsaved reservation' do

      setup do
        @reservation = FactoryGirl.build(:reservation_with_credit_card)
        @reservation.subtotal_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
        @reservation.service_fee_amount_cents = 10_00
        Timecop.freeze(@reservation.periods.first.date)
      end

      teardown do
        Timecop.return
      end

      should 'create a delayed_job task to run in 24 hours time when saved' do
        Timecop.freeze(Time.zone.now) do
          assert_difference 'Delayed::Job.count' do
            @reservation.save!
          end

          assert_equal 24.hours.from_now.to_i, Delayed::Job.last.run_at.to_i
        end
      end

    end

    context 'with a confirmed reservation' do

      setup do
        User::BillingGateway.any_instance.expects(:charge)
        @reservation = FactoryGirl.build(:reservation_with_credit_card)
        @reservation.subtotal_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
        @reservation.service_fee_amount_cents = 10_00
        @reservation.save!
        @reservation.confirm
      end

      should 'not send any email if the expire method is called' do
        ReservationMailer.expects(:notify_guest_of_expiration).never
        @reservation.perform_expiry!
      end

    end

  end

  context "confirmation" do
    should "attempt to charge user card if paying by credit card" do
      reservation = FactoryGirl.build(:reservation_with_credit_card)
      reservation.subtotal_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
      reservation.service_fee_amount_cents = 10_00
      reservation.save!

      User::BillingGateway.any_instance.expects(:charge)
      reservation.confirm
      assert reservation.reload.paid?
    end
  end

  context "with serialization" do
    should "work even if the total amount is nil" do
      reservation = Reservation.new
      reservation.listing = FactoryGirl.create(:listing)
      reservation.subtotal_amount_cents = nil
      reservation.service_fee_amount_cents = nil

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
    context "daily priced listing" do
      setup do
        @listing = FactoryGirl.create(:listing, quantity: 10)
        @user    = FactoryGirl.create(:user)
        @reservation = @listing.reservations.build(:user => @user)
      end

      should "set total, subtotal and service fee cost after creating a new reservation" do
        dates              = [Time.zone.today, Date.tomorrow, Time.zone.today + 5, Time.zone.today + 6].map { |d|
          d += 1 if d.wday == 6
          d += 1 if d.wday == 0
          d
        }
        quantity           =  5

        reservation = @listing.reservations.build(
          user: @user,
          quantity: quantity,
          payment_method: 'credit_card'
        )

        dates.each do |date|
          reservation.add_period(date)
        end

        reservation.save!

        assert_equal Reservation::DailyPriceCalculator.new(reservation).price.cents, reservation.subtotal_amount_cents
        assert_equal Reservation::ServiceFeeCalculator.new(reservation).service_fee.cents, reservation.service_fee_amount_cents
        assert_equal Reservation::DailyPriceCalculator.new(reservation).price.cents +
                     Reservation::ServiceFeeCalculator.new(reservation).service_fee.cents,
                     reservation.total_amount_cents

      end

      should "not reset total cost when saving an existing reservation" do
        ReservationMailer.expects(:notify_host_with_confirmation).returns(stub(deliver: true)).at_least_once
        ReservationMailer.expects(:notify_guest_with_confirmation).returns(stub(deliver: true)).at_least_once

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
        dates    = [Time.zone.today]
        quantity = 11

        assert quantity > @listing.availability_for(dates.first)

        assert_raises DNM::PropertyUnavailableOnDate do
          @listing.reserve!(@user, dates, quantity)
        end
      end

      should "charge a service fee to credit card paid reservations" do
        reservation = @listing.reservations.create!(
          user: @user,
          date: 1.week.from_now.monday,
          quantity: 1,
          payment_method: 'credit_card'
        )

        assert_not_equal 0, reservation.service_fee_amount_cents
      end

      should "not charge a service fee to manual payment reservations" do
        reservation = @listing.reservations.create!(
          user: @user,
          date: 1.week.from_now.monday,
          quantity: 1,
          payment_method: 'manual'
        )

        assert_equal 0, reservation.service_fee_amount_cents
      end
    end

    context "hourly priced listing" do
      setup do
        @listing = FactoryGirl.create(:listing, quantity: 10, hourly_reservations: true, hourly_price_cents: 100)
        @user = FactoryGirl.create(:user)
        @reservation = @listing.reservations.build(
          :user => @user
        )
      end

      should "set total cost based on HourlyPriceCalculator" do
        @reservation.periods.build :date => Time.zone.today.advance(:weeks => 1).beginning_of_week, :start_minute => 9*60, :end_minute => 12*60
        assert_equal Reservation::HourlyPriceCalculator.new(@reservation).price.cents +
                     Reservation::ServiceFeeCalculator.new(@reservation).service_fee.cents, 
                     @reservation.total_amount_cents
      end
    end
  end

  context "payments" do
    should "set default payment status to pending" do
      reservation = FactoryGirl.build(:reservation)
      reservation.payment_status = nil
      reservation.save!
      assert reservation.pending?

      reservation = FactoryGirl.build(:reservation)
      reservation.payment_status = Reservation::PAYMENT_STATUSES[:unknown]
      reservation.save!
      assert reservation.pending?

      reservation = FactoryGirl.build(:reservation)
      reservation.payment_status = Reservation::PAYMENT_STATUSES[:paid]
      reservation.save!
      assert !reservation.pending?
    end

    should "set default payment status to paid for free reservations" do
      reservation = FactoryGirl.build(:reservation)
      Reservation::DailyPriceCalculator.any_instance.stubs(:price).returns(0.to_money)
      reservation.save!
      assert reservation.free?
      assert reservation.paid?
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

      @sunday = Time.zone.today.end_of_week
      @monday = Time.zone.today.next_week.beginning_of_week
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

  context '#reject' do
    subject { FactoryGirl.create(:reservation) }
    should 'set reason and update status' do
      assert_equal subject.reject('Reason'), true
      assert_equal subject.reload.rejection_reason, 'Reason'
      assert_equal subject.state, 'rejected'
    end
  end
end
