require 'test_helper'

class ListingTest < ActiveSupport::TestCase

  should belong_to(:location)
  should belong_to(:listing_type)
  should have_many(:reservations)
  should have_many(:ratings)
  should have_many(:unit_prices)

  should validate_presence_of(:location)
  should validate_presence_of(:name)
  should validate_presence_of(:description)
  should validate_presence_of(:quantity)
  should validate_presence_of(:listing_type_id)
  should validate_numericality_of(:quantity)
  should allow_value('x' * 250).for(:description)
  should_not allow_value('x' * 251).for(:description)

  setup do
    @listing = FactoryGirl.build(:listing)
  end

  test "setting the price with hyphens" do
    @listing.daily_price = "50-100"
    assert_equal 5000, @listing.price_cents
  end

  test "price with other strange characters" do
    @listing.daily_price = "50.0-!@\#$%^&*()100"
    assert_equal 5000, @listing.price_cents
  end

  test "negative price is 0" do
    @listing.daily_price = "-100"
    assert_equal 0, @listing.price_cents
  end

  context "first available date" do
    should "return monday for friday" do
      friday = Date.today.sunday + 5.days
      Timecop.freeze(friday.to_time)
      assert_equal friday+3.day, @listing.first_available_date
    end

    should "return monday for saturday" do
      saturday = Date.today.sunday + 6.days
      Timecop.freeze(saturday.to_time)
      assert_equal saturday+2.day, @listing.first_available_date
    end

    should "return monday for sunday" do
      sunday = Date.today.sunday
      Timecop.freeze(sunday.to_time)
      assert_equal sunday+1.day, @listing.first_available_date
    end

    should "return tuesday for monday" do
      tuesday = Date.today.sunday + 2
      Timecop.freeze(tuesday.to_time)
      assert_equal tuesday+1.day, @listing.first_available_date
    end

    should "return monday for tuesday if the whole week is booked" do
      @listing.save!
      tuesday = Date.today.sunday + 2
      Timecop.freeze(tuesday.to_time)
      dates = [tuesday]
      4.times do |i|
        dates << tuesday + i.day
      end
      @listing.reserve!(FactoryGirl.build(:user), dates, 1)
      # wednesday, thursday, friday = 3, saturday, sunday = 2 -> monday is sixth day
      assert_equal tuesday+6.day, @listing.first_available_date
    end

    should "return thursday for tuesday if there is one desk left" do
      @listing.quantity = 2
      @listing.save!
      tuesday = Date.today.sunday + 2
      Timecop.freeze(tuesday.to_time)
      # book all seats on wednesday
      @listing.reserve!(FactoryGirl.build(:user), [tuesday+1.day], 2)
      # leave one seat free on thursday
      @listing.reserve!(FactoryGirl.build(:user), [tuesday+2.day], 1)
      # the soonest day should be the one with at least one seat free
      assert_equal tuesday+2.day, @listing.first_available_date
    end
  end
end
