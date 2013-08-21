require 'test_helper'

class ListingTest < ActiveSupport::TestCase

  context 'desksnearme instance' do
    subject { Listing.new }

    should belong_to(:location)
    should belong_to(:listing_type)
    should have_many(:reservations)

    should validate_presence_of(:location)
    should validate_presence_of(:name)
    should validate_presence_of(:description)
    should validate_presence_of(:quantity)
    should validate_presence_of(:listing_type_id)
    should validate_numericality_of(:quantity)

    should allow_value(10).for(:quantity)
    should_not allow_value(-10).for(:quantity)

    should allow_value('x' * 250).for(:description)
    should_not allow_value('x' * 251).for(:description)

    should_not allow_value([]).for(:photos)
  end

  setup do
    @listing = FactoryGirl.build(:listing)
  end

  context "#photo_not_required" do
    subject do
      @listing = FactoryGirl.build_stubbed(:listing)
      @listing.photo_not_required = true
      @listing
    end

    should allow_value([]).for(:photos)
    should allow_value([FactoryGirl.create(:photo)]).for(:photos)
  end

  context "#prices_by_days" do
    setup do
      @listing.save!
      @listing.daily_price = 100
      @listing.weekly_price=  400
      @listing.monthly_price = 1200

      # Force a 5 day block size
      @listing.stubs(:booking_days_per_week).returns(5)
    end

    should "be correct for all prices" do
      assert_equal({ 1 => 100, 5 => 400, 20 => 1200 }, @listing.prices_by_days)
    end

    should "be correct for day & week" do
      @listing.monthly_price = nil
      assert_equal({ 1 => 100, 5 => 400 }, @listing.prices_by_days)
    end

    should "be correct for day" do
      @listing.monthly_price = nil
      @listing.weekly_price = nil
      assert_equal({ 1 => 100 }, @listing.prices_by_days)
    end

    should "be correct for week & month" do
      @listing.daily_price = nil
      assert_equal({ 5 => 400, 20 => 1200 }, @listing.prices_by_days)
    end

    should "be correct for free" do
      @listing.daily_price = nil
      @listing.monthly_price = nil
      @listing.weekly_price = nil
      @listing.free = true
      assert_equal({ 1 => 0 }, @listing.prices_by_days)
    end

    should "be correct for different block size" do
      # Force a 3 day block size
      @listing.stubs(:booking_days_per_week).returns(3)
      assert_equal({ 1 => 100, 3 => 400, 12 => 1200 }, @listing.prices_by_days)
    end
  end

  context "free flag and prices" do

    should "valid if free flag is true and no prices are provided" do
      @listing.free = true
      @listing.daily_price = nil
      @listing.weekly_price = nil
      @listing.monthly_price = nil
      @listing.save
      assert @listing.valid?
    end

    should "valid if free flag is false and at daily price is greater than zero" do
      @listing.free = false
      @listing.daily_price = 1
      @listing.weekly_price = nil
      @listing.monthly_price = nil
      @listing.save
      assert @listing.valid?
    end

    should "valid if free flag is false and at weekly price is greater than zero" do
      @listing.free = false
      @listing.daily_price = 0
      @listing.weekly_price = 1
      @listing.monthly_price = nil
      @listing.save
      assert @listing.valid?
    end

    should "valid if free flag is false and at monthly price is greater than zero" do
      @listing.free = false
      @listing.daily_price = 0
      @listing.weekly_price = 0
      @listing.monthly_price = 5
      @listing.save
      assert @listing.valid?
    end

    should "be invalid if free flag is true and the hourly_reservations flag is true" do
      @listing.free = true
      @listing.hourly_reservations = true
      @listing.save
      assert !@listing.valid?
    end
  end

  context "first available date" do

    teardown do
      Timecop.return
    end

    should "return monday for friday" do
      friday = Time.zone.today.sunday + 5.days
      Timecop.freeze(friday.beginning_of_day)
      assert_equal friday+3.day, @listing.first_available_date
    end

    should "return monday for saturday" do
      saturday = Time.zone.today.sunday + 6.days
      Timecop.freeze(saturday.beginning_of_day)
      assert_equal saturday+2.day, @listing.first_available_date
    end

    should "return monday for sunday" do
      sunday = Time.zone.today.sunday
      Timecop.freeze(sunday.beginning_of_day)
      assert_equal sunday+1.day, @listing.first_available_date
    end

    should "return tuesday for monday" do
      tuesday = Time.zone.today.sunday + 2
      Timecop.freeze(tuesday.beginning_of_day)
      assert_equal tuesday+1.day, @listing.first_available_date
    end

    should "return monday for tuesday if the whole week is booked" do
      ReservationMailer.expects(:notify_host_with_confirmation).returns(stub(deliver: true)).once
      ReservationMailer.expects(:notify_guest_with_confirmation).returns(stub(deliver: true)).once

      @listing.save!
      tuesday = Time.zone.today.sunday + 2
      Timecop.freeze(tuesday.beginning_of_day)
      dates = [tuesday]
      4.times do |i|
        dates << tuesday + i.day
      end
      @listing.reserve!(FactoryGirl.build(:user), dates, 1)
      # wednesday, thursday, friday = 3, saturday, sunday = 2 -> monday is sixth day
      assert_equal tuesday+6.day, @listing.first_available_date
    end

    should "return thursday for tuesday if there is one desk left" do
      ReservationMailer.expects(:notify_host_with_confirmation).returns(stub(deliver: true)).twice
      ReservationMailer.expects(:notify_guest_with_confirmation).returns(stub(deliver: true)).twice

      @listing.quantity = 2
      @listing.save!
      tuesday = Time.zone.today.sunday + 2
      Timecop.freeze(tuesday.beginning_of_day)
      # book all seats on wednesday
      @listing.reserve!(FactoryGirl.build(:user), [tuesday+1.day], 2)
      # leave one seat free on thursday
      @listing.reserve!(FactoryGirl.build(:user), [tuesday+2.day], 1)
      # the soonest day should be the one with at least one seat free
      assert_equal tuesday+2.day, @listing.first_available_date
    end

    should "return wednesday for monday if hourly reservation and custom availability template" do
      @listing.hourly_reservations = true
      @listing.hourly_price_cents = 5000
      @listing.availability_template_id = nil

      @listing.availability_rules.destroy_all
      @listing.save!

      @listing.availability_rules.create!({:day => 3, :open_hour => 9, :close_hour => 16, :open_minute => 0, :close_minute => 0})

      monday = Time.zone.today.sunday + 1
      Timecop.freeze(monday.beginning_of_day)

      assert_equal monday+2.day, @listing.first_available_date
    end
  end
end
