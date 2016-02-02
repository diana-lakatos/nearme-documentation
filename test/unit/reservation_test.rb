require 'test_helper'
require 'reservations_helper'
require Rails.root.join('lib', 'dnm.rb')
require Rails.root.join('app', 'serializers', 'reservation_serializer.rb')

# PLEASE NOTE:
# This test is now divided into context based on reservation state:
# If you want to add new test please do so in correct section unless it does not fit to any


class ReservationTest < ActiveSupport::TestCase
  include ReservationsHelper

  should belong_to(:listing)
  should belong_to(:owner)
  should have_many(:periods)
  should have_many(:additional_charges)

  context "State test: " do
    setup do
      stub_active_merchant_interaction
    end

    context 'inactive reservation' do
      setup do
        @reservation = FactoryGirl.build(:reservation)
      end

      should 'assign correct cancellation policies' do
        @reservation.build_payment
        assert_equal 0, @reservation.payment.cancellation_policy_hours_for_cancellation
        assert_equal 0, @reservation.payment.cancellation_policy_penalty_percentage

        @reservation.attributes = {cancellation_policy_hours_for_cancellation: 47, cancellation_policy_penalty_percentage: 60 }
        @reservation.build_payment
        assert_equal 47, @reservation.payment.cancellation_policy_hours_for_cancellation
        assert_equal 60, @reservation.payment.cancellation_policy_penalty_percentage
      end

      should 'set proper expiration time' do
        @reservation.listing.transactable_type.update_attribute(:hours_to_expiration, 45)
        travel_to Time.zone.now do
          ReservationExpiryJob.expects(:perform_later).with do |expire_at, id|
            expire_at == @reservation.expire_at && id == @reservation.id
          end
          @reservation.activate!
          assert_equal Time.now + 45.hours, @reservation.reload.expire_at
        end
      end

      should 'not create expiry job if hours is 0' do
        @reservation.activate!
        ReservationExpiryJob.expects(:perform_later).never
      end

      should "be free if total zero" do
        Reservation::DailyPriceCalculator.any_instance.stubs(:price).returns(0.to_money).at_least(1)
        @reservation.service_fee_amount_guest_cents = 0
        @reservation.service_fee_amount_host_cents = 0
        @reservation.build_payment
        assert @reservation.is_free?
        assert @reservation.payment.is_free?
      end
    end

    context 'expired reservation' do
      setup do
        @reservation = FactoryGirl.create(:expired_reservation)
      end

      should 'exist within exipred scope' do
        assert_equal 1, Reservation.expired.count
      end
    end

    context 'rejected reservation' do
      setup do
        @reservation = FactoryGirl.create(:rejected_reservation)
      end

      should 'exist within rejected scope' do
        assert_equal 1, Reservation.rejected.count
      end

      should 'not be cancelable if owner rejected' do
        refute @reservation.cancelable
      end
    end

    context 'unconfirmed reservation' do
      setup do
        @reservation = FactoryGirl.create(:unconfirmed_reservation)
      end

      should 'be cancelable if all periods are for future' do
        assert @reservation.cancelable
      end

      should 'exist within unconfirmed scope' do
        assert_equal 1, Reservation.unconfirmed.count
      end

      should 'have nil timestamps' do
        assert_nil @reservation.confirmed_at
        assert_nil @reservation.cancelled_at
      end

      should 'behave correctly when confirmed' do
        travel_to Time.zone.now do
          @reservation.confirm!
          assert_equal Time.zone.now, @reservation.confirmed_at
          assert_nil @reservation.cancelled_at
        end
      end

      should 'be rejected upon listing removal' do
        @reservation.listing.destroy
        assert @reservation.reload.rejected?
      end

      should 'not confirm when capture fails' do
        stub_active_merchant_interaction({ success?: false })
        @reservation.charge_and_confirm!
        refute @reservation.payment.reload.paid?
        refute @reservation.confirmed?
      end

      should 'confirm when capture pass' do
        @reservation.charge_and_confirm!
        assert @reservation.payment.paid?
        assert @reservation.confirmed?
      end

      should 'send emails if the expire method is called' do
        WorkflowStepJob.expects(:perform).once
        @reservation.perform_expiry!
        assert @reservation.expired?
      end

      should 'not attempt to refund when cancelled by guest' do
        @reservation.expects(:schedule_refund).never
        @reservation.user_cancel!
      end

      should 'be voided after cancel' do
        PaymentVoidJob.expects(:perform).once
        @reservation.user_cancel!
      end

      should 'schedule void on expiration' do
        PaymentVoidJob.expects(:perform).once
        @reservation.expire!
      end

      should 'set reason and update status' do
        assert_equal true, @reservation.reject('Reason')
        assert_equal 'Reason', @reservation.reload.rejection_reason
        assert_equal 'rejected', @reservation.state
      end
    end

    context 'confirmed reservation' do
      setup do
        @reservation = FactoryGirl.create(:confirmed_reservation)
      end

      should 'exist within confirmed scope' do
        assert_equal 1, Reservation.confirmed.count
      end

      should 'confirmed reservation should last after listing removed' do
        @reservation.listing.destroy
        assert @reservation.reload.confirmed?
      end

      should 'behave correctly when user cancel' do
        travel_to Time.zone.now do
          assert @reservation.cancelable
          @reservation.user_cancel!
          assert_equal Time.zone.now, @reservation.cancelled_at
          assert_nil @reservation.confirmed_at
        end
      end

      should 'schedule next refund attempt on fail' do
        stub_active_merchant_interaction({success?: false, message: "fail"})
        @reservation.host_cancel!
        assert @reservation.payment.reload.paid?
      end

      should 'not be cancelable if at least one period has past' do
        @reservation.add_period((Time.zone.today-2.day))
        @reservation.save!
        refute @reservation.cancelable
      end
    end

    context 'cancelled by guest reservation' do
      setup do
        @reservation = FactoryGirl.create(:cancelled_by_guest_reservation)
      end

      should 'exist within cancelled scope' do
        assert_equal 1, Reservation.cancelled.count
      end

      should 'not be cancelable if user canceled' do
        refute @reservation.cancelable
      end

    end

    context 'cancelled by host reservation' do
      setup do
        @reservation = FactoryGirl.create(:cancelled_by_host_reservation)
      end

      should 'exist within cancelled scope too' do
        assert_equal 1, Reservation.cancelled.count
      end

      should 'not be cancelable when owner canceled' do
        refute @reservation.cancelable
      end

    end
  end

  context 'reservation in time zone' do
    should 'should properly cast time zones' do
      Time.use_zone 'Hawaii' do
        FactoryGirl.create(:unconfirmed_reservation)
        assert_equal 1, Reservation.where("created_at < ? ", Time.now).count
        assert_equal 1, Reservation.where(["created_at < ?", Time.current]).count
        assert_equal 1, Reservation.where(["created_at < ?", Time.zone.now]).count
      end

      Reservation.destroy_all

      Time.use_zone 'Sydney' do
        FactoryGirl.create(:unconfirmed_reservation)
        assert_equal 1, Reservation.where(["created_at < ?", Time.now]).count
        assert_equal 1, Reservation.where(["created_at < ?", Time.current]).count
        assert_equal 1, Reservation.where(["created_at < ?", Time.zone.now]).count
      end
    end
  end

  context 'waiver agreement' do
    setup do
      @reservation = FactoryGirl.build(:reservation)
    end

    should 'copy instance waiver agreement template details if available' do
      @waiver_agreement_template_instance = FactoryGirl.create(:waiver_agreement_template)
      assert_difference 'WaiverAgreement.count' do
        @reservation.save!
      end
      waiver_agreement = @reservation.waiver_agreements.first
      assert_equal @waiver_agreement_template_instance.content, waiver_agreement.content
      assert_equal @waiver_agreement_template_instance.name, waiver_agreement.name
      assert_equal @reservation.host.name, waiver_agreement.vendor_name
      assert_equal @reservation.owner.name, waiver_agreement.guest_name
    end

    should 'copy instance waiver agreement template details if available, ignoring not assigned company template' do
      @waiver_agreement_template_instance = FactoryGirl.create(:waiver_agreement_template)
      @waiver_agreement_template_company = FactoryGirl.create(:waiver_agreement_template, target: @reservation.company)
      assert_difference 'WaiverAgreement.count' do
        @reservation.save!
      end
      assert_equal @waiver_agreement_template_instance.name, @reservation.waiver_agreements.first.name
    end

    should 'copy location waiver agreement template details if available, ignoring instance' do
      @waiver_agreement_template_instance = FactoryGirl.create(:waiver_agreement_template)
      @waiver_agreement_template_company = FactoryGirl.create(:waiver_agreement_template, target: @reservation.company)
      @reservation.location.waiver_agreement_templates << @waiver_agreement_template_company
      assert_difference 'WaiverAgreement.count' do
        @reservation.save!
      end
      assert_equal @waiver_agreement_template_company.name, @reservation.waiver_agreements.first.name
    end

    should 'copy listings waiver agreement templates details, ignoring location' do
      @waiver_agreement_template_instance = FactoryGirl.create(:waiver_agreement_template)
      @waiver_agreement_template_company = FactoryGirl.create(:waiver_agreement_template, target: @reservation.company)
      @waiver_agreement_template_company2 = FactoryGirl.create(:waiver_agreement_template, target: @reservation.company)
      @reservation.listing.waiver_agreement_templates << @waiver_agreement_template_company
      @reservation.listing.waiver_agreement_templates << @waiver_agreement_template_company2
      assert_difference 'WaiverAgreement.count', 2 do
        @reservation.save!
      end
      assert_equal [@waiver_agreement_template_company.name, @waiver_agreement_template_company2.name], @reservation.waiver_agreements.pluck(:name)
    end
  end

  context "with serialization" do
    should "work even if the total amount is nil" do
      reservation = Reservation.new state: 'unconfirmed'
      reservation.listing = FactoryGirl.create(:transactable)
      reservation.subtotal_amount_cents = nil
      reservation.service_fee_amount_guest_cents = nil
      reservation.service_fee_amount_host_cents = nil
      Reservation::CancellationPolicy.any_instance.stubs(:cancelable?).returns(true)

      expected = {
        reservation: {
          id:nil,
          user_id: nil,
          listing_id: reservation.listing.id,
          state: "pending",
          cancelable: true,
          total_cost: { amount: 0.0, label: "$0.00", currency_code: "USD" },
          times: []
        }
      }

      assert_equal expected, ReservationSerializer.new(reservation).as_json
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

  context 'validations' do
    setup do
      @user = FactoryGirl.create(:user)

      @listing = FactoryGirl.create(:transactable, quantity: 2)
      @listing.availability_template = AvailabilityTemplate.first
      @listing.save!

      @reservation = Reservation.new(:user => @user, :quantity => 1, listing: @listing)

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
        first_reservation = FactoryGirl.create(:confirmed_reservation, listing: @listing)
        first_reservation.add_period(@monday)
        first_reservation.save!

        @reservation.add_period(@monday)
        @reservation.validate_all_dates_available
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

  # TODO rewrite what's below this line

  context "with reservation pricing" do
    context "daily priced listing" do
      setup do
        FactoryGirl.create(:manual_payment_method)

        @listing = FactoryGirl.build(:transactable, quantity: 10)
        @user    = FactoryGirl.build(:user)
        @reservation = FactoryGirl.build(:reservation, user: @user, listing: @listing)
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
        )

        dates.each do |date|
          reservation.add_period(date)
        end

        reservation.calculate_prices

        assert_equal Reservation::DailyPriceCalculator.new(reservation).price.cents, reservation.subtotal_amount.cents
        assert_equal reservation.subtotal_amount_cents * 0.1, reservation.service_fee_amount_guest.cents
        assert_equal reservation.subtotal_amount_cents * 0.1, reservation.service_fee_amount_host.cents
        assert_equal reservation.subtotal_amount_cents + reservation.service_fee_amount_guest_cents, reservation.total_amount.cents

      end

      should "not reset total cost when saving an existing reservation" do

        WorkflowStepJob.expects(:perform).with do |klass, id|
          klass == WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation
        end

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
        reservation = @listing.reservations.build(
          user: @user,
          date: 1.week.from_now.monday,
          quantity: 1
        )
        reservation.calculate_prices
        assert_not_equal 0, reservation.service_fee_amount_guest.cents
        assert_not_equal 0, reservation.service_fee_amount_host.cents
      end

      should "charge a service fee to manual payment reservations" do
        reservation = @listing.reservations.build(
          user: @user,
          date: 1.week.from_now.monday,
          quantity: 1
        )
        reservation.calculate_prices
        assert_not_equal 0, reservation.service_fee_amount_guest.cents
        assert_not_equal 0, reservation.service_fee_amount_host.cents
      end

      context 'with additional charges' do
        setup do
          @act = FactoryGirl.create(:additional_charge_type)
          @reservation.additional_charges.build(additional_charge_type_id: @act.id)
        end

        should 'include fee for additional charges' do
          assert_equal @act.amount_cents, @reservation.service_additional_charges_cents
        end
      end
    end

    context "hourly priced listing" do
      setup do
        @listing = FactoryGirl.create(:transactable, quantity: 10, action_hourly_booking: true, hourly_price_cents: 100)
        @reservation = FactoryGirl.create(:reservation, listing: @listing, reservation_type: 'hourly')
      end

      should "set total cost based on HourlyPriceCalculator" do
        @reservation.periods.build date: Time.zone.today.advance(weeks: 1).beginning_of_week, start_minute: 9*60, end_minute: 12*60
        assert_equal Reservation::HourlyPriceCalculator.new(@reservation).price.cents +
          @reservation.service_fee_amount_guest.cents, @reservation.total_amount_cents
      end
    end
  end
end

