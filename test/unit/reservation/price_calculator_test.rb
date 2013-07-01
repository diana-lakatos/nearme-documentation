require 'test_helper'

class Reservation::PriceCalculatorTest < ActiveSupport::TestCase

  def setup
    @reservation = Reservation.new
    @listing = stub()
    @listing.stubs(:prices_by_days).returns({
        1 => 100.to_money
    })
    @listing.stubs(:hourly_price => 20.to_money)
    @listing.stubs(:open_on?).returns(true)
    @listing.stubs(:availability_for).returns(10)
    @listing.stubs(:minimum_booking_days).returns(1)
    @listing.stubs(:hourly_reservations?).returns(false)
    @listing.stubs(:service_fee_percent).returns(BigDecimal(10))
    @reservation.stubs(:listing).returns(@listing)
    @calculator = Reservation::PriceCalculator.new(@reservation)
  end

  context 'price' do
    context 'daily' do
      setup do
        @listing.stubs(:hourly_reservations?).returns(false)
        @calculator = Reservation::PriceCalculator.new(@reservation)
      end

      should "have correct totals for individual date" do
        dates = date_groups_of(1, 1)
        seed_reservation_dates(dates)

        assert_equal 100_00, @calculator.subtotal_price.cents
        assert_equal  10_00, @calculator.service_fee.cents
        assert_equal 110_00, @calculator.total_price.cents
      end
    end

    context 'hourly' do
      setup do
        @listing.stubs(:hourly_reservations?).returns(true)
        @calculator = Reservation::PriceCalculator.new(@reservation)
      end

      should "have correct totals for individual date, hour" do
        add_date(Date.today, 9*60, 10*60)
        assert_equal 20_00, @calculator.subtotal_price.cents
        assert_equal  2_00, @calculator.service_fee.cents
        assert_equal 22_00, @calculator.total_price.cents
      end
    end

    context "free booking" do
      setup do
        @listing.stubs(:hourly_reservations?).returns(false)
        @calculator = Reservation::PriceCalculator.new(@reservation)
        @listing.stubs(:prices_by_days).returns({
            1 => 0.to_money
          }
        )
      end

      should "return 0 for free booking" do
        dates = date_groups_of(4, 4)
        seed_reservation_dates(dates)

        assert_equal 0, @calculator.total_price.cents
      end
    end

  end

  private

  # Return dates in groups to use for seeding the tests
  def date_groups_of(count = 1, quantity = 3)
    quantity.times.map do |i|
      count.times.map do |c|
        Date.today.advance(:months => i*count, :days => c)
      end
    end
  end

  def add_date(date, start_min = nil, end_min = nil)
    @reservation.periods.build(:date => date, :start_minute => start_min, :end_minute => end_min)
  end

  def seed_reservation_dates(dates, reservation = @reservation)
    dates.flatten.uniq.each do |date|
      reservation.periods.build(:date => date)
    end
  end

end
