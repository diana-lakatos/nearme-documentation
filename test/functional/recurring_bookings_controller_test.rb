require 'test_helper'

class RecurringBookingsControllerTest < ActionController::TestCase

  setup do
    @recurring_booking = FactoryGirl.create(:recurring_booking)
    sign_in @recurring_booking.owner
  end

  context 'show' do

    context 'one reservation in past' do
      should 'redirect to upcoming' do
        get :show, id: @recurring_booking.id
        assert_redirected_to upcoming_recurring_booking_path(@recurring_booking)
      end

      context 'with two archived reservations' do
        setup do
          @past_reservation = @recurring_booking.reservations.first
          @past_reservation.periods.first.update_column(:date, Date.yesterday)
          @cancelled_reservation = @recurring_booking.reservations.last
          @cancelled_reservation.user_cancel!
          @upcoming_reservations = @recurring_booking.reservations.reject { |r| [@past_reservation.id, @cancelled_reservation.id].include?(r.id) }
          @archived_reservations = @recurring_booking.reservations.select { |r| [@past_reservation.id, @cancelled_reservation.id].include?(r.id) }
        end
        should 'list only upcoming reservations' do
          get :upcoming, id: @recurring_booking.id
          @upcoming_reservations.map(&:id).each do |r_id|
            assert_select "#reservation_#{r_id}", 1, 'Upcoming reservation not included in upcoming list'
          end
          @archived_reservations.map(&:id).each do |r_id|
            assert_select "#reservation_#{r_id}", 0, 'Archived reservation included in upcoming list'
          end
        end

        should 'list only archived reservations' do
          get :archived, id: @recurring_booking.id
          @archived_reservations.map(&:id).each do |r_id|
            assert_select "#reservation_#{r_id}", 1, 'Archived reservation not included in archived list'
          end
          @upcoming_reservations.map(&:id).each do |r_id|
            assert_select "#reservation_#{r_id}", 0, 'Upcoming reservation included in archived list'
          end
        end
      end

    end

  end

end

