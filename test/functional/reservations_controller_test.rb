require 'test_helper'

class ReservationsControllerTest < ActionController::TestCase

  context '#event_tracker' do

    setup do
      @reservation = FactoryGirl.create(:reservation_with_credit_card)
      sign_in @reservation.owner
      stub_mixpanel
    end

    should "track and redirect a host to the My Bookings page when they cancel a booking" do
      ReservationMailer.expects(:notify_host_of_cancellation).returns(stub(deliver: true))

      @tracker.expects(:cancelled_a_booking).with do |reservation, custom_options|
        reservation == assigns(:reservation) && custom_options == { actor: 'guest' }
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).owner
      end
      @tracker.expects(:updated_profile_information).with do |user|
        user == assigns(:reservation).host
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
      Timecop.freeze(Time.zone.local(2013, 6, 28, 10, 5, 0))
      @reservation.add_period(Time.zone.local(2013, 7, 1, 10, 5, 0).to_date)
      @reservation.add_period(Time.zone.local(2013, 7, 2, 10, 5, 0).to_date)
      @reservation.add_period(Time.zone.local(2013, 7, 3, 10, 5, 0).to_date)
      @reservation.save!
      sign_in @reservation.owner
    end

    should 'be exportable to .ics format' do
      url = bookings_dashboard_url(id: @reservation.id)
      get :export, :format => :ics, :listing_id => @reservation.listing.id, :id => @reservation.id
      assert_response :success
      assert_equal "text/calendar", response.content_type
      expected_result = ["BEGIN:VCALENDAR",
                         "PRODID;X-RICAL-TZSOURCE=TZINFO:-//com.denhaven2/NONSGML ri_cal gem//EN",
                         "CALSCALE:GREGORIAN",
                         "VERSION:2.0",
                         "X-WR-CALNAME::Desks Near Me",
                         "X-WR-RELCALID::#{@reservation.owner.id}",
                         "BEGIN:VEVENT",
                         "CREATED;VALUE=DATE-TIME:20130628T100500Z",
                         "DTEND;VALUE=DATE-TIME:20130701T170000",
                         "DTSTART;VALUE=DATE-TIME:20130701T090000",
                         "LAST-MODIFIED;VALUE=DATE-TIME:20130628T100500Z",
                         "UID:#{@reservation.id}_2013-07-01",
                         "DESCRIPTION:Aliquid eos ab quia officiis sequi.",
                         "URL:#{url}",
                         "SUMMARY:ICS Listing",
                         "LOCATION:42 Wallaby Way",
                         "END:VEVENT",
                         "BEGIN:VEVENT",
                         "CREATED;VALUE=DATE-TIME:20130628T100500Z",
                         "DTEND;VALUE=DATE-TIME:20130702T170000",
                         "DTSTART;VALUE=DATE-TIME:20130702T090000",
                         "LAST-MODIFIED;VALUE=DATE-TIME:20130628T100500Z",
                         "UID:#{@reservation.id}_2013-07-02",
                         "DESCRIPTION:Aliquid eos ab quia officiis sequi.",
                         "URL:#{url}",
                         "SUMMARY:ICS Listing",
                         "LOCATION:42 Wallaby Way",
                         "END:VEVENT",
                         "BEGIN:VEVENT",
                         "CREATED;VALUE=DATE-TIME:20130628T100500Z",
                         "DTEND;VALUE=DATE-TIME:20130703T170000",
                         "DTSTART;VALUE=DATE-TIME:20130703T090000",
                         "LAST-MODIFIED;VALUE=DATE-TIME:20130628T100500Z",
                         "UID:#{@reservation.id}_2013-07-03",
                         "DESCRIPTION:Aliquid eos ab quia officiis sequi.",
                         "URL:#{url}",
                         "SUMMARY:ICS Listing",
                         "LOCATION:42 Wallaby Way",
                         "END:VEVENT",
                         "END:VCALENDAR"]
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

    context 'render view' do
      should 'if no bookings' do
        get :upcoming
        assert_response :success
        assert_select ".box .no-data", "You don't have any upcoming bookings. Find a space near you!"
      end

      should 'if any upcoming bookings' do
        FactoryGirl.create(:reservation, owner: @user)
        get :upcoming
        assert_response :success
      end

      should 'if any archived bookings' do
        FactoryGirl.create(:past_reservation, owner: @user)
        get :upcoming
        assert_response :success
      end
    end
  end


end

