# frozen_string_literal: true
require 'test_helper'
require 'vcr_setup'

class ReservationTest < ActiveSupport::TestCase
  include ReservationsHelper

  should belong_to(:transactable)
  should belong_to(:owner)
  should have_many(:order_items)
  should have_one(:payment_subscription)

  context 'State test: ' do
    setup do
      stub_active_merchant_interaction
    end

    context 'monthly calculator test' do
      setup do
        @order = FactoryGirl.build(:recurring_booking)
      end

      should 'confirm recurring_booking on autoconfirm mode' do
        Transactable.any_instance.stubs(:confirm_reservations?).returns(false)
        @order.payment_subscription = FactoryGirl.build(:payment_subscription, subscriber: @order)
        assert_equal RecurringBooking::AmountCalculatorFactory::BaseAmountCalculator, @order.amount_calculator.class

        @order.process!
        assert @order.confirmed?
        assert_equal 1670, @order.order_items.first.payment.total_amount_cents
      end
    end

    context 'pro rated monthly calculator test' do
      setup do
        @order = FactoryGirl.create(:recurring_booking,
          transactable: create(:subscription_pro_rated_transactable),
        )
        @order.update_column(:starts_at, Time.zone.parse('2025-03-06'))
      end

      should 'confirm recurring_booking on autoconfirm mode' do
        Transactable.any_instance.stubs(:confirm_reservations?).returns(false)
        @order.payment_subscription = FactoryGirl.build(:payment_subscription, subscriber: @order)
        assert_equal true, @order.pro_rated?
        assert_equal RecurringBooking::AmountCalculatorFactory::FirstTimeMonthlyAmountCalculator, @order.amount_calculator.class
        @order.process!
        assert @order.confirmed?
        # pro rata is calculated for start_on date 6 March 2025
        pro_rata = (31 - 6 + 1) / 31.to_f
        assert_equal RecurringBooking::AmountCalculatorFactory::BaseAmountCalculator, @order.amount_calculator.class
        assert_equal (1670 * pro_rata).ceil, @order.order_items.first.payment.total_amount_cents
      end
    end
  end

  context 'monthly subscription' do
    setup do
      # Uncoment if you want to record new VCR cassete
      # WebMock.allow_net_connect!
    end

    should 'generate next period' do
      FactoryGirl.create_list(:confirmed_recurring_booking, 2).each do |rb|
        rb.update_column(:next_charge_date, Date.current.prev_month.end_of_month)
        rb.generate_next_period!
      end

      assert_equal 2, RecurringBooking.needs_charge(Date.current).count

      # VCR records Stripe responses to test/assets/vcr_cassettes/stripe_recurring_booking.yml
      # - to check if real connection works - remove the file and rerun test
      # - to add new connections uncomment WebMock.allow_net_connect! - those will be recorded.

      VCR.use_cassette("stripe_recurring_booking", :record => :new_episodes) do
        CreditCard.last.destroy
        # As we are using real Stripe data we are storing CC within Stripe
        CreditCard.all.each {|cc| process_credit_card!(cc) }

        RecurringBooking.needs_charge(Date.current).find_each do |rb|
          ScheduleChargeSubscriptionJob.perform(rb.id)
        end
      end

      assert_equal 1, Payment.paid.count
      assert_equal 4, RecurringBookingPeriod.count
      assert_equal 1, RecurringBooking.with_state(:overdued).count
      assert_equal 0, RecurringBooking.needs_charge(Date.current).count
      assert_equal 1, RecurringBooking.confirmed.count
    end

    should 'not include RecurringBooking that was confirmed but period was not yet generated' do
      rb = FactoryGirl.create(:confirmed_recurring_booking)
      rb.update_column(:next_charge_date, Date.current.prev_month.end_of_month)
      assert_equal 0, RecurringBooking.needs_charge(Date.current).count
    end

    should 'include properly confirmed recurring booking' do
      rb = FactoryGirl.create(:recurring_booking, state: 'unconfirmed')
      rb.update_column(:next_charge_date, Date.current.prev_month.end_of_month)
      rb.confirm!
      assert_equal 1, RecurringBooking.needs_charge(Date.current).count
    end
  end
end
