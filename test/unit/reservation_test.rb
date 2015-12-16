require 'test_helper'
require 'reservations_helper'
require Rails.root.join('lib', 'dnm.rb')
require Rails.root.join('app', 'serializers', 'reservation_serializer.rb')

class ReservationTest < ActiveSupport::TestCase
  include ReservationsHelper

  should belong_to(:listing)
  should belong_to(:owner)
  should have_many(:periods)
  should have_many(:additional_charges)

  setup do
    stub_mixpanel
    @manual_payment_method = FactoryGirl.create(:manual_payment_gateway).payment_methods.first
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
      travel_to Time.zone.now do
        @reservation.confirm!
        assert_equal Time.zone.now, @reservation.confirmed_at
        assert_nil @reservation.cancelled_at
      end
    end

    should 'have correct cancelled_at when cancelled by guest' do
      @reservation = FactoryGirl.create(:reservation, :state => 'confirmed')
      travel_to Time.zone.now do
        @reservation.user_cancel!
        assert_equal Time.zone.now, @reservation.cancelled_at
      end
    end

    should 'should properly cast time zones' do
      Time.use_zone 'Hawaii' do
        FactoryGirl.create(:reservation_with_credit_card)
        assert_equal 1, Reservation.where("created_at < ? ", Time.now).count
        assert_equal 1, Reservation.where(["created_at < ?", Time.current]).count
        assert_equal 1, Reservation.where(["created_at < ?", Time.zone.now]).count
      end

      Reservation.destroy_all

      Time.use_zone 'Sydney' do
        FactoryGirl.create(:reservation_with_credit_card)
        assert_equal 1, Reservation.where(["created_at < ?", Time.now]).count
        assert_equal 1, Reservation.where(["created_at < ?", Time.current]).count
        assert_equal 1, Reservation.where(["created_at < ?", Time.zone.now]).count
      end
    end

  end

  context 'parent transactable deleted' do

    should 'unconfirm reservation become rejected' do
      @reservation = FactoryGirl.create(:reservation, :state => 'unconfirmed')
      @reservation.listing.destroy
      assert @reservation.reload.rejected?
    end

    should 'confirm reservation stay at it is' do
      @reservation = FactoryGirl.create(:reservation, :state => 'confirmed')
      @reservation.listing.destroy
      refute @reservation.reload.rejected?
      assert @reservation.confirmed?
    end

  end

  context 'cancelable' do

    setup do
      @reservation = Reservation.new payment_method: @manual_payment_method
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
      Payment.any_instance.expects(:capture).once
      Reservation.any_instance.stubs(:billing_authorization).returns(stub()).at_least(0)
    end

    should 'create reservation charge with cancellation policy if enabled ignoring updated values' do
      @reservation = FactoryGirl.create(:reservation_with_credit_card, :state => 'unconfirmed', cancellation_policy_hours_for_cancellation: 47, cancellation_policy_penalty_percentage: 60)
      assert_difference 'Payment.count' do
        @reservation.payment_capture
      end
      @payment = @reservation.payments.last
      assert_equal 47, @payment.cancellation_policy_hours_for_cancellation
      assert_equal 60, @payment.cancellation_policy_penalty_percentage
    end

    should 'create reservation charge without cancellation policy if disabled, despite adding it later' do
      @reservation = FactoryGirl.create(:reservation_with_credit_card, :state => 'unconfirmed')
      TransactableType.update_all(cancellation_policy_enabled: nil)
      assert_difference 'Payment.count' do
        @reservation.payment_capture
      end
      @payment = @reservation.payments.last
      assert_equal 0, @payment.cancellation_policy_hours_for_cancellation
      assert_equal 0, @payment.cancellation_policy_penalty_percentage
    end

    should 'not confirm when capture fails' do
      @reservation = FactoryGirl.create(:reservation_with_credit_card, :state => 'unconfirmed')
      assert_difference 'Payment.count' do
        @reservation.payment_capture
      end
      @payment = @reservation.payments.last
      assert_equal false, @payment.paid?
      assert_equal "failed", @reservation.reload.payment_status
      assert_equal false, @reservation.confirmed?
    end

  end

  context 'attempt_payment_refund' do
    setup do
      @charge = FactoryGirl.create(:charge)
      @reservation = @charge.payment.payable
      @reservation.stubs(:attempt_payment_capture).returns(true)
      @reservation.stubs(:payment_capture).returns(true)
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

    context 'payment capture' do
      setup do
        @reservation = FactoryGirl.create(:reservation, state: 'unconfirmed')
      end

      should 'not be invoked when we check if reservation can be confirmed' do
        @reservation.expects(:payment_capture).never
        @reservation.can_confirm?
      end

      should 'not be confirmed if payment capture fails' do
        @reservation.stubs(:payment_capture).returns(false)
        @reservation.confirm
        refute @reservation.confirmed?
      end

      should 'be confirmed if payment capture succeeds ' do
        @reservation.expects(:payment_capture).returns(true)
        @reservation.confirm
        assert @reservation.confirmed?
      end
    end

    context 'void' do

      context 'manual payment reservation' do

        should 'not schedule payment transfer on cancel' do
          @reservation = FactoryGirl.create(:reservation, state: 'unconfirmed')
          ReservationVoidPaymentJob.expects(:perform).never
          @reservation.user_cancel!
        end
      end

      context 'credit card reservation' do

        setup do
          @reservation = FactoryGirl.create(:reservation_with_credit_card, state: 'unconfirmed')
          @reservation.stubs(:billing_authorization).returns(stub(present: true))
        end

        should 'schedule void on guest cancellation' do
          ReservationVoidPaymentJob.expects(:perform).once
          @reservation.user_cancel!
        end

        should 'schedule void on expiration' do
          ReservationVoidPaymentJob.expects(:perform).once
          @reservation.expire!
        end

      end

    end

    should 'be able to schedule refund' do
      travel_to Time.zone.now do
        ReservationRefundJob.expects(:perform_later).with do |time, id, counter|
          time.to_i == Time.zone.now.to_i && id == @reservation.id && counter == 0
        end.once
      end
      @reservation.send(:schedule_refund, nil)
    end

    should 'change payment status to refunded if successfully refunded' do
      @reservation.update_column(:payment_method_id, FactoryGirl.create(:credit_card_payment_method).id)
      Payment.any_instance.expects(:refund).returns(true)
      @reservation.send(:attempt_payment_refund)
      assert_equal Reservation::PAYMENT_STATUSES[:refunded], @reservation.reload.payment_status
    end

    should 'schedule next refund attempt on fail' do
      @reservation.update_column(:payment_method_id, FactoryGirl.create(:credit_card_payment_method).id)
      Payment.any_instance.expects(:refund).returns(false)
      travel_to Time.zone.now do
        ReservationRefundJob.expects(:perform_later).with do |time, id, counter|
          time.to_i == (Time.zone.now + 12.hours).to_i && id == @reservation.id && counter == 2
        end.once
      end
      @reservation.send(:attempt_payment_refund, 1)
      assert_equal Reservation::PAYMENT_STATUSES[:paid], @reservation.reload.payment_status
    end

    should 'stop schedluing next refund attempt after 3 attempts' do
      @reservation.update_column(:payment_method_id, FactoryGirl.create(:credit_card_payment_method).id)
      Payment.any_instance.expects(:refund).returns(false)
      ReservationRefundJob.expects(:perform_later).never
      Rails.application.config.marketplace_error_logger.class.any_instance.stubs(:log_issue).with do |error_type, msg|
        error_type == MarketplaceErrorLogger::BaseLogger::REFUND_ERROR && msg.include?("Refund for Reservation id=#{@reservation.id}")
      end
      @reservation.send(:attempt_payment_refund, 2)
      assert_equal Reservation::PAYMENT_STATUSES[:paid], @reservation.reload.payment_status
    end

    should 'abort attempt to refund if payment was manual' do
      @reservation.update_column(:payment_method_id, @manual_payment_method.id)
      Payment.any_instance.expects(:refund).never
      @reservation.send(:attempt_payment_refund)
      assert_equal Reservation::PAYMENT_STATUSES[:paid], @reservation.reload.payment_status
    end

    # TODO - think how to handle FREE - payment_method
    # should 'abort attempt to refund if payment was free' do
    #   @reservation.update_column(:payment_method_id, FactoryGirl.create(:credit_card_payment_method).id)
    #   Payment.any_instance.expects(:refund).never
    #   @reservation.host_cancel!
    #   assert_equal Reservation::PAYMENT_STATUSES[:paid], @reservation.reload.payment_status
    # end
  end

  context 'expiration' do

    setup do
      stub_active_merchant_interaction
      @payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
      @payment_method = @payment_gateway.payment_methods.first
      @reservation = FactoryGirl.build(:reservation_with_credit_card)

      @reservation.subtotal_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
      @reservation.service_fee_amount_guest_cents = 10_00
      @reservation.service_fee_amount_host_cents = 10_00
      @reservation.create_billing_authorization(token: "token", payment_gateway: @payment_gateway, payment_gateway_mode: "test")
      @reservation.save!
    end

    should 'not send any email if the expire method is called' do
      @reservation.confirm
      WorkflowStepJob.expects(:perform).never
      @reservation.perform_expiry!
    end

  end

  context 'expiration settings' do
    setup do
    end

    should 'set proper expiration time' do
      TransactableType.first.update_attribute(:hours_to_expiration, 45)
      @reservation = FactoryGirl.create(:reservation)
      travel_to Time.zone.now do
        ReservationExpiryJob.expects(:perform_later).with do |hours, id|
          hours == 45.hours && id == @reservation.id
        end
        @reservation.schedule_expiry
      end
      assert_equal 45, @reservation.hours_to_expiration
    end

    should 'not create expiry job if hours is 0' do
      TransactableType.first.update_attribute(:hours_to_expiration, 0)
      @reservation = FactoryGirl.create(:reservation)
      ReservationExpiryJob.expects(:perform_later).never
      @reservation.schedule_expiry
      assert_equal 0, @reservation.hours_to_expiration
    end

  end

  context "confirmation" do

    setup do
      @reservation = FactoryGirl.build(:reservation_with_credit_card)
      @reservation.subtotal_amount_cents = 100_00 # Set this to force the reservation to have an associated cost
      @reservation.service_fee_amount_guest_cents = 10_00
      @reservation.service_fee_amount_host_cents = 10_00
      @payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
      @reservation.create_billing_authorization(token: "token", payment_gateway: @payment_gateway, payment_gateway_mode: "test")
      @reservation.save!
    end

    should "attempt to charge user card if paying by credit card" do
      stub_active_merchant_interaction
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

  context "with reservation pricing" do
    context "daily priced listing" do
      setup do
        @listing = FactoryGirl.create(:transactable, quantity: 10)
        @user    = FactoryGirl.create(:user)
        @payment_method = FactoryGirl.create(:credit_card_payment_method)
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
          payment_method_id: @payment_method.id
        )

        dates.each do |date|
          reservation.add_period(date)
        end

        reservation.save!

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
        reservation = @listing.reservations.create!(
          user: @user,
          date: 1.week.from_now.monday,
          quantity: 1,
          payment_method: @payment_method
        )

        assert_not_equal 0, reservation.service_fee_amount_guest.cents
        assert_not_equal 0, reservation.service_fee_amount_host.cents
      end

      should "charge a service fee to manual payment reservations" do
        reservation = @listing.reservations.create!(
          user: @user,
          date: 1.week.from_now.monday,
          quantity: 1,
          payment_method: @manual_payment_method
        )

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

        should 'calculate fee wo additional charges' do
          assert_equal 0, @reservation.service_fee_amount_guest
        end
      end
    end

    context "hourly priced listing" do
      setup do
        @listing = FactoryGirl.create(:transactable, quantity: 10, action_hourly_booking: true, hourly_price_cents: 100)
        @reservation = @listing.reservations.build(reservation_type: 'hourly', payment_method_id: FactoryGirl.create(:credit_card_payment_method).id )
      end

      should "set total cost based on HourlyPriceCalculator" do
        @reservation.periods.build date: Time.zone.today.advance(weeks: 1).beginning_of_week, start_minute: 9*60, end_minute: 12*60
        assert_equal Reservation::HourlyPriceCalculator.new(@reservation).price.cents +
          @reservation.service_fee_amount_guest.cents, @reservation.total_amount_cents
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
      Reservation::DailyPriceCalculator.any_instance.stubs(:price).returns(0.to_money).at_least(1)
      reservation = FactoryGirl.build(:reservation)
      reservation.save!
      assert reservation.action_free_booking?
      assert reservation.paid?
    end
  end

  context 'validations' do
    setup do
      @user = FactoryGirl.create(:user)

      @listing = FactoryGirl.create(:transactable, quantity: 2)
      @listing.availability_template = AvailabilityTemplate.first
      @listing.save!

      @reservation = Reservation.new(:user => @user, :quantity => 1, payment_method: @manual_payment_method)
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
        reservation = @listing.reservations.build(:user => @user, :quantity => 2, payment_method: @manual_payment_method)
        reservation.add_period(@monday)
        reservation.save!
        reservation.confirm

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

  context 'attempt payment capture' do

    setup do
      @reservation = FactoryGirl.create(:reservation_with_credit_card)
    end

    should 'not attempt to capture payment' do
      @reservation.stubs(:billing_authorization).returns(nil).at_least(0)
      @reservation.stubs(:recurring_booking_id).returns(1).at_least(0)
      @reservation.expects(:attempt_payment_capture).never
      @reservation.expects(:schedule_payment_capture).once
      @reservation.payment_capture
    end

    should 'do not schedule payment capture if has no billing authorization but also do not belong to recurring booking ' do
      @reservation.stubs(:billing_authorization).returns(nil).at_least(0)
      @reservation.stubs(:recurring_booking_id).returns(nil).at_least(0)
      @reservation.expects(:schedule_payment_capture).never
      @reservation.payment_capture
    end

    should 'attempt if have billing authorization' do
      @reservation.stubs(:billing_authorization).returns(stub()).at_least(0)
      @reservation.stubs(:recurring_booking_id).returns(nil).at_least(0)
      @reservation.expects(:attempt_payment_capture).once
      @reservation.expects(:schedule_payment_capture).never
      @reservation.payment_capture
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

end

