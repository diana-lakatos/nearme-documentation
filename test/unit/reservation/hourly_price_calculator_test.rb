require 'test_helper'

class Reservation::HourlyPriceCalculatorTest < ActiveSupport::TestCase
  def setup
    @reservation = Reservation.new
    @listing = stub(:hourly_price => 100.to_money)
    @reservation.stubs(:listing).returns(@listing)
    @calculator = Reservation::HourlyPriceCalculator.new(@reservation)
  end

  context '#price' do
    should "be correct for individual date, hour" do
      add_date(Date.today, 9*60, 10*60)
      assert_equal 100_00, @calculator.price.cents
    end

    should "be correct for individual date, multiple hour" do
      add_date(Date.today, 9*60, 12*60)
      assert_equal 300_00, @calculator.price.cents
    end

    should "be correct for individual date, multiple partial hour" do
      add_date(Date.today, 9*60, 12*60+15)
      assert_equal 325_00, @calculator.price.cents
    end

    should "be correct for multiple dates, hour" do
      add_date(Date.today, 9*60, 10*60)
      add_date(Date.today+1, 9*60, 10*60)
      assert_equal 200_00, @calculator.price.cents
    end

    should "be correct for multiple dates, multiple hour" do
      add_date(Date.today, 9*60, 12*60)
      add_date(Date.today+2, 12*60, 18*60)
      assert_equal 900_00, @calculator.price.cents
    end

    should "be correct for multiple dates, multiple partial hour" do
      add_date(Date.today, 9*60, 12*60+15)
      add_date(Date.today+2, 12*60, 15*60+15)
      add_date(Date.today+3, 9*60, 12*60+15)
      add_date(Date.today+5, 9*60, 12*60+15)
      assert_equal 1300_00, @calculator.price.cents
    end

    should "be correct for same date, multiple separate hours" do
      add_date(Date.today, 9*60, 12*60)
      add_date(Date.today, 13*60, 16*60)
      assert_equal 600_00, @calculator.price.cents
    end

    should "be correct for multiple quantity" do
      add_date(Date.today, 9*60, 12*60)
      add_date(Date.today, 13*60, 16*60)
      @reservation.quantity = 3
      assert_equal 1800_00, @calculator.price.cents
    end
  end

  private

  def add_date(date, start_min = nil, end_min = nil)
    @reservation.periods.build(:date => date, :start_minute => start_min, :end_minute => end_min)
  end
end
