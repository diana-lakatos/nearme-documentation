require 'test_helper'

class Dashboard::UserReservationsControllerTest < ActionController::TestCase

  context '#event_tracker' do

    setup do
      @reservation = FactoryGirl.create(:reservation_with_credit_card)
      sign_in @reservation.owner
      stub_mixpanel
    end

    should "track and redirect a host to the My Bookings page when they cancel a booking" do
      WorkflowStepJob.expects(:perform).with(WorkflowStep::ReservationWorkflow::GuestCancelled, @reservation.id)

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
      assert_redirected_to dashboard_user_reservations_path
    end

  end

  context 'export' do
    should 'be exportable to .ics format' do
      @listing = FactoryGirl.create(:transactable, :name => 'ICS Listing')
      @reservation = FactoryGirl.build(:reservation_with_credit_card, :listing => @listing)
      @reservation.periods = []
      travel_to Time.zone.local(2013, 6, 28, 10, 5, 0) do
        @reservation.add_period(Time.zone.local(2013, 7, 1, 10, 5, 0).to_date)
        @reservation.add_period(Time.zone.local(2013, 7, 2, 10, 5, 0).to_date)
        @reservation.add_period(Time.zone.local(2013, 7, 3, 10, 5, 0).to_date)
        @reservation.save!
        sign_in @reservation.owner

        url = dashboard_user_reservations_url(id: @reservation.id, host: Rails.application.routes.default_url_options[:host])
        get :export, :format => :ics, :listing_id => @reservation.listing.id, :id => @reservation.id
        assert_response :success
        assert_equal "text/calendar", response.content_type
        expected_result = ["BEGIN:VCALENDAR",
                           "PRODID;X-RICAL-TZSOURCE=TZINFO:-//com.denhaven2/NONSGML ri_cal gem//EN",
                           "CALSCALE:GREGORIAN",
                           "VERSION:2.0",
                           "X-WR-CALNAME::#{@reservation.listing.company.instance.name}",
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
                           "LOCATION:42 Wallaby Way\\, North Highlands\\, California",
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
                           "LOCATION:42 Wallaby Way\\, North Highlands\\, California",
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
                           "LOCATION:42 Wallaby Way\\, North Highlands\\, California",
                           "END:VEVENT",
                           "END:VCALENDAR"]
        assert_equal expected_result, response.body.split("\r\n").reject { |el| el.include?('DTSTAMP') }
      end
    end
  end

  context 'GET bookings' do

    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
      @location = FactoryGirl.create(:location_in_auckland)
      @listing = FactoryGirl.create(:transactable, location: @location)
      @company.locations << @location

    end

    context 'render view' do
      should 'if no bookings' do
        @instance = FactoryGirl.create(:instance)
        get :upcoming
        assert_response :success
        assert_select "div.dash-body", "You don't have any upcoming bookings. Find #{PlatformContext.current.instance.bookable_noun} near you!"
      end

      should 'if any upcoming bookings' do
        @reservation = FactoryGirl.create(:reservation, owner: @user)
        @reservation.add_period((Time.zone.now.next_week + 4.days).to_date)
        @reservation.starts_at = @reservation.first_period.starts_at
        @reservation.ends_at = @reservation.last_period.ends_at
        @reservation.save
        get :upcoming
        assert_response :success
        assert_select ".order", 1
        dates = @reservation.periods.map{|p| I18n.l(p.date, format: :only_date_short) }.join(' ; ')
        assert_select ".order .dates", dates
      end

      should 'if any archived bookings' do
        FactoryGirl.create(:past_reservation, owner: @user)
        get :archived
        assert_response :success
        assert_select ".order", 1
      end

    end
  end

  context 'versions' do

    should 'store new version after user cancel' do
      @reservation = FactoryGirl.create(:reservation_with_credit_card)
      sign_in @reservation.owner
      stub_mixpanel
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count') do
        with_versioning do
          post :user_cancel, { listing_id: @reservation.listing.id, id: @reservation.id }
        end
      end
    end

  end
end
