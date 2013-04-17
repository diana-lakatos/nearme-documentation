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

  context '#contiguous_blocks' do
    should "be correct for a single date" do
      dates = date_groups_of(1, 1)
      seed_reservation_dates(dates)

      assert_equal dates, @calculator.contiguous_blocks
    end

    should "be correct for a set of single dates" do
      dates = date_groups_of(1, 3)
      seed_reservation_dates(dates)

      assert_equal dates, @calculator.contiguous_blocks
    end

    should "be correct for multiple dates" do
      dates = date_groups_of(3, 1)
      seed_reservation_dates(dates)

      assert_equal dates, @calculator.contiguous_blocks
    end

    should "be correct for a set of multiple dates" do
      dates = date_groups_of(3, 3)
      seed_reservation_dates(dates)

      assert_equal dates, @calculator.contiguous_blocks
    end

    context "semantics with availability" do
      setup do
        @reservation.quantity = 2

        # We set up a set of dates with gaps that are deemed "contiguous" by our 
        # custom definition.
        @dates = [Date.today, Date.today + 2.days, Date.today + 4.days, Date.today + 8.days]
        @dates.each do |date|
          @listing.stubs(:availability_for).with(date).returns(2)
          @listing.stubs(:open_on?).with(date).returns(true)
        end

        @closed = [Date.today + 1.day]
        @closed.each do |date|
          @listing.stubs(:open_on?).with(date).returns(false)
        end

        @unavailable = [Date.today + 3.days]
        @unavailable.each do |date|
          @listing.stubs(:open_on?).with(date).returns(true)
          @listing.stubs(:availability_for).with(date).returns(1)
        end

        @listing.stubs(:open_on?).with(Date.today + 5.days).returns(false)
     
        seed_reservation_dates(@dates)
      end

      should "take into account listing availability" do
        blocks = @calculator.contiguous_blocks
        assert_equal @dates.slice(0, 3), blocks[0], blocks.inspect
        assert_equal @dates.slice(3, 1), blocks[1], blocks.inspect
      end
    end
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
    dates = []
    quantity.times do |i|
      arr = []
      count.times do |c|
        arr << Date.today.advance(:months => i*count, :days => c)
      end
      dates << arr
    end
    dates
  end

  def seed_reservation_dates(dates, reservation = @reservation)
    dates.flatten.uniq.each do |date|
      reservation.periods.build(:date => date)
    end
  end

end

