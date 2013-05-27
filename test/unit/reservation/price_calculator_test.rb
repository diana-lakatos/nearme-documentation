require 'test_helper'

class Reservation::PriceCalculatorTest < ActiveSupport::TestCase
  def setup
    @reservation = Reservation.new

    @listing = stub()
    @listing.stubs(:prices_by_days).returns({
        1 => 100.to_money,
        5 => 400.to_money,
        20 => 1000.to_money
    })
    @listing.stubs(:open_on?).returns(true)
    @listing.stubs(:availability_for).returns(10)

    @reservation.stubs(:listing).returns(@listing)

    @calculator = Reservation::PriceCalculator.new(@reservation)
  end

  context '#price_for_days' do
    setup do
    end

    should "be correct for 1 day" do
      assert_equal 100_00, @calculator.price_for_days(1).cents
    end

    should "be correct for 1 week" do
      assert_equal 400_00, @calculator.price_for_days(5).cents
    end

    should "be correct for pro-rated weeks" do
      assert_equal 1120_00, @calculator.price_for_days(14).cents
    end

    should "be correct for 1 month" do
      assert_equal 1000_00, @calculator.price_for_days(20).cents
    end

    should "be correct for pro-rated months" do
      assert_equal 2250_00, @calculator.price_for_days(45).cents
    end
  end

  context '#price' do
    should "be correct for individual date" do
      dates = date_groups_of(1, 1)
      seed_reservation_dates(dates)

      assert_equal 100_00, @calculator.price.cents
    end

    should "be correct for set of individual date" do
      dates = date_groups_of(1, 3)
      seed_reservation_dates(dates)

      assert_equal 300_00, @calculator.price.cents
    end

    should "be correct for a week" do
      dates = date_groups_of(5, 1)
      seed_reservation_dates(dates)

      assert_equal 400_00, @calculator.price.cents
    end

    should "be correct for set of weeks" do
      dates = date_groups_of(5, 3)
      seed_reservation_dates(dates)

      assert_equal 1200_00, @calculator.price.cents
    end

    should "be correct for a pro-rata month" do
      dates = date_groups_of(45, 3)
      seed_reservation_dates(dates) 

      assert_equal 6750_00, @calculator.price.cents
    end

    should "take into account quantity" do
      @reservation.quantity = 3
      seed_reservation_dates date_groups_of(45, 3)

      assert_equal 3*6750_00, @calculator.price.cents
    end

    context "free booking" do
      setup do
        @listing.stubs(:prices_by_days).returns({
            1 => 0.to_money
          }
        )
      end

      should "return 0 for empty booking" do
        assert_equal 0, @calculator.price.cents
      end

      should "return 0 for free booking" do
        dates = date_groups_of(4, 4)
        seed_reservation_dates(dates)

        assert_equal 0, @calculator.price.cents
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

  def seed_reservation_dates(dates, reservation = @reservation)
    dates.flatten.uniq.each do |date|
      reservation.periods.build(:date => date)
    end
  end

end

