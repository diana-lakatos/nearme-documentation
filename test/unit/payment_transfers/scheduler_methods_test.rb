require 'test_helper'

class PaymentTransfers::SchedulerMethodsTest < ActiveSupport::TestCase
  setup do
    @instance = FactoryGirl.build(:instance)
  end

  context 'method next_payment_transfers_date' do
    should 'return correct date of next payment transfers' do
      @instance.payment_transfers_frequency = 'daily'
      travel_to(Time.zone.now.next_week) do
        assert PaymentTransfers::SchedulerMethods.new(@instance).next_payment_transfers_date.tuesday?
      end

      @instance.payment_transfers_frequency = 'semiweekly'
      obj = PaymentTransfers::SchedulerMethods.new(@instance)
      travel_to(Time.zone.now.next_week) do
        next_date = obj.next_payment_transfers_date
        assert next_date.thursday?
        next_date = obj.next_payment_transfers_date(Time.zone.now - 1.day)
        assert next_date.monday?
      end

      @instance.payment_transfers_frequency = 'weekly'
      assert PaymentTransfers::SchedulerMethods.new(@instance).next_payment_transfers_date.monday?

      @instance.payment_transfers_frequency = 'fortnightly'
      obj = PaymentTransfers::SchedulerMethods.new(@instance)
      travel_to(Time.zone.now.beginning_of_month) do
        assert_equal 15, obj.next_payment_transfers_date.day
        assert_equal 1, obj.next_payment_transfers_date(Time.zone.now.beginning_of_month + 2.weeks).day
      end

      @instance.payment_transfers_frequency = 'monthly'
      assert_equal 1, PaymentTransfers::SchedulerMethods.new(@instance).next_payment_transfers_date.day
    end
  end
end
