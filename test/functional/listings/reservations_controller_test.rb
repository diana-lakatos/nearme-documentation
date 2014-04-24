require 'test_helper'

class Listings::ReservationsControllerTest < ActionController::TestCase

  setup do
    @listing = FactoryGirl.create(:listing_in_san_francisco)
    @user = FactoryGirl.create(:user)
    sign_in @user
    stub_mixpanel
    stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
    @listing.instance.instance_payment_gateways << FactoryGirl.create(:stripe_instance_payment_gateway)
    stub_billing_gateway
  end


  should "track booking review open" do
    @tracker.expects(:reviewed_a_booking).with do |reservation|
      reservation == assigns(:reservation_request).reservation.decorate
    end
    post :review, booking_params_for(@listing)
    assert_response 200
  end

  should "track booking request" do
    ReservationMailer.expects(:notify_host_with_confirmation).returns(stub(deliver: true)).once
    ReservationMailer.expects(:notify_guest_with_confirmation).returns(stub(deliver: true)).once

    @tracker.expects(:requested_a_booking).with do |reservation|
      reservation == assigns(:reservation_request).reservation
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation_request).reservation.owner
    end
    @tracker.expects(:updated_profile_information).with do |user|
      user == assigns(:reservation_request).reservation.host
    end
    assert_difference 'Reservation.count' do
      post :create, booking_params_for(@listing)
    end
    assert_response :redirect
  end

  context 'schedule expiry' do

    should 'create a delayed_job task to run in 24 hours time when saved' do
      Timecop.freeze(Time.zone.now) do
        ReservationExpiryJob.expects(:perform_later).with do |time, id|
          time == 24.hours.from_now
        end
        post :create, booking_params_for(@listing)
      end
    end

  end

  context "#twilio" do

    context 'sending sms fails' do

      should 'raise invalid phone number exception if message indicates so' do
        ReservationMailer.expects(:notify_host_with_confirmation).returns(stub(deliver: true)).once
        ReservationMailer.expects(:notify_guest_with_confirmation).returns(stub(deliver: true)).once

        ActiveSupport::TaggedLogging.any_instance.expects(:error).never
        User.any_instance.expects(:notify_about_wrong_phone_number).once
        SmsNotifier::Message.any_instance.stubs(:send_twilio_message).raises(Twilio::REST::RequestError, "The 'To' number +16665554444 is not a valid phone number")
        assert_nothing_raised do 
          post :create, booking_params_for(@listing)
        end
        assert @response.body.include?('redirect')
        assert_redirected_to booking_successful_reservation_path(Reservation.last)
      end

      should 'log twilio exceptions that have unknown message' do
        ReservationMailer.expects(:notify_host_with_confirmation).returns(stub(deliver: true)).once
        ReservationMailer.expects(:notify_guest_with_confirmation).returns(stub(deliver: true)).once

        @controller.class.any_instance.expects(:handle_invalid_mobile_number).never
        SmsNotifier::Message.any_instance.stubs(:send_twilio_message).raises(Twilio::REST::RequestError, "Some other error")
        ActiveSupport::TaggedLogging.any_instance.expects(:error).once
        assert_nothing_raised do 
          post :create, booking_params_for(@listing)
        end
        assert @response.body.include?('redirect')
        assert_redirected_to booking_successful_reservation_path(Reservation.last)
      end

    end

  end

  context 'versions' do

    should 'store new version after creating reservation' do
      assert_difference('Version.where("item_type = ? AND event = ?", "Reservation", "create").count') do
        with_versioning do
          post :create, booking_params_for(@listing)
        end
      end
    end

  end

  private

  def booking_params_for(listing)
    {
      listing_id: listing.id,
      reservation_request: {
        dates: [Chronic.parse('Monday')],
        quantity: "1",
        card_number: 4111111111111111,
        card_expires: 1.year.from_now.strftime("%m/%y"),
        card_code: '111'
      }
    }
  end

  def object_hash_for(reservation)
    {
      booking_desks: reservation.quantity,
      booking_days: reservation.total_days,
      booking_total: reservation.total_amount_dollars,
      location_address: reservation.location.address,
      location_currency: reservation.location.currency,
      location_suburb: reservation.location.suburb,
      location_city: reservation.location.city,
      location_state: reservation.location.state,
      location_country: reservation.location.country,
      location_postcode: reservation.location.postcode
    }
  end

end
