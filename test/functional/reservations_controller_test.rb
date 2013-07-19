require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  context '#event_tracker' do

    setup do
      @reservation = FactoryGirl.create(:reservation_with_credit_card)
      stub_request(:get, /.*api\.mixpanel\.com.*/)
      sign_in @reservation.owner
      @tracker = Analytics::EventTracker.any_instance
    end

    should "track and redirect a host to the My Bookings page when they cancel a booking" do
      @tracker.expects(:cancelled_a_booking).with do |reservation, custom_options|
        reservation == assigns(:reservation) && custom_options == { actor: 'guest' }
      end
      post :user_cancel, { listing_id: @reservation.listing.id, id: @reservation.id }
      assert_redirected_to bookings_dashboard_path
    end

  end

  context 'export' do

    setup do
      @listing = FactoryGirl.create(:listing, :name => 'ICS Listing')
      @reservation = FactoryGirl.build(:reservation_with_credit_card, :listing => @listing)
      @reservation.periods = []
      Timecop.freeze(Time.zone.local(2013, 6, 28, 10, 5, 0).utc)
      @reservation.add_period(Time.zone.local(2013, 7, 1, 10, 5, 0).to_date)
      @reservation.add_period(Time.zone.local(2013, 7, 2, 10, 5, 0).to_date)
      @reservation.add_period(Time.zone.local(2013, 7, 3, 10, 5, 0).to_date)
      @reservation.save!
      sign_in @reservation.owner
      Rails.application.routes.url_helpers.stubs(:reservation_url).returns("http://example.com/reservations/1/export.ics")
    end

    should 'be exportable to .ics format' do
      get :export, :format => :ics, :listing_id => @reservation.listing.id, :id => @reservation.id
      assert_response :success
      assert_equal "text/calendar", response.content_type
      expected_result = ["BEGIN:VCALENDAR", "VERSION:2.0", "CALSCALE:GREGORIAN", "METHOD:PUBLISH",
                         "PRODID:iCalendar-Ruby", "BEGIN:VEVENT", "CREATED:100500", "DESCRIPTION:42 Wallaby Way - ICS Listing",
                         "DTEND:20130701T170000", "DTSTART:20130701T090000", "CLASS:PUBLIC",
                         "LAST-MODIFIED:100500", "LOCATION:42 Wallaby Way", "SEQUENCE:0", "SUMMARY:ICS Listing",
                         "UID:http://example.com/reservations/1/export.ics", "URL:http://example.com/reservations/1/export.ics",
                         "END:VEVENT", "BEGIN:VEVENT", "CREATED:100500", "DESCRIPTION:42 Wallaby Way - ICS Listing", "DTEND:20130702T170000",
                         "DTSTART:20130702T090000", "CLASS:PUBLIC", "LAST-MODIFIED:100500", "LOCATION:42 Wallaby Way",
                         "SEQUENCE:0", "SUMMARY:ICS Listing", "UID:http://example.com/reservations/1/export.ics", "URL:http://example.com/reservations/1/export.ics",
                         "END:VEVENT", "BEGIN:VEVENT", "CREATED:100500", "DESCRIPTION:42 Wallaby Way - ICS Listing", "DTEND:20130703T170000",
                         "DTSTART:20130703T090000", "CLASS:PUBLIC", "LAST-MODIFIED:100500", "LOCATION:42 Wallaby Way",
                         "SEQUENCE:0", "SUMMARY:ICS Listing", "UID:http://example.com/reservations/1/export.ics", "URL:http://example.com/reservations/1/export.ics",
                         "END:VEVENT", "END:VCALENDAR"]
      assert_equal expected_result, response.body.split("\r\n").reject { |el| el.include?('DTSTAMP') }
    end

    teardown do
      Timecop.return
    end

  end

  context 'GET bookings' do

    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
      @location = FactoryGirl.create(:location_in_auckland)
      @company.locations << @location
    end

    should 'redirect if no bookings' do
      get :upcoming
      assert_redirected_to search_path
      assert_equal "You haven't made any bookings yet!", flash[:warning]
    end

    should 'render view if any bookings' do
      FactoryGirl.create(:reservation, owner: @user)
      get :upcoming
      assert_response :success
    end
  end


end

