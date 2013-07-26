require 'test_helper'

class Listings::ReservationsControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  context "making a booking" do

    setup do
      @listing = FactoryGirl.create(:listing_in_san_francisco)
      @user = FactoryGirl.create(:user)
      sign_in @user
      @tracker = Analytics::EventTracker.any_instance
      stub_request(:get, /.*api\.mixpanel\.com.*/)
      stub_request(:post, "https://www.googleapis.com/urlshortener/v1/url")
    end

    should "track booking modal open" do
      @tracker.expects(:opened_booking_modal).with do |reservation|
        reservation == assigns(:reservation_request).reservation
      end
      xhr :post, :review, booking_params_for(@listing)
      assert_response 200
    end

    should "track booking request" do
      @tracker.expects(:requested_a_booking).with do |reservation|
        reservation == assigns(:reservation_request).reservation
      end
      xhr :post, :create, booking_params_for(@listing)
      assert_response 200
    end


    context "#twilio" do

      context 'sending sms fails' do

        should 'rescue from errors' do
          SmsNotifier::Message.any_instance.stubs(:deliver).raises(Twilio::REST::RequestError, "The 'To' number +16665554444 is not a valid phone number")
          assert_nothing_raised Twilio::REST::RequestError do
            xhr :post, :create, booking_params_for(@listing)
          end
        end

      end

    end

  end


  def booking_params_for(listing)
    {
      "listing_id" => listing.id,
      "reservation_request" => {
        "dates" => [Chronic.parse('Monday')],
        "quantity"=>"1"
      }
    }
  end

end

