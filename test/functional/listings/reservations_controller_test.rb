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
        reservation == assigns(:reservation)
      end
      xhr :post, :review, booking_params_for(@listing)
      assert_response 200
    end

    should "track booking request" do
      @tracker.expects(:requested_a_booking).with do |reservation|
        reservation == assigns(:reservation)
      end
      xhr :post, :create, booking_params_for(@listing)
      assert_response 200
    end

  end

  def booking_params_for(listing)
    {
      "listing_id" => @listing.id,
      "reservation" => {
        "dates" => [Chronic.parse('Monday')],
        "quantity"=>"1"
      }
    }
  end

end

