require 'test_helper'
require 'reservations_helper'
require Rails.root.join('lib', 'dnm.rb')
require Rails.root.join('app', 'serializers', 'reservation_serializer.rb')

class ReservationTest < ActiveSupport::TestCase
  include ReservationsHelper

  should belong_to(:listing)
  should belong_to(:owner)
  should have_many(:periods)

  setup do
    stub_mixpanel
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
      FactoryGirl.create(:reservation, :state => 'cancelled_by_guest')
      FactoryGirl.create(:reservation, :state => 'cancelled_by_host')
      assert_equal 2, Reservation.cancelled.count
    end
  end

  context 'timestamps' do

    should 'have both timestamps nil initially' do
      @reservation = FactoryGirl.create(:reservation, :state => 'unconfirmed')
      assert_nil @reservation.confirmed_at
      assert_nil @reservation.cancelled_at
    end
    should 'have correct confirmed_at' do
      @reservation = FactoryGirl.create(:reservation, :state => 'unconfirmed')
      Timecop.freeze(Time.zone.now) do
        @reservation.confirm!
        assert_equal Time.zone.now, @reservation.confirmed_at
        assert_nil @reservation.cancelled_at
      end
    end

    should 'have correct cancelled_at when cancelled by guest' do
      @reservation = FactoryGirl.create(:reservation, :state => 'confirmed')
      Timecop.freeze(Time.zone.now) do
        @reservation.user_cancel!
        assert_equal Time.zone.now, @reservation.cancelled_at
      end
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

    context 'cancellation policy returns true' do

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
        @reservation.save!
        refute @reservation.cancelable
      end

      should 'not be cancelable if at least one period is for past no matter order' do
        @reservation.add_period((Time.zone.today-2.day))
        @reservation.add_period((Time.zone.today+2.day))
        @reservation.save!
        refute @reservation.cancelable
      end

      should 'not be cancelable if user canceled' do
        @reservation.user_cancel!
        refute @reservation.cancelable
      end

      should 'not be cancelable if owner rejected' do
        @reservation.reject!
        refute @reservation.cancelable
      end

      should 'not be cancelable if expired' do
        @reservation.expire!
        refute @reservation.cancelable
      end

      should 'not be cancelable if owner canceled' do
        @reservation.confirm!
        @reservation.host_cancel!
        refute @reservation.cancelable
      end

    end

  end

  context 'attempt_payment_capture' do

    setup do
      TransactableType.update_all({
        cancellation_policy_enabled: Time.zone.now,
        cancellation_policy_hours_for_cancellation: 48,
        cancellation_policy_penalty_percentage: 50})
      ReservationCharge.any_instance.expects(:capture).once
    end

    should 'create reservation charge with cancellation policy if enabled ignoring updated values' do
      @reservation = FactoryGirl.create(:reservation_with_credit_card, :state => 'unconfirmed', cancellation_policy_hours_for_cancellation: 24, cancellation_policy_penalty_percentage: 60)
      assert_difference 'ReservationCharge.count' do
        @reservation.confirm!
      end
      @reservation_charge = @reservation.reservation_charges.last
      assert_equal 24, @reservation_charge.cancellation_policy_hours_for_cancellation
      assert_equal 60, @reservation_charge.cancellation_policy_penalty_percentage
    end

    should 'create reservation charge without cancellation policy if disabled, despite adding it later' do
      @reservation = FactoryGirl.create(:reservation_with_credit_card, :state => 'unconfirmed')
      TransactableType.update_all(cancellation_policy_enabled: nil)
      assert_difference 'ReservationCharge.count' do
        @reservation.confirm!
      end
      @reservation_charge = @reservation.reservation_charges.last
      assert_equal 0, @reservation_charge.cancellation_policy_hours_for_cancellation
      assert_equal 0, @reservation_charge.cancellation_policy_penalty_percentage
    end

  end

  context 'attempt_payment_refund' do
    setup do
      @charge = FactoryGirl.create(:charge)
      @reservation = @charge.reference.reservation
      @reservation.stubs(:attempt_payment_capture).returns(true)
      @reservation.confirm!
      @reservation.update_column(:payment_status, Reservation::PAYMENT_STATUSES[:paid])
    end

    context 'when to trigger' do
      should 'attempt to refund when cancelled by host' do
        @reservation.expects(:schedule_refund).once
        @reservation.host_cancel!
      end

      should 'attempt to refund when cancelled by guest' do
        @reservation.expects(:schedule_refund).once
        @reservation.user_cancel!
      end

      should 'not attempt to refund when cancelled by guest but was unconfirmed' do
        @reservation.update_column(:state, 'unconfirmed')
        @reservation = Reservation.find(@reservation.id)
        @reservation.expects(:schedule_refund).never
        @reservation.user_cancel!
      end

    end

    should 'be able to schedule refund' do
      Timecop.freeze(Time.zone.now) do
        ReservationRefundJob.expects(:perform_later).with do |time, id, counter|
          time.to_i == Time.zone.now.to_i && id == @reservation.id && counter == 0
        end.once
      end
      @reservation.send(:schedule_refund, nil)
    end

    should 'change payment status to refunded if successfully refunded' do
      @reservation.update_column(:payment_method, 'credit_card')
      ReservationCharge.any_instance.expects(:refund).returns(true)
      @reservation.send(:attempt_payment_refund)
      assert_equal Reservation::PAYMENT_STATUSES[:refunded], @reservation.reload.payment_status
    end

    should 'schedule next refund attempt on fail' do
      @reservation.update_column(:payment_method, 'credit_card')
      ReservationCharge.any_instance.expects(:refund).returns(false)
      Timecop.freeze(Time.zone.now) do
        ReservationRefundJob.expects(:perform_later).with do |time, id, counter|
          time.to_i == (Time.zone.now + 12.hours).to_i && id == @reservation.id && counter == 2
        end.once
      end
      @reservation.send(:attempt_payment_refund, 1)
      assert_equal Reservation::PAYMENT_STATUSES[:paid], @reservation.reload.payment_status
    end

    should 'stop schedluing next refund attempt after 3 attempts' do
      @reservation.update_column(:payment_method, 'credit_card')
      ReservationCharge.any_instance.expects(:refund).returns(false)
      ReservationRefundJob.expects(:perform_later).never
      BackgroundIssueLogger.expects(:log_issue)
      @reservation.send(:attempt_payment_refund, 2)
      assert_equal Reservation::PAYMENT_STATUSES[:paid], @reservation.reload.payment_status
    end

    should 'abort attempt to refund if payment was manual' do
      @reservation.update_column(:payment_method, 'manual')
      ReservationCharge.any_instance.expects(:refund).never
      @reservation.send(:attempt_payment_refund)
      assert_equal Reservation::PAYMENT_STATUSES[:paid], @reservation.reload.payment_status
    end

    should 'abort attempt to refund if payment was free' do
      @reservation.update_column(:payment_method, 'free')
      ReservationCharge.any_instance.expects(:refund).never
      @reservation.host_cancel!
      assert_equal Reservation::PAYMENT_STATUSES[:paid], @reservation.reload.payment_status
    end
  end

  context 'expiration' do

    context 'with a confirmed reservation' do

      setup do
        Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:charge)
        @reservation = FactoryGirl.build(:reservation_with_credit_card)
        @reservation.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)

        @reservation.subtotal_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
        @reservation.service_fee_amount_guest_cents = 10_00
        @reservation.service_fee_amount_host_cents = 10_00
        @reservation.create_billing_authorization(token: "token", payment_gateway_class: "Billing::Gateway::Processor::Incoming::Stripe", payment_gateway_mode: "test")
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

    setup do
      @reservation = FactoryGirl.build(:reservation_with_credit_card)
      @reservation.subtotal_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
      @reservation.service_fee_amount_guest_cents = 10_00
      @reservation.service_fee_amount_host_cents = 10_00
      @reservation.create_billing_authorization(token: "token", payment_gateway_class: "Billing::Gateway::Processor::Incoming::Stripe", payment_gateway_mode: "test")
      @reservation.save!
    end

    should "attempt to charge user card if paying by credit card" do
      @reservation.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
      Billing::Gateway::Processor::Incoming::Stripe.any_instance.expects(:charge)
      @reservation.confirm
      assert @reservation.reload.paid?
    end

  end

  context "with serialization" do
    should "work even if the total amount is nil" do
      reservation = Reservation.new
      reservation.listing = FactoryGirl.create(:transactable)
      reservation.subtotal_amount_cents = nil
      reservation.service_fee_amount_guest_cents = nil
      reservation.service_fee_amount_host_cents = nil
      Reservation::CancellationPolicy.any_instance.stubs(:cancelable?).returns(true)

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
        @listing = FactoryGirl.create(:transactable, quantity: 10)
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
        assert_equal Reservation::ServiceFeeCalculator.new(reservation).service_fee_guest.cents, reservation.service_fee_amount_guest_cents
        assert_equal Reservation::ServiceFeeCalculator.new(reservation).service_fee_host.cents, reservation.service_fee_amount_host_cents
        assert_equal Reservation::DailyPriceCalculator.new(reservation).price.cents +
          Reservation::ServiceFeeCalculator.new(reservation).service_fee_guest.cents,
          reservation.total_amount_cents

      end

      should "not reset total cost when saving an existing reservation" do
        ReservationMailer.expects(:notify_host_with_confirmation).returns(mailer_stub).at_least_once
        ReservationMailer.expects(:notify_guest_with_confirmation).returns(mailer_stub).at_least_once

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

        assert_not_equal 0, reservation.service_fee_amount_guest_cents
        assert_not_equal 0, reservation.service_fee_amount_host_cents
      end

      should "not charge a service fee to manual payment reservations" do
        reservation = @listing.reservations.create!(
          user: @user,
          date: 1.week.from_now.monday,
          quantity: 1,
          payment_method: 'manual'
        )

        assert_equal 0, reservation.service_fee_amount_guest_cents
        assert_equal 0, reservation.service_fee_amount_host_cents
      end
    end

    context "hourly priced listing" do
      setup do
        @listing = FactoryGirl.create(:transactable, quantity: 10, hourly_reservations: true, hourly_price_cents: 100)
        @user = FactoryGirl.create(:user)
        @reservation = @listing.reservations.build(
          :user => @user
        )
      end

      should "set total cost based on HourlyPriceCalculator" do
        @reservation.periods.build :date => Time.zone.today.advance(:weeks => 1).beginning_of_week, :start_minute => 9*60, :end_minute => 12*60
        assert_equal Reservation::HourlyPriceCalculator.new(@reservation).price.cents +
          Reservation::ServiceFeeCalculator.new(@reservation).service_fee_guest.cents,
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
      refute reservation.pending?
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

      @listing = FactoryGirl.create(:transactable, quantity: 2)
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
        refute @reservation.valid?
      end

      should "validate date available" do
        assert @listing.open_on?(@monday)
        refute @listing.open_on?(@sunday)

        @reservation.add_period(@monday)
        assert @reservation.valid?

        @reservation.add_period(@sunday)
        refute @reservation.valid?
      end

      should "validate against other reservations" do
        reservation = @listing.reservations.build(:user => @user, :quantity => 2)
        reservation.add_period(@monday)
        reservation.save!

        @reservation.add_period(@monday)
        refute @reservation.valid?
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

        refute @reservation.valid?

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

        refute @reservation.valid?

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

  context 'foreign keys' do
    setup do
      @listing = FactoryGirl.create(:transactable)
      @reservation = FactoryGirl.create(:reservation, :listing => @listing)
    end

    should 'assign correct key immediately' do
      @reservation = FactoryGirl.create(:reservation)
      assert @reservation.creator_id.present?
      assert @reservation.instance_id.present?
      assert @reservation.company_id.present?
      assert @reservation.listings_public
    end

    should 'assign correct creator_id' do
      assert_equal @listing.creator_id, @reservation.creator_id
    end

    should 'assign correct company_id' do
      assert_equal @listing.company_id, @reservation.company_id
    end

    should 'assign administrator_id' do
      @reservation.location.update_attribute(:administrator_id, @reservation.location.creator_id + 1)
      assert_equal @reservation.location.administrator_id, @reservation.reload.administrator_id
    end

    context 'update company' do

      should 'assign correct creator_id' do
        @reservation.company.update_attribute(:creator_id, @reservation.company.creator_id + 1)
        assert_equal @reservation.company.creator_id, @reservation.reload.creator_id
      end

      should 'assign correct company_id' do
        @reservation.location.update_attribute(:company_id, @reservation.location.company_id + 1)
        assert_equal @reservation.location.company_id, @reservation.reload.company_id
      end

      should 'assign correct partner_id' do
        partner = FactoryGirl.create(:partner)
        @reservation.company.update_attribute(:partner_id, partner.id)
        assert_equal partner.id, @reservation.reload.partner_id
      end

      should 'assign correct instance_id' do
        instance = FactoryGirl.create(:instance)
        @reservation.company.update_attribute(:instance_id, instance.id)
        PlatformContext.any_instance.stubs(:instance).returns(instance)
        assert_equal instance.id, @reservation.reload.instance_id
      end

      should 'update listings_public' do
        assert @reservation.listings_public
        @reservation.company.update_attribute(:listings_public, false)
        refute @reservation.reload.listings_public
      end
    end

  end
end
