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
    @listing.stubs(:minimum_booking_days).returns(1)

    @reservation.stubs(:listing).returns(@listing)

    @calculator = Reservation::PriceCalculator.new(@reservation)
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

    should "return 0 for empty booking" do
      assert_equal 0.to_money, @calculator.price
    end

    context "free booking" do
      setup do
        @listing.stubs(:prices_by_days).returns({
            1 => 0.to_money
          }
        )
      end

      should "return 0 for free booking" do
        dates = date_groups_of(4, 4)
        seed_reservation_dates(dates)

        assert_equal 0, @calculator.price.cents
      end
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

        # The expectation is to have blocks:
        # [today, today+2, today+4]
        # [today+8]
        #
        # If a 'week' pricing is applied on 3 consecutive days, then the pricing should be
        # 1w + 1d
        @listing.stubs(:prices_by_days).returns({
          1 => 100.to_money,
          3 => 400.to_money
        })
      end

      should "take into account listing availability" do
        assert_equal 500.to_money*2, @calculator.price
      end
    end
  end

  context '#valid?' do
    setup do
      @listing.stubs(:minimum_booking_days).returns(5)
    end

    should "return false if any blocks don't meet minimum date requrement" do
      seed_reservation_dates date_groups_of(4, 1)

      assert !@calculator.valid?
    end

    should "return true if blocks meet minimum date requirement" do
      seed_reservation_dates date_groups_of(5, 1)

      assert @calculator.valid?
      assert_equal 400.to_money, @calculator.price
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

