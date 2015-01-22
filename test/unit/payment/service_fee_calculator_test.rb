require 'test_helper'

class Payment::ServiceFeeCalculatorTest < ActiveSupport::TestCase

  setup do
    @amount = Money.new(120_00, 'USD')
  end

  context 'service fee' do
    context 'guest' do
      should "have correct fee for individual date" do
        @service_fee_calculator = Payment::ServiceFeeCalculator.new(@amount, BigDecimal(10))
        assert_equal 12_00, @service_fee_calculator.service_fee_guest.cents
      end

      should "return 0 for nil service_fee_percent" do
        @service_fee_calculator = Payment::ServiceFeeCalculator.new(@amount)
        assert_equal 0, @service_fee_calculator.service_fee_guest.cents
      end
    end

    context 'host' do
      should "have correct fee for individual date" do
        @service_fee_calculator = Payment::ServiceFeeCalculator.new(@amount, nil, BigDecimal(10))
        assert_equal 12_00, @service_fee_calculator.service_fee_host.cents
      end

      should "return 0 for nil service_fee_percent" do
       @service_fee_calculator = Payment::ServiceFeeCalculator.new(@amount)
        assert_equal 0, @service_fee_calculator.service_fee_host.cents
      end
    end
  end

end
