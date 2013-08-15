require 'test_helper'

class Listings::ReservationsControllerTest < ActionController::TestCase

  context "making a booking" do

    setup do
      @listing = FactoryGirl.create(:listing_in_san_francisco)
      @user = FactoryGirl.create(:user)
      sign_in @user
      stub_mixpanel
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

        should 'raise invalid phone number exception if message indicates so' do
          BackgroundIssueLogger.expects(:log_issue).never
          @controller.class.any_instance.expects(:handle_invalid_mobile_number).once
          SmsNotifier::Message.any_instance.stubs(:deliver).raises(Twilio::REST::RequestError, "The 'To' number +16665554444 is not a valid phone number")
          assert_nothing_raised do 
            xhr :post, :create, booking_params_for(@listing)
          end
          assert @response.body.include?('redirect'), "Expected json object with redirect, got #{@response.body}"
        end

        should 'log twilio exceptions that have unknown message' do
          @controller.class.any_instance.expects(:handle_invalid_mobile_number).never
          SmsNotifier::Message.any_instance.stubs(:deliver).raises(Twilio::REST::RequestError, "Some other error")
          BackgroundIssueLogger.expects(:log_issue).once
          assert_nothing_raised do 
            xhr :post, :create, booking_params_for(@listing)
          end
          assert @response.body.include?('redirect'), "Expected json object with redirect, got #{@response.body}"
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

