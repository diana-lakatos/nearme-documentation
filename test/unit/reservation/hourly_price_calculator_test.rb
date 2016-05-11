require 'test_helper'

class Reservation::HourlyPriceCalculatorTest < ActiveSupport::TestCase

  setup do
    @reservation = Reservation.new
    @reservation.stubs(:transactable_pricing).returns(
      stub({
        action: stub({
          minimum_booking_days: 1,
          favourable_pricing_rate: true
        }),
        all_prices_for_unit: {
          1 => {price: 100.to_money},
          5 => {price: 400.to_money},
        }
      })
    )
    @calculator = Reservation::HourlyPriceCalculator.new(@reservation)
  end

  context '#price' do
    should "be correct for individual date, hour" do
      add_date(Time.zone.today, 9*60, 10*60)
      assert_equal 100_00, @calculator.price.cents
    end

    should "be correct for 5 hours" do
      add_date(Time.zone.today, 10*60, 15*60)
      assert_equal 400_00, @calculator.price.cents
    end

    should "be correct for individual date, multiple hour" do
      add_date(Time.zone.today, 9*60, 12*60)
      assert_equal 300_00, @calculator.price.cents
    end

    should "be correct for individual date, multiple partial hour" do
      add_date(Time.zone.today, 9*60, 12*60+15)
      assert_equal 325_00, @calculator.price.cents
    end

    should "be correct for multiple dates, hour" do
      add_date(Time.zone.today, 9*60, 10*60)
      add_date(Time.zone.today+1, 9*60, 10*60)
      assert_equal 200_00, @calculator.price.cents
    end

    should "be correct for multiple dates, multiple hour" do
      add_date(Time.zone.today, 9*60, 12*60)
      add_date(Time.zone.today+2, 12*60, 18*60)
      assert_equal 780_00, @calculator.price.cents
    end

    should "be correct for multiple dates, multiple partial hour" do
      add_date(Time.zone.today, 9*60, 12*60+15)
      add_date(Time.zone.today+2, 12*60, 15*60+15)
      add_date(Time.zone.today+3, 9*60, 12*60+15)
      add_date(Time.zone.today+5, 9*60, 12*60+15)
      assert_equal 1300_00, @calculator.price.cents
    end

    should "be correct for same date, multiple separate hoursxxx" do
      add_date(Time.zone.today, 9*60, 12*60)
      add_date(Time.zone.today, 13*60, 16*60)
      assert_equal 600_00, @calculator.price.cents
    end

    should "be correct for multiple quantity" do
      add_date(Time.zone.today, 9*60, 12*60)
      add_date(Time.zone.today, 13*60, 16*60)
      @reservation.quantity = 3
      assert_equal 600_00, @calculator.price.cents
    end
  end

  private

  def add_date(date, start_min = nil, end_min = nil)
    @reservation.periods.build(:date => date, :start_minute => start_min, :end_minute => end_min)
  end
end
