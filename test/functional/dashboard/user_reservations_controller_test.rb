require 'test_helper'

class Dashboard::UserReservationsControllerTest < ActionController::TestCase
  context 'export' do
    should 'be exportable to .ics format' do
      @transactable = FactoryGirl.create(:transactable, name: 'ICS Listing')
      @reservation = FactoryGirl.build(:unconfirmed_reservation, transactable: @transactable)
      @reservation.periods = []
      travel_to Time.zone.local(2013, 6, 28, 10, 5, 0) do
        @reservation.add_period(Time.zone.local(2013, 7, 1, 10, 5, 0).to_date)
        @reservation.add_period(Time.zone.local(2013, 7, 2, 10, 5, 0).to_date)
        @reservation.add_period(Time.zone.local(2013, 7, 3, 10, 5, 0).to_date)
        @reservation.save!
        sign_in @reservation.owner

        url = dashboard_user_reservations_url(id: @reservation.id, host: Rails.application.routes.default_url_options[:host])
        get :export, { format: :ics, listing_id: @reservation.transactable.id, id: @reservation.id }
        assert_response :success
        assert_equal 'text/calendar', response.content_type
        expected_result = ['BEGIN:VCALENDAR',
                           'PRODID;X-RICAL-TZSOURCE=TZINFO:-//com.denhaven2/NONSGML ri_cal gem//EN',
                           'CALSCALE:GREGORIAN',
                           'VERSION:2.0',
                           "X-WR-CALNAME::#{@reservation.transactable.company.instance.name}",
                           "X-WR-RELCALID::#{@reservation.owner.id}",
                           'BEGIN:VEVENT',
                           'CREATED;VALUE=DATE-TIME:20130628T100500Z',
                           'DTEND;VALUE=DATE-TIME:20130701T170000',
                           'DTSTART;VALUE=DATE-TIME:20130701T090000',
                           'LAST-MODIFIED;VALUE=DATE-TIME:20130628T100500Z',
                           "UID:#{@reservation.id}_2013-07-01",
                           'DESCRIPTION:Aliquid eos ab quia officiis sequi.',
                           "URL:#{url}",
                           'SUMMARY:ICS Listing',
                           'LOCATION:42 Wallaby Way\\, North Highlands\\, California',
                           'END:VEVENT',
                           'BEGIN:VEVENT',
                           'CREATED;VALUE=DATE-TIME:20130628T100500Z',
                           'DTEND;VALUE=DATE-TIME:20130702T170000',
                           'DTSTART;VALUE=DATE-TIME:20130702T090000',
                           'LAST-MODIFIED;VALUE=DATE-TIME:20130628T100500Z',
                           "UID:#{@reservation.id}_2013-07-02",
                           'DESCRIPTION:Aliquid eos ab quia officiis sequi.',
                           "URL:#{url}",
                           'SUMMARY:ICS Listing',
                           'LOCATION:42 Wallaby Way\\, North Highlands\\, California',
                           'END:VEVENT',
                           'BEGIN:VEVENT',
                           'CREATED;VALUE=DATE-TIME:20130628T100500Z',
                           'DTEND;VALUE=DATE-TIME:20130703T170000',
                           'DTSTART;VALUE=DATE-TIME:20130703T090000',
                           'LAST-MODIFIED;VALUE=DATE-TIME:20130628T100500Z',
                           "UID:#{@reservation.id}_2013-07-03",
                           'DESCRIPTION:Aliquid eos ab quia officiis sequi.',
                           "URL:#{url}",
                           'SUMMARY:ICS Listing',
                           'LOCATION:42 Wallaby Way\\, North Highlands\\, California',
                           'END:VEVENT',
                           'END:VCALENDAR']
        assert_equal expected_result, response.body.split("\r\n").reject { |el| el.include?('DTSTAMP') }
      end
    end
  end

  context 'GET bookings' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @company = FactoryGirl.create(:company_in_auckland, creator_id: @user.id)
      @location = FactoryGirl.create(:location_in_auckland)
      @transactable = FactoryGirl.create(:transactable, location: @location)
      @company.locations << @location
    end

    context 'render view' do
      context 'with upcoming reservation' do
        setup do
          @reservation = FactoryGirl.create(:future_unconfirmed_reservation, user: @user)
          get :upcoming
          assert_response :success
          assert_select '.order', 1
        end

        should 'allow to cancel if cancelation policy does not apply' do
          stub_active_merchant_interaction
          assert_select 'form[action=?]', user_cancel_dashboard_user_reservation_path(@reservation)
          post :user_cancel, { id: @reservation }
          assert_redirected_to dashboard_orders_path
          assert_select '.order', 0
          assert @reservation.reload.cancelled?
        end
      end

      context 'reservation with cancellation policy' do
        should 'not allow to cancel if cancelation policy does apply' do
          @reservation = FactoryGirl.create(:future_unconfirmed_reservation, user: @user, cancellation_policy_hours_for_cancellation: 1)
          time = Time.now.in_time_zone(@reservation.time_zone).advance(minutes: 59)
          @reservation.add_period(time.to_date, time.to_minutes, time.to_minutes + 60)
          @reservation.save!

          get :upcoming
          assert_response :success
          assert_select '.order', 1
          assert_select '.order form', 0
          post :user_cancel, { id: @reservation }
          assert_redirected_to dashboard_orders_path
          assert_not @reservation.reload.cancelled?
        end

        should 'not allow to cancel when reservation already started' do
          @reservation = FactoryGirl.create(:lasting_reservation, user: @user, cancellation_policy_hours_for_cancellation: nil)
          @reservation.activate!
          get :upcoming
          assert_response :success
          assert_select '.order', 1
          assert_select '.order form', 0
          post :user_cancel, { id: @reservation }
          assert_redirected_to dashboard_orders_path
          assert_not @reservation.reload.cancelled?
        end

        should 'not allow to cancel if cancelation policy does apply for user in different timezone' do
          @user.update_attributes(time_zone: 'London')
          @reservation = FactoryGirl.create(:future_unconfirmed_reservation, user: @user, time_zone: 'Tokelau Is.', cancellation_policy_hours_for_cancellation: 1)
          @reservation.periods.destroy_all

          # Adding new period form 13:15 to 14:00 2016-01-30 Tokelau Is. Timezone
          reservation_period = @reservation.add_period(Date.parse('2016-01-30'), 13 * 60 + 15, 14 * 60)
          @reservation.save!

          # Travel to UTC time - similar as user London 13h before reservation happends but reservation zone is +13h
          # Lising should be stil visible but not cancelable anymore

          travel_to Date.parse('2016-01-30').beginning_of_day do
            get :upcoming
            assert_response :success
            assert_select '.order', 1
            assert_select '.order form', 0
            stub_active_merchant_interaction
            post :user_cancel, { id: @reservation }
            assert_redirected_to dashboard_orders_path
            assert_not @reservation.reload.cancelled?
          end
        end
      end
    end
  end

  context 'versions' do
    should 'store new version after user cancel' do
      stub_active_merchant_interaction
      @reservation = FactoryGirl.create(:future_unconfirmed_reservation)
      sign_in @reservation.owner
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "update").count') do
        with_versioning do
          post :user_cancel, { listing_id: @reservation.transactable.id, id: @reservation.id }
        end
      end
    end
  end
end
