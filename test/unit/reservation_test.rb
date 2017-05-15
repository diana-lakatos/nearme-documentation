# frozen_string_literal: true
require 'test_helper'
require 'reservations_helper'
require Rails.root.join('lib', 'dnm.rb')
require Rails.root.join('app', 'serializers', 'reservation_serializer.rb')

# PLEASE NOTE:
# This test is now divided into context based on reservation state:
# If you want to add new test please do so in correct section unless it does not fit to any

class ReservationTest < ActiveSupport::TestCase
  include ReservationsHelper

  should belong_to(:transactable)
  should belong_to(:owner)
  should have_many(:periods)
  should have_one(:payment)

  context 'State test: ' do
    setup do
      stub_active_merchant_interaction
    end

    context 'inactive reservation' do
      setup do
        @reservation = FactoryGirl.build(:reservation)
      end

      should 'confirm reservation on autoconfirm mode' do
        Transactable.any_instance.stubs(:confirm_reservations?).returns(false)
        @reservation.payment = FactoryGirl.build(:authorized_payment, payable: @reservation)
        @reservation.process!

        assert @reservation.confirmed?
        assert @reservation.payment.paid?
      end

      should 'assign correct cancellation policies' do
        @reservation.payment_attributes = {}
        assert_equal 0, @reservation.payment.cancellation_policy_hours_for_cancellation
        assert_equal 0, @reservation.payment.cancellation_policy_penalty_percentage

        @reservation.attributes = { cancellation_policy_hours_for_cancellation: 47, cancellation_policy_penalty_percentage: 60 }
        @reservation.payment_attributes = {}
        assert_equal 47, @reservation.payment.cancellation_policy_hours_for_cancellation
        assert_equal 60, @reservation.payment.cancellation_policy_penalty_percentage
      end

      should 'set proper expiration time' do
        @reservation.transactable.action_type.transactable_type_action_type.update_attribute(:hours_to_expiration, 45)
        travel_to Time.zone.now do
          OrderExpiryJob.expects(:perform_later).with do |expires_at, id|
            expires_at == @reservation.expires_at && id == @reservation.id
          end
          @reservation.activate!
          assert_equal Time.now + 45.hours, @reservation.reload.expires_at
        end
      end

      should 'not create expiry job if hours is 0' do
        @reservation.activate!
        OrderExpiryJob.expects(:perform_later).never
      end

      should 'be free if total zero' do
        Reservation::DailyPriceCalculator.any_instance.stubs(:price).returns(0.to_money).at_least(1)
        @reservation.save
        assert @reservation.is_free?
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

      should 'not be cancellable if owner rejected' do
        refute @reservation.cancellable?
      end
    end

    context 'unconfirmed reservation' do
      setup do
        @reservation = FactoryGirl.create(:unconfirmed_reservation)
      end

      should 'be cancellable if all periods are for future' do
        assert @reservation.cancellable?
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

      should 'be rejected upon transactable removal' do
        @reservation.transactable.destroy
        assert @reservation.reload.rejected?
      end

      should 'not confirm when capture fails' do
        stub_active_merchant_interaction(success?: false)
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
        assert @reservation.reject('Reason')
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

      should 'confirmed reservation should last after transactable removed' do
        @reservation.transactable.destroy
        assert @reservation.reload.confirmed?
      end

      should 'behave correctly when user cancel' do
        travel_to Time.zone.now do
          assert @reservation.cancellable?
          @reservation.user_cancel!
          assert_equal Time.zone.now, @reservation.cancelled_at
          assert_nil @reservation.confirmed_at
        end
      end

      should 'schedule next refund attempt on fail' do
        stub_active_merchant_interaction(success?: false, message: 'fail')
        @reservation.host_cancel!
        assert @reservation.payment.reload.paid?
      end

      should 'not be cancellable if at least one period has past' do
        @reservation.add_period((Time.zone.today - 2.days))
        @reservation.save!
        assert @reservation.cancellable?
        FactoryGirl.create(:cancel_allowed_cellation_policy,
          cancellable: @reservation.action.transactable_type_action_type)
        @reservation.send :set_cancellation_policy
        @reservation.save!
        refute @reservation.cancellable?
      end
    end

    context 'cancelled by guest reservation' do
      setup do
        @reservation = FactoryGirl.create(:cancelled_by_guest_reservation)
      end

      should 'exist within cancelled scope' do
        assert_equal 1, Reservation.cancelled.count
      end

      should 'not be cancellable if user canceled' do
        refute @reservation.cancellable?
      end
    end

    context 'cancelled by host reservation' do
      setup do
        @reservation = FactoryGirl.create(:cancelled_by_host_reservation)
      end

      should 'exist within cancelled scope too' do
        assert_equal 1, Reservation.cancelled.count
      end

      should 'not be cancellable when owner canceled' do
        refute @reservation.cancellable?      end
    end
  end

  context 'reservation in time zone' do
    should 'should properly cast time zones' do
      Time.use_zone 'Hawaii' do
        FactoryGirl.create(:unconfirmed_reservation)
        assert_equal 1, Reservation.where('created_at < ? ', Time.now).count
        assert_equal 1, Reservation.where(['created_at < ?', Time.current]).count
        assert_equal 1, Reservation.where(['created_at < ?', Time.zone.now]).count
      end

      Reservation.destroy_all

      Time.use_zone 'Sydney' do
        FactoryGirl.create(:unconfirmed_reservation)
        assert_equal 1, Reservation.where(['created_at < ?', Time.now]).count
        assert_equal 1, Reservation.where(['created_at < ?', Time.current]).count
        assert_equal 1, Reservation.where(['created_at < ?', Time.zone.now]).count
      end
    end
  end

  context 'waiver agreement' do
    setup do
      @reservation = FactoryGirl.create(:reservation)
    end

    should 'copy instance waiver agreement template details if available' do
      @waiver_agreement_template_instance = FactoryGirl.create(:waiver_agreement_template)
      assert_difference 'WaiverAgreement.count' do
        @reservation.attributes = { waiver_agreements_attributes: { '0' => { waiver_agreement_template_id: @waiver_agreement_template_instance.id }}}
        @reservation.save!
      end
      waiver_agreement = @reservation.waiver_agreements.first
      assert_equal @waiver_agreement_template_instance.content, waiver_agreement.content
      assert_equal @waiver_agreement_template_instance.name, waiver_agreement.name
    end

    should 'raise validation error when waiver agreement not checked' do
      @waiver_agreement_template_instance = FactoryGirl.create(:waiver_agreement_template)
      @reservation.stubs(:should_validate_field?).returns(true)
      assert_no_difference 'WaiverAgreement.count' do
        @reservation.attributes = { waiver_agreements_attributes: { '0' => { waiver_agreement_template_id: @waiver_agreement_template_instance.id, _destroy: true }}}
        @reservation.save
      end
      refute @reservation.valid?
    end

    should 'copy instance waiver agreement template details if available, ignoring not assigned company template' do
      @waiver_agreement_template_instance = FactoryGirl.create(:waiver_agreement_template)
      @waiver_agreement_template_company = FactoryGirl.create(:waiver_agreement_template, target: @reservation.company)
      assert_difference 'WaiverAgreement.count' do
        @reservation.attributes = { waiver_agreements_attributes: { '0' => { waiver_agreement_template_id: @waiver_agreement_template_instance.id }}}
        @reservation.save!
      end
      assert_equal @waiver_agreement_template_instance.name, @reservation.waiver_agreements.first.name
    end

    should 'copy location waiver agreement template details if available, ignoring instance' do
      @waiver_agreement_template_instance = FactoryGirl.create(:waiver_agreement_template)
      @waiver_agreement_template_company = FactoryGirl.create(:waiver_agreement_template, target: @reservation.company)
      @reservation.location.waiver_agreement_templates << @waiver_agreement_template_company
      assert_difference 'WaiverAgreement.count' do
        @reservation.attributes = { waiver_agreements_attributes: { '0' => { waiver_agreement_template_id: @waiver_agreement_template_company.id }}}
        @reservation.save!
      end
      assert_equal @waiver_agreement_template_company.name, @reservation.waiver_agreements.first.name
    end

    should 'copy transactables waiver agreement templates details, ignoring location' do
      @waiver_agreement_template_instance = FactoryGirl.create(:waiver_agreement_template)
      @waiver_agreement_template_company = FactoryGirl.create(:waiver_agreement_template, target: @reservation.company)
      @waiver_agreement_template_company2 = FactoryGirl.create(:waiver_agreement_template, target: @reservation.company)
      @reservation.transactable.waiver_agreement_templates << @waiver_agreement_template_company
      @reservation.transactable.waiver_agreement_templates << @waiver_agreement_template_company2
      assert_difference 'WaiverAgreement.count', 2 do
        @reservation.attributes = { waiver_agreements_attributes: { '0' => { waiver_agreement_template_id: @waiver_agreement_template_company.id },
          '1' => { waiver_agreement_template_id: @waiver_agreement_template_company2.id }}
        }
        @reservation.save!
      end
      assert_equal [@waiver_agreement_template_company.name, @waiver_agreement_template_company2.name].sort, @reservation.waiver_agreements.pluck(:name).sort
    end
  end

  context 'with serialization' do
    should 'work even if the total amount is nil' do
      reservation = Reservation.new state: 'unconfirmed'
      reservation.transactable = FactoryGirl.create(:transactable)
      reservation.transactable_pricing = reservation.transactable.action_type.pricings.first
      # reservation.subtotal_amount_cents = nil
      # reservation.service_fee_amount_guest_cents = nil
      # reservation.service_fee_amount_host_cents = nil
      Reservation.any_instance.stubs(:cancellable?).returns(true)

      expected = {
        reservation: {
          id: nil,
          user_id: nil,
          listing_id: reservation.transactable.id,
          state: 'pending',
          cancellable: true,
          total_cost: { amount: 0.0, label: '$0.00', currency_code: 'USD' },
          times: []
        }
      }

      assert_equal expected, ReservationSerializer.new(reservation).as_json
    end
  end

  context 'foreign keys' do
    setup do
      @transactable = FactoryGirl.create(:transactable)
      @reservation = FactoryGirl.create(:reservation, transactable: @transactable, company_id: nil)
    end

    should 'assign correct key immediately' do
      @reservation = FactoryGirl.create(:reservation)
      assert @reservation.creator_id.present?
      assert @reservation.instance_id.present?
      assert @reservation.company_id.present?
      # assert @reservation.transactables_public
    end

    should 'assign correct creator_id' do
      assert_equal @transactable.creator_id, @reservation.creator_id
    end

    should 'assign correct company_id' do
      assert_equal @transactable.company_id, @reservation.company_id
    end
  end

  context 'validations' do
    setup do
      @user = FactoryGirl.create(:user)

      @transactable = FactoryGirl.create(:transactable, quantity: 2)
      @transactable.action_type.availability_template = AvailabilityTemplate.first
      @transactable.save!

      @reservation = Reservation.new(user: @user, quantity: 1, transactable: @transactable, transactable_pricing: @transactable.action_type.pricings.first)
      @sunday = Time.zone.today.end_of_week
      @monday = Time.zone.today.next_week.beginning_of_week
    end

    context 'date availability' do
      should 'validate date quantity available' do
        @reservation.add_period(@monday)
        assert @reservation.valid?
        @reservation.quantity = 1113
        @reservation.action.try(:validate_all_dates_available, @reservation)
        refute @reservation.errors.empty?
      end

      should 'validate date available' do
        assert @transactable.open_on?(@monday)
        refute @transactable.open_on?(@sunday)

        @reservation.add_period(@monday)
        assert @reservation.valid?

        @reservation.add_period(@sunday)
        @reservation.charge_and_confirm!
        refute @reservation.errors.blank?
      end

      should 'validate against other reservations' do
        first_reservation = FactoryGirl.create(:confirmed_reservation, transactable: @transactable)
        first_reservation.add_period(@monday)
        first_reservation.save!

        @reservation.add_period(@monday)
        @reservation.charge_and_confirm!
        refute @reservation.errors.blank?
      end
    end

    context 'minimum contiguous block requirement' do
      setup do
        @transactable.action_type.day_pricings.first.update!(number_of_units: 5)
        assert_equal 5, @transactable.action_type.minimum_booking_days
      end

      should 'require minimum days' do
        4.times do |i|
          @reservation.add_period(@monday + i)
        end

        refute @reservation.valid?

        @reservation.add_period(@monday + 4)
        assert @reservation.valid?
      end

      should 'test all blocks' do
        5.times do |i|
          @reservation.add_period(@monday + i)
        end

        # Leave a week in between
        4.times do |i|
          @reservation.add_period(@monday + i + 14)
        end

        refute @reservation.valid?

        @reservation.add_period(@monday + 4 + 14)
        assert @reservation.valid?
      end
    end
  end

  context 'with reservation pricing' do
    context 'daily priced transactable' do
      setup do
        FactoryGirl.create(:manual_payment_method)

        @transactable = FactoryGirl.build(:transactable, quantity: 10)
        @user = FactoryGirl.build(:user)
        @reservation = FactoryGirl.build(:reservation, user: @user, owner: @user, transactable: @transactable, transactable_pricing: @transactable.action_type.pricings.first)
      end

      should 'set total, subtotal and service fee cost after creating a new reservation' do
        dates              = [Time.zone.today, Date.tomorrow, Time.zone.today + 5, Time.zone.today + 6].map do |d|
          d += 1 if d.wday == 6
          d += 1 if d.wday.zero?
          d
        end
        quantity = 5

        reservation = @transactable.reservations.build(
          user: @user,
          quantity: quantity,
          transactable: @transactable,
          transactable_pricing: @transactable.action_type.pricings.first,
          dates: dates
        )

        reservation.save

        assert_equal Reservation::DailyPriceCalculator.new(reservation).price.cents * quantity, reservation.subtotal_amount.cents
        assert_equal reservation.subtotal_amount_cents * 0.1, reservation.service_fee_amount_guest.cents
        assert_equal reservation.subtotal_amount_cents * 0.1, reservation.service_fee_amount_host.cents
        assert_equal reservation.subtotal_amount_cents + reservation.service_fee_amount_guest_cents, reservation.total_amount.cents
      end

      should 'not reset total cost when saving an existing reservation' do
        WorkflowStepJob.expects(:perform).with do |klass, _id|
          klass == WorkflowStep::ReservationWorkflow::CreatedWithoutAutoConfirmation
        end

        dates = [1.week.from_now.monday]
        quantity = 2
        assert reservation = @transactable.reserve!(@user, dates, quantity)

        assert_not_nil reservation.total_amount_cents

        assert_no_difference 'reservation.total_amount_cents' do
          reservation.confirmation_email = 'joe@cuppa.com'
          reservation.save
        end
      end

      should 'raise an exception if we try to reserve more desks than are available' do
        dates    = [Time.zone.today]
        quantity = 11

        assert quantity > @transactable.availability_for(dates.first)

        assert_raises DNM::PropertyUnavailableOnDate do
          @transactable.reserve!(@user, dates, quantity)
        end
      end

      should 'charge a service fee to credit card paid reservations' do
        reservation = @transactable.reservations.build(
          user: @user,
          owner: @user,
          date: 1.week.from_now.monday,
          quantity: 1,
          transactable: @transactable,
          transactable_pricing: @transactable.action_type.pricings.first
        )

        reservation.save
        assert_not_equal 0, reservation.service_fee_amount_guest.cents
        assert_not_equal 0, reservation.service_fee_amount_host.cents
      end

      should 'charge a service fee to manual payment reservations' do
        reservation = @transactable.reservations.build(
          user: @user,
          owner: @user,
          date: 1.week.from_now.monday,
          quantity: 1,
          transactable: @transactable,
          transactable_pricing: @transactable.action_type.pricings.first
        )
        reservation.save
        assert_not_equal 0, reservation.service_fee_amount_guest.cents
        assert_not_equal 0, reservation.service_fee_amount_host.cents
      end

      context 'with additional charges' do
        setup do
          @act = FactoryGirl.create(:additional_charge_type)
          @reservation.save
        end

        should 'include fee for additional charges' do
          assert_equal @act.amount_cents, @reservation.service_additional_charges_cents
        end
      end
    end

    context 'hourly priced transactable' do
      setup do
        @transactable = FactoryGirl.create(:transactable, quantity: 10)
        @reservation = FactoryGirl.create(:confirmed_hour_reservation, transactable: @transactable)
      end

      should 'set total cost based on HourlyPriceCalculator' do
        @reservation.periods.build date: Time.zone.today.advance(weeks: 1).beginning_of_week, start_minute: 9 * 60, end_minute: 12 * 60
        @reservation.reload
        assert_equal Reservation::HourlyPriceCalculator.new(@reservation).price.cents * @reservation.quantity +
                     @reservation.service_fee_amount_guest.cents, @reservation.total_amount.cents
      end
    end
  end
end
