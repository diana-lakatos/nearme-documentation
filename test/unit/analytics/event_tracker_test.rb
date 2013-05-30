require 'test_helper'

class EventTrackerTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    @mixpanel = stub(:set => true)
    @tracker = Analytics::EventTracker.new(@mixpanel, @user)
  end

  context "#initialize" do
    should "assign user and #set via mixpanel" do
      @mixpanel.expects(:set).with(@user.id, {
        name: @user.name,
        email: @user.email,
        phone: @user.phone,
        job_title: @user.job_title
      })

      Analytics::EventTracker.new(@mixpanel, @user)
    end
  end

  context 'Reservations' do
    setup do
      @reservation = FactoryGirl.create(:reservation)
    end

    should 'track a booking request' do
      expect_event 'Requested a Booking', {
        booking_desks: @reservation.quantity,
        booking_days: @reservation.total_days,
        booking_total: @reservation.total_amount_dollars,
        location_address: @reservation.address,
        location_currency: @reservation.currency,
        location_suburb: @reservation.suburb,
        location_city: @reservation.city,
        location_state: @reservation.state,
        location_country: @reservation.country
      }

      tracker.requested_a_booking(@reservation)
    end
  end

  private

  def expect_event(event_name, params)
    @mixpanel.expects(:track_event).with do |name, options|
      event_name == name && options == params
    end
  end

  def expect_set(user_id, params)
    @mixpanel.expects(:set).with do |*args|
      raise "got #{args.inspect}"
      args == [user_id, params]
    end
  end

end
