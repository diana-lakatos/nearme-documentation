require 'test_helper'

class ReservationPeriodTest < ActiveSupport::TestCase
  setup do
    @transactable = FactoryGirl.create(:transactable, quantity: 2)
    @user = FactoryGirl.create(:user)
    @reservation = FactoryGirl.build(:confirmed_reservation, transactable: @transactable, user: @user)
    @next_monday = Time.zone.today.advance(weeks: 1).beginning_of_week
  end

  context '#bookable?' do
    context 'daily transactables' do
      should 'determine status correctly' do
        period = @reservation.periods.build(date: @next_monday)
        assert period.bookable?

        res = FactoryGirl.create(:confirmed_reservation, transactable: @transactable, quantity: 1, date: @next_monday, user: @user)
        period = @reservation.periods.build(date: @next_monday)
        assert period.bookable?

        res = FactoryGirl.create(:confirmed_reservation, transactable: @transactable, quantity: 1, date: @next_monday, user: @user)
        period = @reservation.periods.build(date: @next_monday)
        assert !period.bookable?
      end
    end

    context 'hourly transactables' do
      setup do
        @nine = 9 * 60
        @one  = 13 * 60
      end

      should 'determine status correctly' do
        period = @reservation.periods.build(date: @next_monday, start_minute: @nine, end_minute: @one)
        assert period.bookable?

        res = FactoryGirl.build(:confirmed_reservation, transactable: @transactable, quantity: 1, user: @user)
        res.periods.destroy_all
        res.add_period(@next_monday, @nine, @one)
        res.save!

        assert period.bookable?

        res = FactoryGirl.build(:confirmed_reservation, transactable: @transactable, quantity: 1, user: @user)
        res.periods.destroy_all
        res.add_period(@next_monday, @nine, @one)
        res.save!

        assert !period.bookable?
      end

      should 'not be bookable at a closed time' do
        period = @reservation.periods.build(date: @next_monday, start_minute: 0, end_minute: 30)
        assert !period.bookable?
      end
    end
  end

  context '#hours' do
    should 'return the amount of hours in the booking' do
      period = @reservation.periods.build(date: Time.zone.today, start_minute: 9 * 60, end_minute: 18 * 60 + 15)
      assert_equal 9.25, period.hours
    end
  end
end
