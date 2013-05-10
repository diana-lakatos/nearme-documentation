require 'test_helper'

class ReservationPeriodTest < ActiveSupport::TestCase
  def setup
    @listing = FactoryGirl.create(:listing, quantity: 2)
    @user = FactoryGirl.create(:user)
    @reservation = @listing.reservations.build(:user => @user)
    @next_monday = Date.today.advance(:weeks => 1).beginning_of_week
  end

  context "#bookable?" do
    context "daily listings" do
      should "determine status correctly" do
        period = @reservation.periods.build(:date => @next_monday)
        assert period.bookable?

        @listing.reservations.create(:quantity => 1, :date => @next_monday, :user => @user)
        assert period.bookable?

        @listing.reservations.create(:quantity => 1, :date => @next_monday, :user => @user)
        assert !period.bookable?
      end
    end

    context "hourly listings" do
      should "determine status correctly" do
        flunk
      end
    end
  end

  context "#hours" do
    should "return the amount of hours in the booking" do
      period = @reservation.periods.build(:date => Date.today, :start_minute => 9*60, :end_minute => 18*60+15)
      assert_equal 9.25, period.hours
    end
  end
end

