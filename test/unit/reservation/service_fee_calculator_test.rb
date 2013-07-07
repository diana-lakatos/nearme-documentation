require 'test_helper'

class Reservation::ServiceFeeCalculatorTest < ActiveSupport::TestCase

  def setup
    @reservation = Reservation.new
    @reservation.stubs(:subtotal_amount_cents).returns(120_00)

    @listing = stub()
    @listing.stubs(:currency).returns('USD')
    @reservation.stubs(:listing).returns(@listing)
    @service_fee_calculator = Reservation::ServiceFeeCalculator.new(@reservation)
    
  end

  context 'service fee' do
    should "have correct fee for individual date" do
      setup { @listing.stubs(:service_fee_percent).returns(BigDecimal(10)) }
      should { assert_equal 12_00, @service_fee_calculator.service_fee.cents }
    end

    should "return 0 for nil service_fee_percent" do
      setup { @listing.stubs(:service_fee_percent).returns(nil) }
      should { assert_equal 0, @service_fee_calculator.service_fee.cents }
    end
  end

end
