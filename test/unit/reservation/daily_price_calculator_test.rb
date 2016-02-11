require 'test_helper'

class Reservation::DailyPriceCalculatorTest < ActiveSupport::TestCase

  setup do
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
    @listing.stubs(:overnight_booking?).returns(false)

    @reservation.stubs(:listing).returns(@listing)

    @calculator = Reservation::DailyPriceCalculator.new(@reservation)
  end

  context 'favourable price' do

    setup do
      @reservation.stubs(:favourable_pricing_rate).returns(true)
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
          @dates = [Time.zone.today, Time.zone.today + 2.days, Time.zone.today + 4.days, Time.zone.today + 8.days]
          @dates.each do |date|
            @listing.stubs(:availability_for).with(date).returns(2)
            @listing.stubs(:open_on?).with(date).returns(true)
          end

          @closed = [Time.zone.today + 1.day]
          @closed.each do |date|
            @listing.stubs(:open_on?).with(date).returns(false)
          end

          @unavailable = [Time.zone.today + 3.days]
          @unavailable.each do |date|
            @listing.stubs(:open_on?).with(date).returns(true)
            @listing.stubs(:availability_for).with(date).returns(1)
          end

          @listing.stubs(:open_on?).with(Time.zone.today + 5.days).returns(false)

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

      context "semantics with availability for overnight" do
        setup do
          @listing.stubs(:overnight_booking?).returns(true)

          # We set up a set of dates with gaps that are deemed "contiguous" by our
          # custom definition.
          @dates = [Time.zone.today, Time.zone.today + 1.days, Time.zone.today + 2.days, Time.zone.today + 4.days]
          @dates.each do |date|
            @listing.stubs(:availability_for).with(date).returns(1)
            @listing.stubs(:open_on?).with(date).returns(true)
          end

          @listing.stubs(:open_on?).with(Time.zone.today + 3.days).returns(false)

          seed_reservation_dates(@dates)

          # The expectation is to have blocks:
          # [today, today+1, today+2] = 2 nights
          # [today+4] = 1 night
          #
          # If a 'week' pricing is applied on 3 consecutive nights, then the pricing should be
          # 2n(from pro-rated week price) + 1n(per night price)
          @listing.stubs(:prices_by_days).returns({
            1 => 100.to_money,
            3 => 400.to_money
          })
        end

        should "take into account open availability" do
          assert_equal (2 * 400.to_money / 3) + 100.to_money, @calculator.price
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

  end

  context 'not favourable price' do

    setup do
      @reservation.stubs(:favourable_pricing_rate).returns(false)
    end

    should "be correct if price for months weeks and days has to be taken into consideration" do
      # 4 * 20 -> 80days for 4 * 1000
      # 3 * 5 -> 15 days for 3 * 400
      # 4 * 1 -> 4 days for 4 * 100
      # which gives total 4000 + 1200 + 400 = 5600 for one desk
      # because quantity is 2, the total is 5600 * 2 = 11200
      dates = date_groups_of(99, 2)
      seed_reservation_dates(dates)
      assert_equal 11200_00, @calculator.price.cents
    end

    should "be correct if price for months and weeks has to be taken into consideration" do
      # 4 * 20 -> 80days for 4 * 1000
      # 3 * 5 -> 15 days for 3 * 400
      # which gives total 4000 + 1200 = 5200 for one desk
      dates = date_groups_of(95, 1)
      seed_reservation_dates(dates)
      assert_equal 5200_00, @calculator.price.cents
    end

    should "be correct if price for months and days has to be taken into consideration" do
      dates = date_groups_of(22, 1)
      seed_reservation_dates(dates)
      assert_equal 1200_00, @calculator.price.cents
    end

    should "be correct if price for weeks and days has to be taken into consideration" do
      dates = date_groups_of(12, 1)
      seed_reservation_dates(dates)
      assert_equal 1000_00, @calculator.price.cents
    end

    should "be correct if only price for days has to be taken into consideration" do
      dates = date_groups_of(4, 1)
      seed_reservation_dates(dates)
      assert_equal 400_00, @calculator.price.cents
    end

    should "be correct if only price for months is defined and I want to book more than 30 days" do
      #pro rate even when favourable pricing is disabled to avoid error when only montly price is enabled
      @listing.stubs(:prices_by_days).returns({
            30 => 400.to_money
          })
      dates = date_groups_of(35, 1)
      seed_reservation_dates(dates)
      assert_equal (400_00 + ((5/30.to_f) * 400_00)).round, @calculator.price.cents
    end

  end

  private

  # Return dates in groups to use for seeding the tests
  def date_groups_of(count = 1, quantity = 3)
    quantity.times.map do |i|
      count.times.map do |c|
        Time.zone.today.advance(:months => i*count, :days => c)
      end
    end
  end

  def seed_reservation_dates(dates, reservation = @reservation)
    dates.flatten.uniq.each do |date|
      reservation.periods.build(:date => date)
    end
  end

end

