# frozen_string_literal: true
require 'test_helper'

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
end
