require 'test_helper'

class Payment::ServiceFeeCalculatorTest < ActiveSupport::TestCase

  setup do
    @amount = Money.new(120_00, 'USD')
  end

  context 'service fee' do
    context 'guest' do
      should "have correct fee for individual date" do
        options = { guest_fee_percent: BigDecimal(10) }
        service_fee_calculator = Payment::ServiceFeeCalculator.new(@amount, options)
        assert_equal 12_00, service_fee_calculator.service_fee_guest.cents
      end

      should "return 0 for nil service_fee_percent" do
        service_fee_calculator = Payment::ServiceFeeCalculator.new(@amount)
        assert_equal 0, service_fee_calculator.service_fee_guest.cents
      end
    end

    context 'host' do
      should "have correct fee for individual date" do
        options = { host_fee_percent: BigDecimal(10) }
        service_fee_calculator = Payment::ServiceFeeCalculator.new(@amount, options)
        assert_equal 12_00, service_fee_calculator.service_fee_host.cents
      end

      should "return 0 for nil service_fee_percent" do
        service_fee_calculator = Payment::ServiceFeeCalculator.new(@amount)
        assert_equal 0, service_fee_calculator.service_fee_host.cents
      end
    end

    context 'when additional charges' do
      setup do
        act = FactoryGirl.create(:additional_charge_type)
        AdditionalCharge.create(additional_charge_type_id: act.id)
        options = { guest_fee_percent: BigDecimal(10), additional_charges: AdditionalCharge.all }
        @service_fee_calculator = Payment::ServiceFeeCalculator.new(@amount, options)
      end

      should 'have correct fee with additional charges' do
        assert_equal 22_00, @service_fee_calculator.service_fee_guest.cents
      end

      should 'calculate fee wo additional charges' do
        assert_equal 12_00, @service_fee_calculator.service_fee_guest_wo_ac.cents
      end
    end
  end
end
